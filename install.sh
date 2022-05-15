#!/bin/bash
printf "\033c"

mcsmanager_install_path="/opt/mcsmtw"
node_install_path="/opt/node-v14.17.6-linux-x64"

# ----------------- Program start ----------------- 

# rm -f "$0"

if [ $(whoami) != "root" ]; then
  Red_Error "[x] Please use Root!"
fi

is64bit=$(getconf LONG_BIT)
if [ "${is64bit}" != '64' ]; then
  Red_Error "[x] Please use 64-bit system!"
fi


echo "+----------------------------------------------------------------------
| MCSManager Installer
+----------------------------------------------------------------------
| Copyright © 2021 Suwings All rights reserved.
+----------------------------------------------------------------------
| Shell Install Script by IceBrick
+----------------------------------------------------------------------
"

echo "[+] Installing dependent software... (git,tar)"
yum install -y git tar
apt install -y git tar
pacman -Syu --noconfirm git tar

echo "[x] Delete the original MCSManager"
rm -irf ${mcsmanager_install_path}

echo "[+] mkdir -p ${mcsmanager_install_path}"
mkdir -p ${mcsmanager_install_path} || exit

echo "[→] cd ${mcsmanager_install_path}"
cd ${mcsmanager_install_path} || exit

echo "[↓] git clone MCSManager/MCSManager-Daemon-Production.git"
git clone https://gitee.com/mcsmanager/MCSManager-Daemon-Production.git

echo "[-] mv MCSManager-Daemon-Production daemon"
mv MCSManager-Daemon-Production daemon

echo "[→] cd daemon"
cd daemon || exit

echo "[+] npm install --registry=https://registry.npm.taobao.org"
npm install --registry=https://registry.npm.taobao.org

echo "[←] cd .."
cd ..

echo "[↓] git clone DreamStart-Team/MCSManager-Web-zhtw9.4.4.git"
git clone https://github.com/DreamStart-Team/MCSManager-Web-zhtw9.4.4.git

echo "[-] mv MCSManager-Web-zhtw9.4.4 web"
mv MCSManager-Web-zhtw9.4.4 web

echo "[→] cd web"
cd web || exit

echo "[+] npm install --registry=https://registry.npm.taobao.org"
npm install --registry=https://registry.npm.taobao.org

echo "=============== MCSManager ==============="
echo " Daemon: ${mcsmanager_install_path}/daemon"
echo " Web: ${mcsmanager_install_path}/web"
echo "=============== MCSManager ==============="
echo
echo ""
echo -e "\033[1;32m[ok] MCSManager installed successfully!!!\033[0m"
echo "[ok] Location: ${mcsmanager_install_path}"
echo
sleep 3

echo "[x] Initialize the service file"
rm -f /etc/systemd/system/mcsmtw-daemon.service
rm -f /etc/systemd/system/mcsmtw-web.service

echo "[+] cat >>/etc/systemd/system/mcsmtw-daemon.service"
cat >>/etc/systemd/system/mcsmtw-daemon.service <<'EOF'
[Unit]
Description=MCSManager Daemon

[Service]
WorkingDirectory=/opt/mcsmtw/daemon
ExecStart=/usr/bin/node app.js
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID

[Install]
WantedBy=multi-user.target
EOF

echo "[+] cat >>/etc/systemd/system/mcsmtw-web.service"
cat >>/etc/systemd/system/mcsmtw-web.service <<'EOF'
[Unit]
Description=MCSManager Web

[Service]
WorkingDirectory=/opt/mcsmtw/web
ExecStart=/usr/bin/node app.js
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID

[Install]
WantedBy=multi-user.target
EOF

echo "[-] systemctl daemon-reload"
systemctl daemon-reload

echo "[+] systemctl enable mcsmtw-daemon.service --now"
systemctl enable mcsmtw-daemon.service --now

sleep 4

echo "[+] systemctl enable mcsmtw-web.service --now"
systemctl enable mcsmtw-web.service --now

sleep 4
  
echo "[↓] 下載 MCSManager Client..."
rm -f /opt/mcsmtw.sh
wget -P /opt https://raw.githubusercontent.com/IceBrick01/MCSManager-Client/main/mcsmtw.sh
chmod -R 755 /opt/mcsmtw.sh

echo "[+] 安裝 MCSManager Client..."
rm -f /usr/local/bin/mcsmtw
ln -s /opt/mcsmtw.sh /usr/local/bin/mcsmtw

echo "=================================================================="
echo -e "\033[1;32mMCSManager TW Client - 安裝成功\033[0m"
echo "=================================================================="
echo "您可以在命令行使用 \"mcsmtw\" 呼出 MCSManager TW Client"
  
echo "=================================================================="
echo -e "\033[1;32mWelcome to MCSManager (WEB)\033[0m"
echo "=================================================================="
echo "Web Service Address:    http://localhost:23333"
echo "Daemon Service Address: http://localhost:24444"
echo "Username: root"
echo "Password: 123456"
echo -e "\033[33mEnglish: You must expose ports 23333 and 24444 to use the service properly on the Internet.\033[0m"
echo -e "\033[33mChinese: 安装且启动完毕，您必须开放 23333 与 24444 端口来确保面板的正常使用。\033[0m"
echo ""
echo "=================================================================="
echo "systemctl restart mcsmtw-{daemon,web}.service"
echo "systemctl disable mcsmtw-{daemon,web}.service"
echo "systemctl enable mcsmtw-{daemon,web}.service"
echo "systemctl start mcsmtw-{daemon,web}.service"
echo "systemctl stop mcsmtw-{daemon,web}.service"
echo "=================================================================="
