listCont=($( docker ps -a | awk '{print $NF}' | grep witnet ));
listWitnet(){
echo "===List Container==="                                                                                                          
for i in $( seq 1 ${#listCont[@]} );
do
listTwitAddr=$( docker exec ${listCont[$((i-1))]} /tmp/witnet-raw -c /tmp/testnet-1/witnet.toml node address 2>&1 ) 2>/dev/null ;
listTwitAddr=$( echo "$listTwitAddr" 2>/dev/null | grep "jsonrpc" | sed -s "s/.*{\"jsonrpc\"/{\"jsonrpc\"/g" | jq -r .result );
echo "${i}. ${listCont[$((i -1))]} ( ${listTwitAddr} )"
#declare cont${i}=${listCont[$((i-1))]};
done
read -p "Choose container : " contNum
for i in $( seq 1 ${#listCont[@]} );
do
if [ $contNum == ${i} ];
then
cont=${listCont[$((i-1))]};
fi
done
totalCont=${#listCont[@]};
if [[ ! $contNum =~ ^[1-$totalCont]{1}$ ]];
then
echo "Docker container doesn't exist !";
exit 1;
fi 
}

witnetd(){
docker exec $cont /tmp/witnet-raw -c /tmp/testnet-1/witnet.toml node "$@"
}
if [ ! -d "logs" ];
then
	mkdir logs;
fi


myHeader(){
clear
figlet "Mr9868"
echo "Witnet Daily Transaction" | lolcat
echo "------------------------"
}

recQn(){
myHeader;
listWitnet;
myTwitAddr=$( witnetd address 2>/dev/null | grep twit | head -1 );
read -p "Please provide recipient witnet address: " witAddr
#witAddr=twit1w5n5v0mu8erpdf9uj32ekke07kgggpxcvg8v5r
until [[ $witAddr =~ ^twit([0-9a-zA-Z]){39}$ ]];
do
	myHeader;
	echo "Address must be started with 'twit' and total 43 long characters !"
	read -p "Please provide witnet address: " witAddr
done
}

recQn;
read -p "Your recipient address '${witAddr}' are you sure ? (y/n): " twitQn;
if [ $twitQn == "y" ] || [ $twitQn == "Y" ];
then
	echo "The is variable configured ✓"
	echo "Please wait ..."
	sleep 2
else
	recQn;
fi

varStart(){
randTime=1
totalOkTx=0
totalErrTx=0
totalTx=0
totalBatch=0
}

varStart;

newHeader(){
myHeader;
echo
echo "Your witnet address: ${myTwitAddr}"
echo "You recipient witnet address: ${witAddr}"
echo "[INFO] Starting process transaction batch ${totalBatch} ..."
echo
echo "============================================================================================"
sleep 3;
}

sumTx(){
#	echo  " Total tx success: ${totalOkTx}" > logs/recap.log;
#	echo  " Total tx error: ${totalErrTx}" >> logs/recap.log;
#	echo  "______________________________+" >> logs/recap.log;
#	echo -e " Total tx: ${totalTx}\n\nTotal tx batch: ${totalBatch}\n" >> logs/recap.log;

	echo "[RESULT] Total tx success: ${totalOkTx}" 
	echo "[RESULT] Total tx error: ${totalErrTx}"
	echo "______________________________+" 
        echo "[RESULT] Total tx: ${totalTx}" 
	echo
}

decVar(){
	randAmount=${RANDOM:0:2}
	randSplit=$(echo $(( 1 + ${RANDOM} % 5)))
	randTime=$(echo $(( 15 + ${RANDOM} % 20)))
	randFee=$(echo $(( 1 + ${RANDOM} % 4)))
	dateLog=$( date '+[%A, %d-%m-%Y][%H:%M:%S]' );
}


result(){
decVar;
if [ $txProc == "join" ];
then
	joinTxErr=$( echo $joinTx  | grep -c "Error" );
	joinErrDec=$( echo $joinTx  | sed "s/.*\message: \"//g" | sed "s/\" }//g" );
	if [ $joinTxErr -ne 0 ];
	then
	echo "  [ERROR] Join transaction is failed, Please wait for several times !"
	echo -e "  [DETAIL] Message output: ${joinErrDec}"
	totalErrTx=$(( totalErrTx + 1 ));
	echo "[ERROR]${dateLog}[TX][JOIN] ${joinErrDec}" >> logs/error.log;
	else
	echo "  [INFO] Transaction success ✓"
	joinTxOk=$( echo "$joinTx"  | grep "jsonrpc" | jq -r  .result.body.outputs[0] );
	totalOkTx=$(( totalOkTx + 1 ));
	joinTo=$( echo $joinTxOk | jq -r .pkh );
	joinVal=$( echo $joinTxOk | jq -r .value );
	joinTime=$( echo $joinTxOk | jq -r .time_lock );
	joinLog=$( echo "Successful ${txProc} transaction from ${myTwitAddr} to ${joinTo} amount ${joinVal} uWit, time lock ${joinTime}");
	echo -e "  [DETAIL] Message output: ${joinLog}"
	echo "[SUCCESS]${dateLog}[TX][JOIN] ${joinLog}" >> logs/success.log;
	fi
unset txProc
elif [ $txProc == "joinSplit" ]
then
#	echo ,$joinTxSplit
	joinTxSplitErr=$( echo $joinTxSplit 2>&1 | grep -c "Error" );
	joinSplitErrDec=$( echo $joinTxSplit 2>&1 | sed "s/.*\message: \"//g" | sed "s/\" }//g" );
	if [ $joinTxSplitErr -ne 0 ];
	then
	echo "  [ERROR] Join split transaction is failed, Please wait for several times !"
	echo -e "  [DETAIL] Message output: ${joinSplitErrDec}"
	totalErrTx=$(( totalErrTx + 1 ));
	echo "[ERROR]${dateLog}[TX][JOINSPLIT] ${joinSplitErrDec}" >> logs/error.log;
	else
	echo "  [INFO] Transaction success ✓"
	joinTxSplitOk=$( echo "$joinTxSplit" 2>&1 | grep "jsonrpc" |  jq -r .result.body.outputs[0] );
        joinTxSplitOk2=$( echo "$joinTxSplit" 2>&1 | grep "jsonrpc" |  jq -r .result.body.outputs | grep -c twit  );
#	joinTxSplitOk3=$( echo "$joinTxSplitOk" | jq ' . + { "totalOkTx": '$(( joinTxSplitOk2 - 1 ))' }' );
	joinSplitSize=$(( joinTxSplitOk2 -1 ));
	joinSplitTo=$( echo $joinTxSplitOk | jq -r .pkh );
        joinSplitVal=$( echo $joinTxSplitOk | jq -r .value );
        joinSplitTime=$( echo $joinTxSplitOk | jq -r .time_lock );
        joinSplitLog=$( echo "Successful ${txProc} transaction from ${myTwitAddr} to ${joinSplitTo} amount ${joinSplitVal} uWit splitSize ${joinSplitSize}, time lock ${joinSplitTime}" );
	echo -e "  [DETAIL] Message output: ${joinSplitLog}"
	totalOkTx=$(( totalOkTx + 1 ));
	echo "[SUCCESS]${dateLog}[TX][JOINSPLIT] ${joinSplitLog}" >> logs/success.log;
	fi
unset txProc
elif [ $txProc == "send" ];
then
	sendTxErr=$( echo $sendTx 2>&1 | grep -c "Error" );
	sendErrDec=$( echo $sendTx 2>&1 | sed "s/.*\message: \"//g" | sed "s/\" }//g" );
	if [ $sendTxErr -ne 0 ];
	then
	echo "  [ERROR] Send transaction is failed, Please wait for several times ! !"
	echo -e "  [DETAIL] Message output: ${sendErrDec}}"
	totalErrTx=$(( totalErrTx + 1 ));
	echo "[ERROR]${dateLog}[TX][SEND] ${sendErrDec}" >> logs/error.log;
	else
	echo "  [INFO] Transaction success ✓"
	sendTxOk=$( echo "$sendTx" 2>&1 | grep "jsonrpc" | jq -r  .result.body.outputs[0] );
	sendTo=$( echo $sendTxOk | jq -r .pkh );
        sendVal=$( echo $sendTxOk | jq -r .value );
        sendTime=$( echo $sendTxOk | jq -r .time_lock );
        sendLog=$( echo "Successful ${txProc} transaction from ${myTwitAddr} to ${sendTo} amount ${sendVal} uWit, time lock ${sendTime}");
	echo -e "  [DETAIL] Message output: ${sendLog}"
	totalOkTx=$(( totalOkTx + 1 ));
	echo "[SUCCESS]${dateLog}[TX][SEND] ${sendLog}" >> logs/success.log;
	fi
unset txProc
fi
totalTx=$(( totalTx + 1 ));
echo "  [RESULT] Total transaction: ${totalTx}";
echo
echo " ]";
if [ $totalTx -ne 3 ];
then
echo "  [INFO]  Wait for the next transaction ...";
sleep $randSplit
else
echo "  [INFO] finished transaction batch 1"
fi
}

while sleep $randTime;
do
decVar;
totalBatch=$(( totalBatch +1 ));
newHeader;

txProc="join"
txId=1;
echo
echo " ["
echo
echo "  [JOB] Execute join tx ${randAmount} WIT to ${witAddr} with fee ${randFee} ..." 
joinTx=$( witnetd joinTransaction --address $witAddr --value=$randAmount --fee=$randFee 2>&1 );
result

txProc="joinSplit"
txId=2
echo " ["
echo
echo "  [JOB] Execute join tx split size ${randSplit} amount ${randAmount} WIT to ${witAddr} with fee ${randFee} ..." 
joinTxSplit=$( witnetd joinTransaction --address $witAddr --size=$randSplit --value=$randAmount --fee=$randFee 2>&1 );
result

txProc="send"
txId=3
echo " ["
echo
echo "  [JOB] Execute send tx ${randAmount} WIT to ${witAddr} with fee ${randFee} ..."
sendTx=$( witnetd send --address $witAddr --value=$randAmount --fee=$randFee 2>&1 ) \
result;
echo
echo "============================================================================================"
echo
sumTx;
#echo "[RESULT] Total tx batch: ${totalBatch}"
echo "[INFO] Sleep for ${randTime} second ..."
echo "[INFO] Waiting for the next batch transaction ..."
sleep $randTime
done


