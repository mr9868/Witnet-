userSource=~/.bashrc;
#MR9868
#WIT installed by mr9868
#Gihub: https/www.github.com/mr9868

#required dependencies
command -v sudo docker >/dev/null 2>&1 || { echo >&2 "Installing docker ..."; sudo apt install docker.io docker -y; }
command -v sudo jq >/dev/null 2>&1 || { echo >&2 "Installing jq ..."; sudo apt install jq -y; }
command -v sudo lolcat >/dev/null 2>&1 || { echo >&2 "Installing docker ..."; sudo apt install lolcat -y; }



#Export variable
checkWitFunc=$( grep -w "witnetd" $userSource );
if [ -z $checkWitFunc ];
then
    echo "
listCont=(\$( command sudo docker ps -a | awk '{print \$NF}'| grep witnet ));
for i in \$( seq  0 30);
do
samaDgn+=\"=\";
buka=\"\${samaDgn}( OUTPUT )\${samaDgn}\"
tutup=\"\${samaDgn}==========\${samaDgn}\"
done

listWitnet(){
echo \"===List Container===\" 
for i in \$( seq 1 \${#listCont[@]} );
do
echo \"\${i}. \${listCont[\$((i -1))]}\"
#declare cont\${i}=\${listCont[\$((i-1))]};
done
read -p \"Choose container : \" cont
for i in \$( seq 1 \${#listCont[@]} );
do
if [ \$cont == \${i} ];
then
cont=\${listCont[\$((i-1))]};
twitAddr=\$( witnetd_cli  address | grep twit | head -1 );
fi
done
}
witnetd(){
for i in \$( seq 1 \${#listCont[@]} );
do
if [ \$1 == \"\${i}\" ];
then
cont=\${listCont[\$((i-1))]};
twitAddr=\$( witnetd_cli  address | grep twit | head -1 );
echo \$buka;
witnetd_cli \${@:2}
fi
done
if [[ ! \"\$1\" =~ ^[1-9]{1}+\$ ]];
then
listWitnet;
echo \$buka;
witnetd_cli \${@:1}
fi
}
witnetd_cli(){
if [ \$1 == \"remove\" ];
then
command sudo docker stop \$cont && command sudo docker rm \$cont && rm -rf ~/.witnet/storage
elif [ \$1 == \"logs\" ];
then
command sudo docker logs -f \$cont;
else
command sudo docker exec \$cont /tmp/witnet-raw -c /tmp/testnet-1/witnet.toml node \${@:1} 2>/dev/null
echo \$tutup
fi
}
" >> $userSource
fi
listCont=($( command sudo docker ps -a | awk '{print $NF}' | grep witnet ));
totalCont=${#listCont[@]};

#install witnet
function witnetInstall(){
command sudo docker run -d --name witnet${totalCont}_node \
      --volume ~/.witnet:/.witnet \
      --publish $((21337 + $totalCont )):$(( 21337 + $totalCont )) \
      --restart always witnet/witnet-rust:2.0.0-rc.9 \
      -c /tmp/testnet-1/witnet.toml node server
}
witnetInstall
listCommand="List command :\n 1. witnetd ${totalCont} nodeStats\n2. witnetd ${totalCont} balance\n3. witnetd ${totalCont} reputation" 
echo -e "Finished ✓\n${listCommand} ";


