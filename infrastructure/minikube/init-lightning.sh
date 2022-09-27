env=$1
env=${env:="development"}
echo $env

kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-bitcoin
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning-2
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning-3
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-c-lightning-rest
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-ride-the-lightning
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-api

ln1cli="kubectl exec $(kubectl get pod -l app=$env-lightning -o name) -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln2cli="kubectl exec $(kubectl get pod -l app=$env-lightning-2 -o name) -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln3cli="kubectl exec $(kubectl get pod -l app=$env-lightning-3 -o name) -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
bitcoincli="kubectl exec $(kubectl get pod -l app=$env-bitcoin -o name) -- bitcoin-cli -datadir=/bitcoin/.bitcoin -regtest=1 -rpcport=8332 -rpcuser=test -rpcpassword=test "

initial_block_height=$($ln1cli getinfo | jq -r '.blockheight')

ln1id=$($ln1cli getinfo | jq -r '.id')
ln1port=$($ln1cli getinfo | jq -r '.binding[0].port')
ln1addr=$($ln1cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 200 $ln1addr

ln2id=$($ln2cli getinfo | jq -r '.id')
ln2port=$($ln2cli getinfo | jq -r '.binding[0].port')
ln2addr=$($ln2cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 200 $ln2addr

ln3id=$($ln3cli getinfo | jq -r '.id')
ln3port=$($ln3cli getinfo | jq -r '.binding[0].port')
ln3addr=$($ln3cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 200 $ln3addr

ln1toln2=$($ln1cli connect $ln2id $env-lightning-service-2 $ln2port | jq -r '.id')
ln1toln3=$($ln1cli connect $ln3id $env-lightning-service-3 $ln3port | jq -r '.id')
ln2toln3=$($ln2cli connect $ln3id $env-lightning-service-3 $ln3port | jq -r '.id')

# Wait for funds to register before trying to open channel
ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')
ln3Funds=$($ln3cli getinfo | jq -r '.blockheight')

# Push mining transactions to LN Nodes firther down chain so they become spendable
$bitcoincli generatetoaddress 200 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt

while [ $ln1Funds -ne $(($initial_block_height+800)) ] || [ $ln2Funds -ne $(($initial_block_height+800)) ] || [ $ln3Funds -ne $(($initial_block_height+800)) ]
do
  sleep 1
  ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
  ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')
  ln3Funds=$($ln3cli getinfo | jq -r '.blockheight')
  echo "Waiting until block height ${initial_block_height+800} synched"
  echo $ln1Funds
  echo $ln2Funds
  echo $ln3Funds
done

# Fund 1 & 2 & 3
channel1=$($ln1cli fundchannel $ln1toln2 16777215 | jq -r '.channel_id')
channel2=$($ln2cli fundchannel $ln2toln3 16777215 | jq -r '.channel_id')
channel3=$($ln1cli fundchannel $ln1toln3 16777215 | jq -r '.channel_id')

# Confirm the fundchannel transactions
$bitcoincli generatetoaddress 200 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt

# Wait for funds to register before trying to open channel
ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')
ln3Funds=$($ln3cli getinfo | jq -r '.blockheight')

while [ $ln1Funds -ne $(($initial_block_height+1000)) ] || [ $ln2Funds -ne $(($initial_block_height+1000)) ] || [ $ln3Funds -ne $(($initial_block_height+1000)) ]
do
  sleep 1
  echo "Waiting until block height ${initial_block_height+1000} synched"
  echo $ln1Funds
  echo $ln2Funds
  echo $ln3Funds
  ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
  ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')
  ln3Funds=$($ln3cli getinfo | jq -r '.blockheight')
done

bolt11=$($ln2cli invoice 677721500 initialfunding initialfunding | jq -r '.bolt11')
echo $($ln1cli pay $bolt11)

bolt11=$($ln3cli invoice 677721500 initialfunding initialfunding | jq -r '.bolt11')
echo $($ln2cli pay $bolt11)

bolt11=$($ln3cli invoice 677721500 initialfundin initialfundin | jq -r '.bolt11')
echo $($ln1cli pay $bolt11)

# Set fees to zero
echo $($ln1cli setchannel $channel1 0 0)
echo $($ln2cli setchannel $channel1 0 0)
echo $($ln2cli setchannel $channel2 0 0)
echo $($ln3cli setchannel $channel2 0 0)
echo $($ln1cli setchannel $channel3 0 0)
echo $($ln3cli setchannel $channel3 0 0)