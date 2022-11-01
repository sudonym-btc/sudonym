env=$1
env=${env:="development"}
echo $env

kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-bitcoin
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning-2
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-c-lightning-rest
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-ride-the-lightning

ln1pod=$(kubectl get pod -l app=$env-lightning -o name)
ln2pod=$(kubectl get pod -l app=$env-lightning-2 -o name)
bitcoinpod=$(kubectl get pod -l app=$env-bitcoin -o name)

ln1cli="kubectl exec $ln1pod -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln2cli="kubectl exec $ln2pod -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
bitcoincli="kubectl exec $bitcoinpod -- bitcoin-cli -datadir=/home/bitcoin/.bitcoin -regtest=1 -rpcport=8332 -rpcuser=test -rpcpassword=test "

initial_block_height=$($ln1cli getinfo | jq -r '.blockheight')

ln1id=$($ln1cli getinfo | jq -r '.id')
ln1port=$($ln1cli getinfo | jq -r '.binding[0].port')
ln1addr=$($ln1cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 1 $ln1addr

ln2id=$($ln2cli getinfo | jq -r '.id')
ln2port=$($ln2cli getinfo | jq -r '.binding[0].port')
ln2addr=$($ln2cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 1 $ln2addr

ln1toln2=$($ln1cli connect $ln2id $env-lightning-service-2 $ln2port | jq -r '.id')

# Wait for funds to register before trying to open channel
ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')

# Push mining transactions to LN Nodes firther down chain so they become spendable
$bitcoincli generatetoaddress 100 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt

while [ $ln1Funds -ne $(($initial_block_height+102)) ] || [ $ln2Funds -ne $(($initial_block_height+102)) ]
do
  sleep 1
  ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
  ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')
  echo "Waiting until block height ${initial_block_height+102} synched"
  echo $ln1Funds
  echo $ln2Funds
done

channel1=$($ln1cli fundchannel $ln1toln2 16777215 | jq -r '.channel_id')

# Confirm the fundchannel transactions
$bitcoincli generatetoaddress 5 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt

# Wait for funds to register before trying to open channel
ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')

while [ $ln1Funds -ne $(($initial_block_height+107)) ] || [ $ln2Funds -ne $(($initial_block_height+107)) ]
do
  sleep 1
  echo "Waiting until block height ${initial_block_height+107} synched"
  echo $ln1Funds
  echo $ln2Funds
  ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
  ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')
done

bolt11=$($ln2cli invoice 677721500 initialfunding initialfunding | jq -r '.bolt11')
echo $($ln1cli pay $bolt11)