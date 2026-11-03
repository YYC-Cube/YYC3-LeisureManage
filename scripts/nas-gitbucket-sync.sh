#!/bin/bash
# YYC³ LeisureManage · NAS GitBucket 全量快照同步(2026-11-03 投产稳定性)
# 用途:把整个文档仓(含 docs/My-* 私人资料)打包推送到 NAS GitBucket 私有仓
# 红线:My-* 仅入 NAS 仓;主仓 .gitignore 已挡(绝不上 GitHub)
# 依赖:环境变量 GITBUCKET_URL(如 http://100.65.172.88:8080)/GITBUCKET_USER/GITBUCKET_TOKEN(API token)
#       REPO_NAME(默认 yyc3-leisuremanage-docs;仓库需已建或脚本用 token 调 API 建)
# 用法:GITBUCKET_URL=… GITBUCKET_USER=root GITBUCKET_TOKEN=… bash nas-gitbucket-sync.sh
set -euo pipefail

SRC="$HOME/YYC-Cube/personal/YYC3-LeisureManage"
WORK="${HOME}/YYC3-Cube/nas-push/leisure-docs"
# 防误删:仅允许固定前缀路径
case "$WORK" in "$HOME/YYC3-Cube/nas-push/"*) ;; *) echo "WORK 路径非法"; exit 1;; esac
REPO_NAME="${REPO_NAME:-yyc3-leisuremanage-docs}"
URL="${GITBUCKET_URL:?需要 GITBUCKET_URL}"
USER="${GITBUCKET_USER:?需要 GITBUCKET_USER}"
TOKEN="${GITBUCKET_TOKEN:?需要 GITBUCKET_TOKEN}"

mkdir -p "$(dirname "$WORK")"
rm -rf "$WORK"
mkdir -p "$WORK"
# 全量快照(含 My-*;排除 .git 由本脚本独立维护)
rsync -a --exclude '.git' --exclude 'node_modules' "$SRC"/ "$WORK"/
cd "$WORK"
if [[ ! -d .git ]]; then
  git init -q
  git remote add origin "$URL/$USER/$REPO_NAME.git"
fi
git add -A
git -c user.name="yyc3-sync" -c user.email="sync@0379.email" commit -qm "snapshot $(date '+%F %T') (含 My- 私人资料,仅 NAS)"
# 建仓(已存在则 API 返回非 0,忽略)
curl -s -o /dev/null -X POST "$URL/api/v3/user/repos" \
  -H "Authorization: token $TOKEN" -H 'Content-Type: application/json' \
  -d "{\"name\":\"$REPO_NAME\",\"private\":true,\"description\":\"YYC3 LeisureManage docs full snapshot (private)\"}" || true
git push -q origin HEAD:main --force
echo "NAS GitBucket 同步完成: $URL/$USER/$REPO_NAME"
