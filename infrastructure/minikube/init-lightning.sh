env=$1
env=${env:="development"}
echo $env

kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-bitcoin || exit
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning || exit
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning-2 || exit
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-lightning-3 || exit
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-c-lightning-rest || exit
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-c-lightning-rest-2 || exit
kubectl wait --for=condition=ready --timeout=300s pod -l app=$env-c-lightning-rest-3 || exit

ln1pod=$(kubectl get pod -l app=$env-lightning -o name || exit)
ln2pod=$(kubectl get pod -l app=$env-lightning-2 -o name || exit)
ln3pod=$(kubectl get pod -l app=$env-lightning-3 -o name || exit)
bitcoinpod=$(kubectl get pod -l app=$env-bitcoin -o name || exit)

ln1cli="kubectl exec $ln1pod -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln2cli="kubectl exec $ln2pod -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln3cli="kubectl exec $ln3pod -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
bitcoincli="kubectl exec $bitcoinpod -- bitcoin-cli -datadir=/home/bitcoin/.bitcoin -regtest=1 -rpcport=8332 -rpcuser=test -rpcpassword=test "

initial_block_height=$($ln1cli getinfo | jq -r '.blockheight') || exit

ln1id=$($ln1cli getinfo | jq -r '.id') || exit
ln1port=$($ln1cli getinfo | jq -r '.binding[0].port') || exit
ln1addr=$($ln1cli newaddr | jq -r '.bech32') || exit
$bitcoincli generatetoaddress 1 $ln1addr || exit

ln2id=$($ln2cli getinfo | jq -r '.id') || exit
ln2port=$($ln2cli getinfo | jq -r '.binding[0].port') || exit
ln2addr=$($ln2cli newaddr | jq -r '.bech32') || exit
$bitcoincli generatetoaddress 1 $ln2addr || exit

ln3id=$($ln3cli getinfo | jq -r '.id') || exit
ln3port=$($ln3cli getinfo | jq -r '.binding[0].port') || exit
ln3addr=$($ln3cli newaddr | jq -r '.bech32') || exit
$bitcoincli generatetoaddress 1 $ln3addr || exit

ln1toln2=$($ln1cli connect $ln2id $env-lightning-service-2 $ln2port | jq -r '.id') || exit
ln2toln3=$($ln2cli connect $ln3id $env-lightning-service-3 $ln3port | jq -r '.id') || exit
ln3toln1=$($ln3cli connect $ln1id $env-lightning-service $ln1port | jq -r '.id') || exit

# Wait for funds to register before trying to open channel

# Push mining transactions to LN Nodes firther down chain so they become spendable
$bitcoincli generatetoaddress 100 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt

current_height=$(($initial_block_height + 103))

ln1Funds=0
ln2Funds=0
ln3Funds=0

while [ $ln1Funds -ne $current_height ] || [ $ln2Funds -ne $current_height ] || [ $ln3Funds -ne $current_height ]; do
  sleep 1
  ln1Funds=$($ln1cli getinfo | jq -r '.blockheight')
  ln2Funds=$($ln2cli getinfo | jq -r '.blockheight')
  ln3Funds=$($ln3cli getinfo | jq -r '.blockheight')
  echo "Waiting until block height ${current_height} synched"
  echo $ln1Funds
  echo $ln2Funds
  echo $ln3Funds
done

channel1=$($ln1cli fundchannel $ln1toln2 16777215 | jq -r '.channel_id') || exit
channel2=$($ln2cli fundchannel $ln2toln3 16777215 | jq -r '.channel_id') || exit
channel3=$($ln3cli fundchannel $ln3toln1 16777215 | jq -r '.channel_id') || exit # eeens
echo "$ln1cli fundchannel $ln1toln2 16777215 | jq -r '.channel_id'"
echo "$ln2cli fundchannel $ln2toln3 16777215 | jq -r '.channel_id'"
echo "$ln3cli fundchannel $ln3toln1 16777215 | jq -r '.channel_id'"
# Confirm the fundchannel transactions
$bitcoincli generatetoaddress 15 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt || exit
