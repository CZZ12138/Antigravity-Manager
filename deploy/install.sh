#!/usr/bin/env bash
set -euo pipefail

# 权限检查
[[ $EUID -eq 0 ]] || { echo "错误: 需要 root 权限，请使用 sudo"; exit 1; }

# 如果通过 pipe 执行，创建目录并进入
if [[ ! -f "$0" ]] || [[ "$0" == "bash" ]]; then
    mkdir -p /opt/antigravity && cd /opt/antigravity
else
    cd "$(dirname "$0")"
fi

REPO="lbjlaq/Antigravity-Manager"

echo "[1/4] 安装依赖..."
if command -v apt-get &>/dev/null; then
    apt-get update -qq
    apt-get install -y -qq xvfb libharfbuzz0b libwebkit2gtk-4.1-0 libgtk-3-0 wget curl jq
elif command -v dnf &>/dev/null; then
    dnf install -y -q xorg-x11-server-Xvfb harfbuzz webkit2gtk4.1 gtk3 wget curl jq
elif command -v yum &>/dev/null; then
    yum install -y -q xorg-x11-server-Xvfb harfbuzz webkit2gtk3 gtk3 wget curl jq
else
    echo "错误: 不支持的包管理器，请手动安装: xvfb, libwebkit2gtk, libgtk-3, wget, curl, jq"
    exit 1
fi

echo "[2/4] 下载程序..."
VERSION=$(curl -sfS "https://api.github.com/repos/${REPO}/releases/latest" | jq -r '.tag_name // empty' | sed 's/^v//')
[[ -n "$VERSION" ]] || { echo "错误: 无法获取版本号，可能是 GitHub API 限流"; exit 1; }

wget -q --show-progress -O antigravity.AppImage \
    "https://github.com/${REPO}/releases/latest/download/Antigravity.Tools_${VERSION}_amd64.AppImage"
chmod +x antigravity.AppImage
echo "$VERSION" > .version

echo "[3/4] 初始化目录..."
mkdir -p .antigravity_tools/accounts logs
[[ -f .antigravity_tools/gui_config.json ]] || \
    echo '{"proxy":{"enabled":true,"auto_start":true,"port":8045}}' > .antigravity_tools/gui_config.json

echo "[4/4] 安装服务..."
cat > /etc/systemd/system/antigravity.service << EOF
[Unit]
Description=Antigravity Tools
After=network.target

[Service]
Type=simple
WorkingDirectory=$(pwd)
Environment="HOME=$(pwd)"
ExecStart=/usr/bin/xvfb-run -a $(pwd)/antigravity.AppImage
Restart=always
StandardOutput=append:$(pwd)/logs/app.log
StandardError=append:$(pwd)/logs/app.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable antigravity
systemctl start antigravity

sleep 3
if systemctl is-active --quiet antigravity; then
    echo "部署完成！版本 v${VERSION}，端口 8045"
else
    echo "启动失败，查看 logs/app.log"
    exit 1
fi
