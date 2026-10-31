#!/usr/bin/env bash
# ============================================================
# YYC³ LeisureManage · 文档门禁(本地与 CI 同源执行)
# G1 社区四件套 + README 在位
# G2 品牌顶图在位
# G3 Front Matter 必填(治理类文档 + 主文档)
# G4 Markdown 相对链接可达(无死链)
# G5 主文档品牌署名块抽检
# ============================================================
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf 'FAIL: \033[31m✗ %s\033[0m\n' "$1"; fail=1; }

echo "== G1 社区四件套与 README =="
for f in LICENSE CODE_OF_CONDUCT.md CONTRIBUTING.md SECURITY.md README.md; do
  if [ -f "$f" ]; then ok "$f"; else bad "缺失 $f"; fi
done

echo "== G2 品牌视觉资产 =="
if [ -f "public/yyc3-family.png" ]; then ok "public/yyc3-family.png"; else bad "顶图缺失 public/yyc3-family.png"; fi

echo "== G3 Front Matter 必填 =="
FM_TARGETS="CODE_OF_CONDUCT.md CONTRIBUTING.md SECURITY.md docs/YYC3-LeisureManage-可视化交互体系设计.md docs/YYC3-LeisureManage-项目规划/YYC3-LeisureManage.md"
for f in $FM_TARGETS; do
  if [ ! -f "$f" ]; then bad "文件不存在: $f"; continue; fi
  if [ "$(head -c 3 "$f")" = "---" ]; then ok "FM $f"; else bad "Front Matter 缺失: $f"; fi
done

echo "== G4 相对链接可达 =="
LINK_FILES=$(find . -name '*.md' -not -path './.git/*' -not -path './node_modules/*' -not -path './docs/YYC3-团队通用-标准规范/*')
for file in $LINK_FILES; do
  dir=$(dirname "$file")
  # 提取 md 相对链接(排除 http/锚点/图片外链),逐个核对在位
  links=$(grep -oE '\]\([^)#]+\.(md|png)' "$file" 2>/dev/null | sed -E 's/^\]\(//' | sort -u || true)
  for link in $links; do
    case "$link" in
      http*) continue ;;
      *) if [ -f "$dir/$link" ]; then :; else bad "死链: $file -> $link"; fi ;;
    esac
  done
done
ok "链接检查完成(死链以 FAIL 行列出)"

echo "== G5 主文档品牌署名块 =="
MAIN_DOC="docs/YYC3-LeisureManage-项目规划/YYC3-LeisureManage.md"
if grep -q "言启象限 | 语枢未来" "$MAIN_DOC" 2>/dev/null; then ok "署名块在位($MAIN_DOC)"; else bad "署名块缺失: $MAIN_DOC"; fi

echo "----------------------------------------"
if [ "$fail" -eq 0 ]; then
  printf '\033[32m文档门禁:全绿 ✅\033[0m\n'
  exit 0
else
  printf '\033[31m文档门禁:存在 FAIL 项,禁止合并 ❌\033[0m\n'
  exit 1
fi
