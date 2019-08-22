#!/bin/bash


AGENT_NAME=$1
AE_HOST=$2
AE_PORT=$3
SM_PORT=$4
AGENT_PASS=$5

FOLDER=$6

echo -e "$AGENT_PASS\n$AGENT_PASS" | sudo passwd ubuntu

# adapt agent binaries
mkdir -p $FOLDER/Agent

cd $FOLDER
tar -zxvf ./artifacts/ucxjlx6.tar.gz -C ./Agent

cp ./Agent/bin/ucxjxxx.ori.ini ./Agent/bin/ucxjlx6.ini
sed -i "s/name=UNIX01/name=$AGENT_NAME/g" ./Agent/bin/ucxjlx6.ini
sed -i "s/cp=cphost:2217/cp=$AE_HOST:$AE_PORT/g" ./Agent/bin/ucxjlx6.ini
sed -i "s/;root=START/root=START/g" ./Agent/bin/ucxjlx6.ini

# adapt service manager binaries
mkdir -p $FOLDER/SM

cd $FOLDER
tar -zxvf ./artifacts/ucsmgrlx6.tar.gz -C ./SM

cp ./SM/bin/ucybsmgr.ori.ini ./SM/bin/ucybsmgr.ini
sed -i "s/port=8871/port=$SM_PORT/g" ./SM/bin/ucybsmgr.ini

SMC_CONTENT="CREATE UC4 $AGENT_NAME"
echo $SMC_CONTENT>>./SM/bin/uc4.smc

SMD_CONTENT="DEFINE UC4 $AGENT_NAME;$FOLDER/Agent/bin/ucxjlx6;$FOLDER/Agent/bin/"
echo $SMD_CONTENT>>./SM/bin/uc4.smd



# start service manager and agent
sudo echo "#!/bin/bash">>$FOLDER/SM/bin/sm.sh
sudo echo "cd $FOLDER/SM/bin">>$FOLDER/SM/bin/sm.sh
sudo echo "./ucybsmgr -i./ucybsmgr.ini Automic">>$FOLDER/SM/bin/sm.sh
sudo chmod +x $FOLDER/SM/bin/sm.sh

sudo echo "[Unit]">>./sm.service
sudo echo "Description=Service Manager">>./sm.service

sudo echo "[Service]">>./sm.service
sudo echo "ExecStart=$FOLDER/SM/bin/sm.sh">>./sm.service

sudo echo "[Install]">>./sm.service
sudo echo "WantedBy=multi-user.target">>./sm.service

sudo chmod +x ./sm.service
sudo mv ./sm.service /etc/systemd/system


sudo systemctl daemon-reload
sudo systemctl enable sm
sudo systemctl start sm

sleep 60