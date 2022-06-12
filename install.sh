#!/bin/bash
printf "\033c"

# wget -N https://shell.ea0.cn/install_MCSManager.sh ; sudo bash install_MCSManager.sh

# 刪除自己
rm -f "$0"

# 環境檢查
Red_Error() {
  echo '================================================='
  printf '\033[1;31;40m%b\033[0m\n' "$@"
  exit 1
}

if [ $(whoami) != "root" ]; then
  Red_Error "[x] 請使用 root 權限執行 MCSManager 安裝命令！"
fi

is64bit=$(getconf LONG_BIT)
if [ "${is64bit}" != '64' ]; then
  Red_Error "[x] 當前面板版本不支持 32位 系統, 請使用 64位 系統！"
fi



# 開始安裝
echo "+----------------------------------------------------------------------
| MCSManager TW FOR CentOS/Ubuntu/Debian
+----------------------------------------------------------------------
| Copyright © 2017-2021 Suwings(MCSManager.com) All rights reserved.
+----------------------------------------------------------------------
| Shell Install Script by 冰磚(IceBrick)
+----------------------------------------------------------------------
"
while [ "$go" != 'y' ] && [ "$go" != 'n' ]
do
	read -r -p "[-] 現在要安裝 MCSManager TW 到 \"/opt/mcsmtw\" 目錄嗎？(y/n): " go;
done

if [ "$go" == 'n' ];then
	exit;
fi



# 定義 MCSManager 安裝目錄
mcsmanager_install_path="/opt/mcsmtw"

# 定義 Node 安裝目錄
node_install_path="/opt/node-v14.17.6-linux-x64"



if [ -d $mcsmanager_install_path ];then
  printf "\033c"
	echo -e "----------------------------------------------------"
  echo -e "檢查到已有 MCSManager TW 面版安裝在 \"$mcsmanager_install_path\""
  echo -e "繼續安裝會刪除原有 MCSManager TW 面版的所有數據！"
  echo -e "----------------------------------------------------"
  echo ""
  read -r -p "[-] 確認已瞭解以上內容，我確定已備份完成 (輸入yes繼續安裝): " yes;

  if [ "$yes" != "yes" ];then
  	echo -e "------------"
  	echo "取消安裝"
  	exit;
  fi
fi



if (systemctl -q is-active mcsm-daemon.service || systemctl -q is-active mcsm-web.service); then
  echo "[-] MCSManager TW 服務正在運行，停止服務..."
  systemctl stop mcsmtw-{daemon,web}.service
  systemctl disable mcsmtw-{daemon,web}.service
  echo
fi



Install_Node() {
  printf "\033c"

  echo "[x] 刪除原有 Node 環境"
  rm -irf ${node_install_path}

  echo "[→] 進入 Node 安裝目錄"
  cd /opt || exit

  echo "[↓] 下載 Node v14.17.6 壓縮包..."
  wget https://nodejs.org/download/release/v14.17.6/node-v14.17.6-linux-x64.tar.gz

  echo "[↑] 解壓 node-v14.17.6-linux-x64.tar.gz"
  tar -zxf node-v14.17.6-linux-x64.tar.gz

  echo "[x] 刪除 node-v14.17.6-linux-x64.tar.gz"
  rm -rf node-v14.17.6-linux-x64.tar.gz

  echo "[x] 刪除原有 Node 鏈接"
  rm -f /usr/bin/npm
  rm -f /usr/bin/node
  rm -f /usr/local/bin/npm
  rm -f /usr/local/bin/node

  echo "[+] 創建 Node 鏈接"
  ln -s ${node_install_path}/bin/npm /usr/bin/
  ln -s ${node_install_path}/bin/node /usr/bin/
  ln -s ${node_install_path}/bin/npm /usr/local/bin/
  ln -s ${node_install_path}/bin/node /usr/local/bin/

  printf "\033c"
  echo "=============== Node Version ==============="
  echo " node: $(node -v)"
  echo " npm: $(npm -v)"
  echo "=============== Node Version ==============="
  echo
  echo "[-] Node 安裝完成，即將開始安裝 MCSManager TW..."
  echo
  sleep 3
}

