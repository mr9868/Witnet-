
#WIT installed by mr9868
#Gihub: https/www.github.com/mr9868

#required dependencies
sudo command -v sudo docker >/dev/null 2>&1 || { echo >&2 "Installing docker ..."; sudo apt install docker.io docker -y; }
sudo command -v sudo jq >/dev/null 2>&1 || { echo >&2 "Installing jq ..."; sudo apt install jq -y; }
sudo command -v sudo lolcat >/dev/null 2>&1 || { echo >&2 "Installing docker ..."; sudo apt install lolcat -y; }



#Export variable
checkWitFunc=$( grep -w "witnetd" ~/.bashrc );
if [ -z $checkWitFunc ];
then

echo ' \
listCont=($( sudo docker ps -a | awk \'{print \$NF}\\' | grep witnet )); \
for i in \$( seq  0 42); \
do \
samaDgn+="="; \
buka="\${samaDgn}( OUTPUT )\${samaDgn}" \
tutup="\${samaDgn}==========\${samaDgn}" \
done \
 \
 \
witnetd(){ \
for i in \$( seq 1 \${#listCont[\@]} ); \
do \
if [ \$1 == "\${i}" ]; \
then \
cont=\${listCont[\$((i-1))]}; \
twitAddr=\$( witnetd_cli  address | grep twit | head -1 ); \
echo \$buka; \
witnetd_cli \${\@:2} \
fi \
done\
if [[ ! "\$1" =~ ^[1-9]{1}+\$ ]]; \
then \
listWitnet; \
echo \$buka; \
witnetd_cli \${@:1} \
fi \
} \

listWitnet(){ \
echo "===List Container===" \
for i in \$( seq 1 \${#listCont[\@]} ); \
do \
echo "\${i}. \${listCont[\$((i -1))]}" \
#declare cont\${i}=\${listCont[\$((i-1))]}; \
done \
read -p "Choose container : " cont \
for i in \$( seq 1 \${#listCont[\@]} ); \
do \
if [ \$cont == \${i} ]; \
then \
cont=\${listCont[\$((i-1))]}; \
twitAddr=\$( witnetd_cli  address | grep twit | head -1 ); \
fi \
done \
} \
 \
witnetd_cli(){ \
if [ \$1 == "remove" ]; \
then \
sudo docker stop \$cont && docker rm \$cont && rm -rf ~/.witnet/storage \
elif [ \$1 == "logs" ]; \
then \
sudo docker logs -f \$cont; \
else \
sudo docker exec \$cont /tmp/witnet-raw -c /tmp/testnet-1/witnet.toml node \${@:1} 2>/dev/null \
echo \$tutup \
fi \
} \
' >> ~/.bashrc
fi

listCont=($( sudo docker ps -a | awk '{print $NF}' | grep witnet ));
totalCont=${#listCont[@};

#install witnet
function witnetInstall(){
  sudo docker run -d --name witnet${totalCont}_node \
      --volume ~/.witnet:/.witnet \
      --publish 2133${totalCont}:2133${totalCont} \
      --restart always witnet/witnet-rust:2.0.0-rc.9 \
      -c /tmp/testnet-1/witnet.toml node server
}
witnetInstall
listCommand="List command :\n 1. witnetd ${totalCont} nodeStats\n \
             2. witnetd ${totalCont} balance\n \
             3. witnetd $totalCont} reputation" 
echo -e "Finished \n$listCommand ";


