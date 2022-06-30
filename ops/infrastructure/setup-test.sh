ln1cli="kubectl exec $(kubectl get pod -l app=development-lightning -o name) -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln2cli="kubectl exec $(kubectl get pod -l app=development-lightning-1 -o name) -- lightning-cli --network=regtest"
ln3cli="kubectl exec $(kubectl get pod -l app=development-lightning-2 -o name) -- lightning-cli --network=regtest"
bitcoincli="kubectl exec $(kubectl get pod -l app=development-bitcoin -o name) -- bitcoin-cli -regtest=1 -rpcuser=test -rpcpassword=test "

# ln1id=$($ln1cli getinfo | jq -r '.id')
# ln1port=$($ln1cli getinfo | jq -r '.binding[0].port')
# ln1addr=$($ln1cli newaddr | jq -r '.bech32')
# $bitcoincli generatetoaddress 105 $ln1addr

# ln2id=$($ln2cli getinfo | jq -r '.id')
# ln2port=$($ln2cli getinfo | jq -r '.binding[0].port')
# ln2addr=$($ln2cli newaddr | jq -r '.bech32')
# $bitcoincli generatetoaddress 105 $ln2addr

# ln3id=$($ln3cli getinfo | jq -r '.id')
# ln3port=$($ln3cli getinfo | jq -r '.binding[0].port')
# ln3addr=$($ln3cli newaddr | jq -r '.bech32')
# $bitcoincli generatetoaddress 105 $ln3addr

# ln1toln2=$($ln1cli connect $ln2id development-lightning-1-service $ln2port | jq -r '.id')
# ln1toln3=$($ln1cli connect $ln3id development-lightning-2-service $ln3port | jq -r '.id')
# ln2toln3=$($ln2cli connect $ln3id development-lightning-2-service $ln3port | jq -r '.id')
# # ln2toln1=$($ln2cli connect $ln1id development-lightning-service $ln1port | jq -r '.id')
# # ln3toln1=$($ln3cli connect $ln1id development-lightning-service $ln1port | jq -r '.id')
# # ln3toln2=$($ln3cli connect $ln2id development-lightning-1-service $ln2port | jq -r '.id')

# # Wait for funds to register before trying to open channel
# ln1Funds=$($ln1cli listfunds | jq -r '.outputs | length')
# ln2Funds=$($ln2cli listfunds | jq -r '.outputs | length')
# ln3Funds=$($ln3cli listfunds | jq -r '.outputs | length')

# # Push mining transactions to LN Nodes firther down chain so they become spendable
# $bitcoincli generatetoaddress 105 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt

# while [ $ln1Funds -ne 105 ] || [ $ln2Funds -ne 105 ] || [ $ln3Funds -ne 105 ]
# do
#   sleep 5
#   ln1Funds=$($ln1cli listfunds | jq -r '.outputs | length')
#   ln2Funds=$($ln2cli listfunds | jq -r '.outputs | length')
#   ln3Funds=$($ln3cli listfunds | jq -r '.outputs | length')
#   echo $ln1Funds
#   echo $ln2Funds
#   echo $ln3Funds
# done

# sleep 5

# # Fund 1 & 2 & 3
# echo $($ln1cli fundchannel $ln1toln2 16777215)
# echo $($ln2cli fundchannel $ln2toln3 16777215)
# echo $($ln1cli fundchannel $ln1toln3 16777215)

# # Confirm the fundchannel transactions
# $bitcoincli generatetoaddress 105 myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt

# sleep 100

bolt11=$($ln2cli invoice 677721500 initialfundin3g initialfunding | jq -r '.bolt11')
echo $($ln1cli pay $bolt11)

bolt11=$($ln3cli invoice 677721500 initialfundin3g initialfunding | jq -r '.bolt11')
echo $($ln2cli pay $bolt11)

bolt11=$($ln3cli invoice 677721500 initialfundi3n initialfundin | jq -r '.bolt11')
echo $($ln1cli pay $bolt11)




