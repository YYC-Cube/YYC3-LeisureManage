# YYC3-LeisureManage · 项目交付总览(SUMMARY)

> 更新:2026-11-01|状态:**MVP 全量落地 + 方案甲资金闭环 + 全量测试绿**
> 本文档回答三个问题:交付了什么 · 代码在哪里 · 怎么跑起来

---

## 一、这个仓库 vs 代码仓库(双仓结构)

| 仓库 | 路径 | 职责 |
|---|---|---|
| **本仓库**(文档站) | `personal/YYC3-LeisureManage` | 需求全集 V3.0 · 工程 01–14 号文档 · 构建指导 · Pages 部署 · 审核报告 |
| **代码仓**(monorepo) | `personal/YYC3-DeepStack-Matrix` | **全部可运行代码**:领域单源包 + 后端 + Web + PWA + 小程序 |

> 代码不放本仓库是**有意裁决**:工程与运行态集中在 DeepStack-Matrix monorepo(pnpm workspace 统一依赖/构建/测试);本仓库承载需求与规划(What),对方承载实现(How)。`code/` 目录提供机器本地软链导航(见 §五)。

---

## 二、交付了什么(全部已落地并验证)

### 2.1 领域单源包 `@yyc3/leisure-core`(8 源文件)
四端一致性锚点:营业日(08:00 日切)· 台费引擎(等级×房型规则快照 + 进位阈值)· 上钟前置校验 · 台票校验 · 全部枚举(报备 8 型/流水 4 型/实时 5 色点)· 传输层注入式 API Client
**验证:tsc 严格模式干净 + vitest 25/25**

### 2.2 后端 `services/leisure-api`(20 源文件 · 11 业务模块)
NestJS + Prisma + MySQL/Redis:auth(JWT+微信绑定+跨店工单)· artist(档案 94 字段/软删/批量)· attendance(报备 8 枚举/汇总矩阵/补打卡)· **session(上下钟/串台/方案甲计费入房账)** · **stage-fee(规则/充值/手动扣费审批/流水)** · **room(方案甲核心:房账开/关房/关房统一结算 ROOM_SETTLE/清扫/艺人自点单/商品目录)** · approval · store · taxonomy · report(7 张 MVP)· 日切 job
**验证:tsc 干净 · prisma generate ✓ · e2e 24/24(含★用例与方案甲断言)**

### 2.3 Web 管理端 `apps/app-leisure-web`(14 页面文件,React19+Vite8+@yyc3/ui)
A1–A20 落地:档案/等级组别/台费规则/充值/手动扣费/流水三查/报备明细汇总/上下钟/看板等

### 2.4 PWA 移动端(同工程移动形态)
BottomNav 断点布局 + manifest/InstallPrompt + **A15 报备现场屏**(全屏二维码)

### 2.5 艺人小程序 `apps/app-mp-artist`(Taro4+React,7 源文件)
B1 资料自助绑定 · B2 扫码签到/签退 · B4 我的流水;scene HMAC 防伪

### 2.6 方案甲资金闭环(2026-11-01 裁决并落地)
**时间费即台费:下钟计入房账(不落流水)→ 关房统一结算(现金/台费抵扣/混合)→ ROOM_SETTLE 流水(逐艺人,只增)**;废止原「下钟即扣 SESSION_DEDUCT」。

---

## 三、怎么跑起来(本地全套)

```bash
M=/Users/yanyu/YYC-Cube/personal/YYC3-DeepStack-Matrix
cd $M && pnpm install

# 后端(MySQL/Redis 起在 3307,见 services/leisure-api/docker-compose.dev.yml)
cd services/leisure-api
docker compose -f docker-compose.dev.yml up -d
DATABASE_URL="mysql://root:root-dev-only@127.0.0.1:3307/leisure" pnpm exec prisma migrate deploy
pnpm db:seed
pnpm dev            # :3001/api/v1(Swagger: /docs)

# 测试
pnpm --filter @yyc3/leisure-core test          # 25/25
LEISURE_E2E_PHONE=13103790379 LEISURE_E2E_PASSWORD='ChangeMe@2026' \
LEISURE_E2E_FINANCE_PHONE=13103790380 pnpm exec vitest run --no-file-parallelism   # 24/24
```
登录:13103790379 / ChangeMe@2026(**首登必改**);财务审批人:13103790380。

---

## 四、验证状态(2026-11-01)

| 层 | 项 | 结果 |
|---|---|---|
| 领域包 | tsc / vitest | ✅ / ✅ 25/25 |
| 后端 | tsc / prisma generate / e2e | ✅ / ✅ / ✅ 24/24 |
| 方案甲 | 下钟不落流水基线 · ROOM_SETTLE 逐艺人 · 余额扣减一致 · 重复关房拒绝 · 超限 40910 | ✅ 全部有断言 |
| 闭环链 | 充值→开房(进房即上钟)→自点单→关房 FEE_DEDUCT→ROOM_SETTLE→清扫→空闲 | ✅ e2e 全链 |

---

## 五、代码导航(`code/` 软链,机器本地有效)

```
code/leisure-core  → ../../YYC3-DeepStack-Matrix/packages/leisure-core
code/leisure-api   → ../../YYC3-DeepStack-Matrix/services/leisure-api
code/web           → ../../YYC3-DeepStack-Matrix/apps/app-leisure-web
code/mp-artist     → ../../YYC3-DeepStack-Matrix/apps/app-mp-artist
```
**真源纪律**:代码只在 DeepStack-Matrix 仓库提交;本目录软链仅供浏览,勿在此改代码。

---

## 六、文档地图(本仓库)

- `docs/YYC3-LeisureManage-项目规划/`:00 需求全集 V3.0(+审核报告)· 01–11 工程文档 · **12–14 构建指导(房态/自点单/融合互通)** · PROMPT
- `docs/YYC3-团队通用-标准规范/`:多端适配规范 · 验收系统
- `YYC3-LeisureManage-可视化交互体系设计.md`:品牌/徽章/Mermaid 图集

---

## 七、下一步(优先级)

1. 房账前端页(看板开关房按钮 + 关房结算单 UI 对接新后端)
2. P0 缺失回补(钟房大屏语音叫钟 / 时段差异化定价 / 上钟离线兜底)——见需求全集 §12
3. 双轨对账试点(与实测系统并行 14 天零差异后切换)