Install_MCSManager() {
  printf "\033c"

  echo "[x] 刪除原有 MCSManager TW"
  rm -irf ${mcsmanager_install_path}

  echo "[+] 創建 MCSManager TW 安裝目錄"
  mkdir -p ${mcsmanager_install_path} || exit

  echo "[→] 進入 MCSManager TW 安裝目錄"
  cd ${mcsmanager_install_path} || exit

  echo "[↓] 下載 MCSManager CN 守護進程..."
  git clone https://github.com/MCSManager/MCSManager-Daemon-Production.git

  echo "[-] 重命名 Daemon -> daemon"
  mv Daemon daemon

  echo "[→] 進入 MCSManager-Daemon 目錄"
  cd daemon || exit

  echo "[+] 安裝 npm 依賴庫..."
  npm install

  echo "[←] 退出 MCSManager-Daemon 目錄"
  cd ..

  echo "[↓] 下載 MCSManager TW 網頁服務..."
  git clone https://github.com/DreamStart-Team/MCSManager-Web-Production-tw9.4.5.git

  echo "[-] 重命名 Web -> web"
  mv Web web

  echo "[→] 進入 MCSManager-Web 目錄"
  cd web || exit

  echo "[+] 安裝 npm 依賴庫..."
  npm install

  printf "\033c"
  echo "=============== MCSManager TW ==============="
  echo " Daemon(守護進程): ${mcsmanager_install_path}/daemon"
  echo " Web(網頁服務): ${mcsmanager_install_path}/web"
  echo "=============== MCSManager TW ==============="
  echo
  echo "[-] MCSManager TW 安裝完成，即將開始創建 MCSManager TW 系統服務..."
  echo
  sleep 3
}

Create_Service() {
  printf "\033c"

  echo "[x] 刪除 MCSManager TW 服務"
  rm -f /etc/systemd/system/mcsmtw-daemon.service
  rm -f /etc/systemd/system/mcsmtw-web.service

  echo "[+] 創建 MCSManager-Daemon 服務"
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

  echo "[+] 創建 MCSManager-Web 服務"
  cat >>/etc/systemd/system/mcsm-web.service <<'EOF'
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

  echo "[-] 重載服務配置文件"
  systemctl daemon-reload

  echo "[+] 啟用 MCSManager-Daemon 服務"
  systemctl enable mcsmtw-daemon.service --now

  echo "[+] 啟用 MCSManager-Web 服務"
  systemctl enable mcsmtw-web.service --now

  echo "[↓] 下載 MCSManager-命令行..."
  rm -f /opt/mcsm.sh
  wget -P /opt https://raw.githubusercontent.com/IceBrick01/MCSManager-Client/main/mcsm.sh
  chmod -R 755 /opt/mcsm.sh

  echo "[+] 創建 MCSManager-命令行 鏈接"
  rm -f /usr/local/bin/mcsmtw
  ln -s /opt/mcsm.sh /usr/local/bin/mcsmtw

  echo "[-] 正在檢查服務..."

  sleep 5

  printf "\033c"
  if (systemctl -q is-active mcsmtw-daemon.service && systemctl -q is-active mcsmtw-web.service); then
    getIpAddress=$(curl -sS --connect-timeout 10 -m 60 https://shell.ea0.cn/api/getIpAddress)
    LOCAL_IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

    echo "=================================================================="
    echo -e "\033[1;32mMCSManager TW- 恭喜，安裝成功！\033[0m"
    echo "=================================================================="
    echo "網頁服務地址-內網: http://${LOCAL_IP}:23333"
    echo "守護進程地址-內網: http://${LOCAL_IP}:24444"
    echo "網頁服務地址: http://${getIpAddress}:23333"
    echo "守護進程地址: http://${getIpAddress}:24444"
    echo "默認賬號: root"
    echo "默認密碼: 123456"
    echo -e "\033[33m若無法訪問面板，請檢查防火牆/安全組是否有放行面板[23333/24444]埠\033[0m"
    #echo "=================================================================="
    #echo "重啟服務: systemctl restart mcsmtw-{daemon,web}.service"
    #echo "禁用服務: systemctl disable mcsmtw-{daemon,web}.service"
    #echo "啟用服務: systemctl enable mcsmtw-{daemon,web}.service"
    #echo "啟動服務: systemctl start mcsmtw-{daemon,web}.service"
    #echo "停止服務: systemctl stop mcsmtw-{daemon,web}.service"
    echo "=================================================================="
    echo "您可以在命令行使用 \"mcsmtw\" 呼出 MCSManager-命令行"
  else
    Red_Error "[x] 服務啟動失敗"
  fi
}



printf "\033c"
echo "[+] 安裝 git tar 包..."
yum install -y git tar
apt install -y git tar
pacman -Syu --noconfirm git tar

# 安裝
Install_Node
Install_MCSManager
Create_Service
