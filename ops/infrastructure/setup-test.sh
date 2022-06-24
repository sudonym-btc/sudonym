ln1cli="kubectl exec $(kubectl get pod -l app=development-lightning -o name) -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln2cli="kubectl exec $(kubectl get pod -l app=development-lightning-1 -o name) -- lightning-cli --network=regtest"
bitcoincli="kubectl exec $(kubectl get pod -l app=development-bitcoin -o name) -- bitcoin-cli -regtest=1 -rpcuser=test -rpcpassword=test "

ln1id=$($ln1cli getinfo | jq -r '.id')
ln1port=$($ln1cli getinfo | jq -r '.binding[0].port')
ln1addr=$($ln1cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 105 $ln1addr

ln2id=$($ln2cli getinfo | jq -r '.id')
ln2port=$($ln2cli getinfo | jq -r '.binding[0].port')
ln2addr=$($ln2cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 105 $ln2addr

ln1toln2=$($ln1cli connect $ln2id development-lightning-1-service $ln2port | jq -r '.id')
ln2toln1=$($ln2cli connect $ln1id development-lightning-service $ln1port | jq -r '.id')
echo $($ln2cli fundchannel $ln2toln1 50000)
echo $($ln1cli fundchannel $ln1toln2 50000)

# Confirm the fundchannel transactions
$bitcoincli generatetoaddress 105 $ln1addr

