listCont=($( docker ps -a | awk '{print $NF}' | grep witnet ));
totalCont=${#listCont[@};

#install witnet
function witnetInstall(){

   docker run --name witnet${totalCont}_node --runtime runc \
   -v /root/.witnet:/witnet \
   -v /root/.witnet/config/privKey${totalCont}.txt:/witnet/privKey${totalCont}.txt \
   -p $(( 21337 + ${totalCont} )):$(( 21337 + ${totalCont} ))/tcp \
   --restart always -h ac7785ebf70a \
   --expose $(( 11212 + ${totalCont} ))/tcp \
   --expose $(( 21337 + ${totalCont} ))/tcp \
   --expose $(( 21338 + ${totalCont} ))/tcp \
   -l org.opencontainers.image.ref.name='ubuntu' \
   -l org.opencontainers.image.version='22.04' \
   -e 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
   -e 'RUST_BACKTRACE=full' \
   -d --entrypoint "./runner.sh" witnet/witnet-rust:2.0.0-rc.9 '-c' '/tmp/testnet-1/witnet.toml' 'node' 'server' '--master-key-import' '/witnet/privKey${totalCont}.txt'
}
