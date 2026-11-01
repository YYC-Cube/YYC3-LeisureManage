# YYC3-LeisureManage · 项目交付总览(SUMMARY)

> 更新:2026-11-01|状态:**MVP 全量 + 方案甲闭环 + P0 回补 + II 期(台票/展示/预约/计费配置/结算单预览/语音盒子联动层/14 天门禁)落地,全量测试绿;双轨试点进入运行期**
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

### 2.1 领域单源包 `@yyc3/leisure-core`(9 源文件)
四端一致性锚点:营业日(08:00 日切)· 台费引擎(等级×房型规则快照 + 进位阈值 + **最低消费/封顶钳位**)· 时段定价槽位解析 · 上钟前置校验 · 台票校验(余额/有效期/购买金额)· **语音盒子传输(HttpVoiceBoxTransport,私网白名单)** · 全部枚举(报备 8 型/流水 4 型/收费通道 5+1/实时 5 色点)· 传输层注入式 API Client(含 tickets/showcase/bookings/storeConfig/recon/voiceBox/billPreview)
**验证:tsc 严格模式干净 + vitest 43/43**

### 2.2 后端 `services/leisure-api`(25 源文件 · 14 业务模块)
NestJS + Prisma + MySQL/Redis:auth(JWT+微信绑定+跨店工单)· artist(档案 94 字段/软删/批量)· attendance(报备 8 枚举/汇总矩阵/补打卡)· **session(上下钟/串台/方案甲计费入房账/离线兜底)** · **stage-fee(规则/时段定价槽位/充值(五通道)/手动扣费审批/流水/冲正)** · **room(方案甲核心:房账开/关房/关房统一结算 ROOM_SETTLE/清扫/艺人自点单/商品目录/叫钟)** · **ticket(规则 CRUD/购买/核销/双记录/余额)** · **showcase(投放/列表/结束/批量结束)** · **booking(创建/流转/终态锁定)** · store-config(艺人设置 8 项+计费配置后台可编辑)· approval · store · taxonomy · report(7 张 MVP+双轨对账)· 日切 job
**验证:tsc 干净 · prisma generate ✓ · e2e 31/31(含★用例/方案甲/P0 三线/台票/展示/预约/最低消费钳位)**

### 2.3 Web 管理端 `apps/app-leisure-web`(23 页面文件,React19+Vite8+@yyc3/ui)
A1–A20 + P0 落地:档案/等级组别/台费规则/**时段定价**/充值(通道下拉)/手动扣费/流水三查/报备明细汇总/上下钟/**房态看板(方案甲开关房+结算单明细预览:时间费逐场次实时报价+点单+余额,MIXED 现金+抵扣)**/**钟房大屏(语音叫钟)**/**双轨对账(14 天门禁面板)**/**台票四 Tab**/**展示控制台**/**预约管理**/**门店参数(含计费配置:最低消费/封顶/收费通道清单编辑)**

### 2.4 PWA 移动端(同工程移动形态)
BottomNav 断点布局 + manifest/InstallPrompt + **A15 报备现场屏**(全屏二维码)

### 2.5 艺人小程序 `apps/app-mp-artist`(Taro4+React,9 源文件)
B1 资料自助绑定 · B2 扫码签到/签退 · B4 我的流水 · **B7 我的台票(余额含有效期+购买/使用流水)**;scene HMAC 防伪

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
pnpm --filter @yyc3/leisure-core test          # 43/43
LEISURE_E2E_PHONE=13103790379 LEISURE_E2E_PASSWORD='ChangeMe@2026' \
LEISURE_E2E_FINANCE_PHONE=13103790380 pnpm exec vitest run --no-file-parallelism   # 34/34
```
登录:13103790379 / ChangeMe@2026(**首登必改**);财务审批人:13103790380。

---

## 四、验证状态(2026-11-01)

| 层 | 项 | 结果 |
|---|---|---|
| 领域包 | tsc / vitest | ✅ / ✅ 43/43 |
| 后端 | tsc / prisma generate / e2e | ✅ / ✅ / ✅ 34/34 |
| 方案甲 | 下钟不落流水基线 · ROOM_SETTLE 逐艺人 · 余额扣减一致 · 重复关房拒绝 · 超限 40910 | ✅ 全部有断言 |
| 闭环链 | 充值(五通道)→开房(进房即上钟)→自点单→**结算单预览(与真结算同额)**→关房 FEE_DEDUCT→ROOM_SETTLE→清扫→空闲 | ✅ e2e 全链 |
| P0 三线 | 钟房大屏语音叫钟 · 时段定价槽位覆盖 · 离线兜底幂等重放 · 双轨对账 MATCHED | ✅ e2e |
| II 期计费 | 最低消费兜底 / 封顶压值 / 后台可编辑(预设 0)· 收费通道 现金/转账/自定义1-3 清单校验 | ✅ e2e(40911 余额/通道清单拒) |
| 台票/展示/预约 | 台票购买核销双记录 · 展示投放去重 · 预约流转终态锁定 40913 | ✅ e2e |
| 语音盒子联动 | 传输层私网白名单/超时不抛(单测 7)· 未配置 skipped 不阻断(e2e) | ✅;真机联调待盒子接口 |
| 14 天门禁 | 日切自动快照 PENDING_LEGACY · history 14 格/streak/gatePassed(e2e) | ✅ 试点运行期 |

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

1. 语音盒子真机联调(确认店内盒子型号/HTTP 接口 → 配 `VOICE_BOX_URL` 模板 → `POST /voice-box/test` 验证)
2. 双轨对账 14 天试点运行(日切已自动快照;每日仅录对侧 4 数,门禁面板盯 streak)
3. 小程序台票页真机回归(Taro build:h5/微信工具);服务评价/CRM 等 III 期
4. 双轨达标后切换演练(对侧只读、本系统唯一记账源)
