# Witnet-Installer ( Docker );
Witnet testnet party

> [!IMPORTANT]
> ## Install witnet docker container:
> 
> *Warning ! Do this for first time only, you must export your private key to continue run the node. See export masterKey sesion below !*
> ```
> cd;
> git clone https://github.com/mr9868/witnet;
> cd witnet;
> chmod +x wit_installer.sh;
> exec bash;
> ```
> 
> ## Run daily transaction witnet:
> ```
> cd ~/witnet;
> chmod +x tx.sh
> ./tx.sh;
> ```
> ## Import witnet node :
> ```
> cd ~/witnet;
> chmod +x import_node.sh
> ./import_node.sh;
> exec bash;
> ```



> [!TIP]
> ## *Another transaction*
>
> Get auth token :
> ```
>  exec bash; witnetd authorizeStake --withdrawer Your_address
>  ```
> Staking :
>  ```
> exec bash; witnetd stake --authorization Auth_token --validator Validator_address --withdrawer Withdraw_address --fee 2 --require_confirmation false
>  ```
> Add Peers :
>  ```
> exec bash; witnetd addPeers 52.166.178.145:21337 52.166.178.145:22337
>   ```
> Join transaction :
>  ```
> exec bash; witnetd joinTransaction --address Receipant_address --value=100 --fee=1
>  ```
> Join transaction with split :
>  ```
> exec bash; witnetd joinTransaction --address Receipant_address --size=3 --value=100 --fee=1
>  ```
> Send transaction :
>  ```
>  exec bash; witnetd send --address Receipant_address --value=17 --fee=1
>  ```
> Export masterKey :
> ```
> exec bash; witnetd masterKeyExport
> ```
>
Done, that's it !
