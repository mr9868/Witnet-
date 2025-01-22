userSource=~/.bashrc;
cp ~/.bashrc ~/.bashrc_backup;
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

function headDgn(){
for i in \$( seq  0 30);
do
samaDgn+=\"=\";
bukaDgn=\"\${samaDgn}( OUTPUT )\${samaDgn}\"
tutupDgn=\"\${samaDgn}==========\${samaDgn}\"
done
if [ \$1 == \"buka\" ];
then
echo \$bukaDgn;
elif [ \$1 == \"tutup\" ];
then
echo \$tutupDgn;
fi
unset samaDgn;
}

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
if [ \${#listCont[@]} -eq 0 ];
then
echo \"No witnet container name found !\";
fi
for i in \$( seq 1 \${#listCont[@]} );
do
if [ \$1 == \"\${i}\" ];
then
cont=\${listCont[\$((i-1))]};
twitAddr=\$( witnetd_cli  address | grep twit | head -1 );
headDgn buka;
witnetd_cli \${@:2}
fi
done
if [[ ! \"\$1\" =~ ^[1-9]{1}+\$ ]];
then
listWitnet;
headDgn buka;
witnetd_cli \${@:1}
fi
}
witnetd_cli(){
if [ \$1 == \"remove\" ];
then
command sudo docker stop \$cont;
echo \" Successfully stop \${cont}\";
command sudo docker rm \$cont;
echo \" Successfully remove \${cont}\";
sudo rm -rf ~/.witnet/storage
headDgn tutup;
source $userSource
elif [ \$1 == \"logs\" ];
then
command sudo docker logs -f \$cont;
headDgn tutup;
else
command sudo docker exec \$cont /tmp/witnet-raw -c /tmp/testnet-1/witnet.toml node \${@:1} 2>/dev/null
headDgn tutup;
source $userSource;
fi
}
" >> $userSource
fi
listCont=($( command sudo docker ps -a | awk '{print $NF}' | grep witnet ));
totalCont=${#listCont[@]};

#install witnet
function witnetInstall(){
command sudo docker run --name witnet${totalCont}_node --runtime runc \
   -v /root/.witnet:/witnet \
   -p $(( 21337 + ${totalCont} )):$(( 21337 + ${totalCont} ))/tcp \
   --restart always -h ac7785ebf70a \
   --expose $(( 11212 + ${totalCont} ))/tcp \
   --expose $(( 21337 + ${totalCont} ))/tcp \
   --expose $(( 21338 + ${totalCont} ))/tcp \
   -l org.opencontainers.image.ref.name='ubuntu' \
   -l org.opencontainers.image.version='22.04' \
   -e 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
   -e 'RUST_BACKTRACE=full' \
   -d --entrypoint "./runner.sh" witnet/witnet-rust:2.0.0-rc.9 \
   '-c' '/tmp/testnet-1/witnet.toml' 'node' 'server' 
   }

witnetInstall
listCommand="You must run 'exec bash'\nList command :\n1. witnetd $(( 1+ totalCont )) nodeStats\n2. witnetd $(( 1 + totalCont )) balance\n3. witnetd $(( 1+ totalCont )) reputation" 
echo -e "Finished ✓\n${listCommand} ";
source $userSource;


