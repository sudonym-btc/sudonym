ln1cli="docker exec development-lightning lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln2cli="docker exec development-lightning-test lightning-cli --network=regtest"
bitcoincli="docker exec development-bitcoin bitcoin-cli -regtest=1 -rpcuser=null -rpcpassword=null "

ln1id=$($ln1cli getinfo | jq -r '.id')
ln1port=$($ln1cli getinfo | jq -r '.binding[0].port')
ln1addr=$($ln1cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 105 $ln1addr

ln2id=$($ln2cli getinfo | jq -r '.id')
ln2port=$($ln2cli getinfo | jq -r '.binding[0].port')
ln2addr=$($ln2cli newaddr | jq -r '.bech32')
$bitcoincli generatetoaddress 105 $ln2addr

ln1toln2=$($ln1cli connect $ln2id lightning $ln2port | jq -r '.id')
ln2toln1=$($ln2cli connect $ln1id lightning $ln1port | jq -r '.id')
echo $($ln2cli fundchannel $ln2toln1 50000)
echo $($ln1cli fundchannel $ln1toln2 50000)

