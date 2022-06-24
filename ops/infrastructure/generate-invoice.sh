ln1cli="kubectl exec $(kubectl get pod -l app=development-lightning -o name) -- lightning-cli --network=regtest --rpc-file=/rpc/lightning-rpc"
ln2cli="kubectl exec $(kubectl get pod -l app=development-lightning-1 -o name) -- lightning-cli --network=regtest"
bitcoincli="kubectl exec $(kubectl get pod -l app=development-bitcoin -o name) -- bitcoin-cli -regtest=1 -rpcuser=test -rpcpassword=test "

invoiceName=$$
echo $($ln2cli invoice 1000 $invoiceName description)
