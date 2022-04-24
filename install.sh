#!/bin/bash
printf "\033c"

mcsmanager_install_path="/opt/mcsm3"
node_install_path="/opt/node-v14.17.6-linux-x64"

Red_Error() {
  echo '================================================='
  printf '\033[1;31;40m%b\033[0m\n' "$@"
  echo '================================================='
  exit 1
}

Install_MCSManager() {

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

  echo "[↓] git clone mcsmanager/MCSManager-Web-Production.git"
  git clone https://github.com/DreamStart-Team/MCSManager-Web-ChineseTraditional.git

  echo "[-] mv MCSManager-Web-Production web"
  mv MCSManager-Web-Production web

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
}

Create_Service() {

  echo "[x] Initialize the service file"
  rm -f /etc/systemd/system/mcsm3-daemon.service
  rm -f /etc/systemd/system/mcsm3-web.service

  echo "[+] cat >>/etc/systemd/system/mcsm3-daemon.service"
  cat >>/etc/systemd/system/mcsm3-daemon.service <<'EOF'
[Unit]
Description=MCSManager Daemon

[Service]
WorkingDirectory=/opt/mcsm3/daemon
ExecStart=/usr/bin/node app.js
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID

[Install]
WantedBy=multi-user.target
EOF

  echo "[+] cat >>/etc/systemd/system/mcsm3-web.service"
  cat >>/etc/systemd/system/mcsm3-web.service <<'EOF'
[Unit]
Description=MCSManager Web

[Service]
WorkingDirectory=/opt/mcsm3/web
ExecStart=/usr/bin/node app.js
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID

[Install]
WantedBy=multi-user.target
EOF

  echo "[-] systemctl daemon-reload"
  systemctl daemon-reload

  echo "[+] systemctl enable mcsm3-daemon.service --now"
  systemctl enable mcsm3-daemon.service --now

  sleep 4

  echo "[+] systemctl enable mcsm3-web.service --now"
  systemctl enable mcsm3-web.service --now

  sleep 4

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
  echo "systemctl restart mcsm-{daemon,web}.service"
  echo "systemctl disable mcsm-{daemon,web}.service"
  echo "systemctl enable mcsm-{daemon,web}.service"
  echo "systemctl start mcsm-{daemon,web}.service"
  echo "systemctl stop mcsm-{daemon,web}.service"
  echo "=================================================================="

}

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
| Shell Install Script by Nuomiaa
+----------------------------------------------------------------------
"

echo "[+] Installing dependent software... (git,tar)"
yum install -y git tar
apt install -y git tar
pacman -Syu --noconfirm git tar

Install_Node
Install_MCSManager
Create_Service
