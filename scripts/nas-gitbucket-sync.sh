#!/bin/bash
# YYC³ LeisureManage · NAS GitBucket 全量快照同步(2026-11-03 投产稳定性;2026-11-04 改密码 auth)
# 用途:把整个文档仓(含 docs/My-* 私人资料)打包推送到 NAS GitBucket 私有仓
# 红线:My-* 仅入 NAS 仓;主仓 .gitignore 已挡(绝不上 GitHub)
# 依赖(环境变量,凭据不入本脚本/不入仓):
#   GITBUCKET_URL(**标准=Tailscale http://100.65.172.88:8080**;2026-11-05 baseUrl 已置空双链通吃,LAN 192.168.3.45:8080 亦可)/ GITBUCKET_USER(如 root)/ GITBUCKET_PASSWORD
#   REPO_NAME(默认 YYC3-Leisuremanage;需已在 GitBucket 网页建仓)
# 用法:GITBUCKET_URL=… GITBUCKET_USER=root GITBUCKET_PASSWORD=… bash nas-gitbucket-sync.sh
set -euo pipefail

SRC="$HOME/YYC-Cube/personal/YYC3-LeisureManage"
WORK="${HOME}/YYC3-Cube/nas-push/leisure-docs"
# 防误删:仅允许固定前缀路径
case "$WORK" in "$HOME/YYC3-Cube/nas-push/"*) ;; *) echo "WORK 路径非法"; exit 1;; esac
REPO_NAME="${REPO_NAME:-YYC3-Leisuremanage}"
URL="${GITBUCKET_URL:?需要 GITBUCKET_URL}"
USER="${GITBUCKET_USER:?需要 GITBUCKET_USER}"
PASS="${GITBUCKET_PASSWORD:?需要 GITBUCKET_PASSWORD}"

mkdir -p "$(dirname "$WORK")"
rm -rf "$WORK"
mkdir -p "$WORK"
# 全量快照(含 My-*;排除主仓 .git 与 node_modules)
rsync -a --exclude '.git' --exclude 'node_modules' "$SRC"/ "$WORK"/
cd "$WORK"
if [[ ! -d .git ]]; then
  git init -q -b main
fi
git add -A
# My-* 被主仓 .gitignore 挡住:快照仓必须强制包含(私有备份语义)
git add -f docs/My-* 2>/dev/null || true
git -c user.name="yyc3-sync" -c user.email="sync@0379.email" commit -qm "snapshot $(date '+%F %T') (全量含 My- 私人资料,仅 NAS)"
# push:凭据内联单次命令(不写 .git/config;仓库已在网页预建)
git push -q --force "http://$USER:$PASS@${URL#http://}/$USER/$REPO_NAME.git" HEAD:main
echo "NAS GitBucket 同步完成: $URL/$USER/$REPO_NAME"
