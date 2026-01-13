# Antigravity Tools 服务器部署

> 无需改动源码，使用 Xvfb 在 Linux 服务器上运行 GUI 应用

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/lbjlaq/Antigravity-Manager/main/deploy/install.sh | sudo bash
```

或者（更安全，先审查脚本）：

```bash
curl -O https://raw.githubusercontent.com/lbjlaq/Antigravity-Manager/main/deploy/install.sh
cat install.sh  # 审查脚本
sudo bash install.sh
```

## 目录结构

安装后在 `/opt/antigravity/` 下：

```
antigravity/
├── antigravity.AppImage          # 主程序
├── .antigravity_tools/           # 数据目录
│   ├── accounts/
│   │   └── {uuid}.json
│   ├── accounts.json
│   └── gui_config.json
├── logs/
│   └── app.log
├── .version                      # 当前版本号
├── install.sh                    # 部署脚本
├── sync.sh                       # 账号同步
└── upgrade.sh                    # 升级脚本
```

## 同步本地账号

在本地 Mac/Linux 执行：

```bash
# 下载同步脚本
curl -O https://raw.githubusercontent.com/lbjlaq/Antigravity-Manager/main/deploy/sync.sh
chmod +x sync.sh

# 同步到服务器
./sync.sh root@your-server /opt/antigravity
```

## 升级

```bash
cd /opt/antigravity
sudo ./upgrade.sh
```

## 运维命令

```bash
systemctl status antigravity          # 查看状态
systemctl restart antigravity         # 重启服务
systemctl stop antigravity            # 停止服务
tail -f /opt/antigravity/logs/app.log # 查看日志
curl localhost:8045/healthz           # 健康检查
```

## 备份与迁移

```bash
# 备份整个目录
tar czf antigravity-backup.tar.gz /opt/antigravity

# 恢复到新服务器
tar xzf antigravity-backup.tar.gz -C /opt
cd /opt/antigravity && sudo ./install.sh
```

## 技术原理

- **Xvfb**: 虚拟显示器，让 GUI 程序在无显示器环境运行
- **HOME 重定向**: `HOME=$PWD` 使程序在当前目录创建 `.antigravity_tools/`，实现便携部署

## 系统要求

- Ubuntu 20.04+ / Debian 11+ / RHEL 8+ / CentOS Stream 8+
- 自动安装依赖：xvfb, libwebkit2gtk, libgtk-3, wget, curl, jq
