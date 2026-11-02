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

### 2.2 后端 `services/leisure-api`(28 源文件 · 16 业务模块)
NestJS + Prisma + **PostgreSQL 15**/Redis:auth(JWT+用户名/手机号登录+**首登强制改密**+微信绑定+跨店工单)· artist(档案 94 字段/软删/批量/**必填项按门店配置校验**)· attendance(报备 8 枚举/汇总矩阵/补打卡/**开放时段+主管审核流**/实时 5 色)· **session(上下钟/串台/方案甲计费入房账/离线兜底/quoteIn 只读报价/艺人自助下钟)** · **stage-fee(规则/时段定价槽位/充值(五通道)/手动扣费审批/流水/冲正)** · **room(方案甲核心:房账开/关房/结算单预览/关房统一结算 ROOM_SETTLE/清扫/艺人自点单/商品目录/叫钟+语音盒子分发)** · **dispatch(轮台派单引擎:队列/推荐/模式校验/日志)** · **ticket(规则 CRUD/购买/核销/双记录/余额含过期归零)** · **showcase(投放[仅审核通过]/列表/结束)** · **booking(创建/流转/终态锁定)** · **review(评价录入/区间列表/均分分布/艺人端 my)** · store-config(艺人设置 8 项 9/9 真消费)· approval · store · taxonomy · report(8 张+双轨对账+14 天门禁)· 日切 job(汇总+对账自动快照)
**验证:tsc 干净 · prisma generate ✓ · e2e 42/42(9 套件,PG15 真库;含★用例/方案甲/P0 三线/台票/展示/预约/评价/钳位/预览/盒子/门禁/改密/设置消费面/轮台)**
**dev 联调件:`scripts/mock-voice-box.mjs`(本机回环 mock 盒子)· `scripts/apply-pg-grants.sql`(运行账号只增表收权)**

### 2.3 Web 管理端 `apps/app-leisure-web`(24 页面文件,React19+Vite8+@yyc3/ui)
A1–A20 + P0 + III 期起步 + **设计体系对齐(2026-11-02 四会话并行批)**:档案/等级组别/台费规则/**时段定价**/充值(通道下拉)/手动扣费/流水三查/报备明细汇总(含审核按钮)/上下钟/**房态看板(结算单明细预览+轮台推荐位)**/**钟房大屏(语音叫钟)**/**双轨对账(14 天门禁面板)**/**台票四 Tab(?tab= 深链)**/**展示控制台**/**预约管理**/**服务评价**/**主题定制(预设色调/语义变量/实时预览)**/**⌘K 命令面板**/门店参数(计费配置+通道清单);**token 化:20 个 --lm-* 变量单源,23 页面 216 处硬编码色收敛**

### 2.4 PWA 移动端(同工程移动形态,**离线能力完整**)
BottomNav 断点布局 + manifest/InstallPrompt + **A15 报备现场屏**(全屏二维码)
**Service Worker(public/sw.js,零依赖)**:导航网络优先→缓存壳 · /assets/* 缓存优先(hash 不可变) · /api/v1 GET 网络优先+离线回缓存+503 信封 · 写操作直连;SW no-cache 头(边缘 nginx 定向 location);更新流=controllerchange 自动重载+toast;离线横幅(useOnlineStatus)

### 2.5 艺人小程序 `apps/app-mp-artist`(Taro4+React,9 源文件)
B1 资料自助绑定 · B2 扫码签到/签退 · B4 我的流水 · **B7 我的台票(余额含有效期+购买/使用流水)**;scene HMAC 防伪
**构建:`pnpm build:h5` ✓**(2026-11-01 修复 webpackbar 5 × webpack ≥5.10x 的 ProgressPlugin 校验崩溃——config/index.ts 用 `plugin.init` 在 validate 钩子阶段做 options 垫片,不改依赖/lockfile)

### 2.6 方案甲资金闭环(2026-11-01 裁决并落地)
**时间费即台费:下钟计入房账(不落流水)→ 关房统一结算(现金/台费抵扣/混合)→ ROOM_SETTLE 流水(逐艺人,只增)**;废止原「下钟即扣 SESSION_DEDUCT」。

---

## 三、怎么跑起来(本地全套)

```bash
M=/Users/yanyu/YYC-Cube/personal/YYC3-DeepStack-Matrix
cd $M && pnpm install

# 后端(PostgreSQL 15/Redis:dev 容器映射 5434/6380;本机 5433 为生产主库勿连——2026-11-02 由 MySQL 切换)
cd services/leisure-api
docker compose -f docker-compose.dev.yml up -d postgres redis
DATABASE_URL="postgresql://leisure:leisure-dev-only@127.0.0.1:5434/leisure?schema=public" pnpm exec prisma migrate deploy
docker exec -i leisure-postgres psql -U leisure -d leisure < scripts/apply-pg-grants.sql   # 运行账号只增表收权
pnpm db:seed        # dev 含测试账号;NODE_ENV=prod 自动跳过
pnpm dev            # :3001/api/v1(Swagger: /docs)

# 测试(e2e 用测试账号;改密套件口令全部走环境变量)
pnpm --filter @yyc3/leisure-core test          # 43/43
LEISURE_E2E_PHONE=admin LEISURE_E2E_PASSWORD=123456 LEISURE_E2E_FINANCE_PHONE=china \
LEISURE_E2E_PWD_ACCOUNT=e2epwd LEISURE_E2E_PWD_DEFAULT='ChangeMe@2026' \
LEISURE_E2E_PWD_ROTATE_A='<强密码A>' LEISURE_E2E_PWD_ROTATE_B='<强密码B>' pnpm test   # 42/42(文件串行)
```
登录(账号=用户名或手机号):**测试账号 `admin / 123456`、`china / 123456`**(管理员角色,dev seed 每次重置,生产 seed 自动跳过);正式账号 13103790379 / ChangeMe@2026(**首登强制改密:改密前业务接口 40302**);财务审批人:13103790380。
**生产部署**:`services/leisure-api/deploy/nas/`(Dockerfile.prod / docker-compose.prod.yml / .env.production.example / README-NAS部署手册)。

---

## 四、验证状态(2026-11-01)

| 层 | 项 | 结果 |
|---|---|---|
| 领域包 | tsc / vitest | ✅ / ✅ 43/43 |
| 后端 | tsc / prisma generate / e2e | ✅ / ✅ / ✅ 42/42(PostgreSQL 15) |
| 安全基线 | 首登强制改密(40302)· prod 启动硬化(拒开发默认密钥/强制 CORS 白名单/Swagger 关)· PG 运行账号只增表收权 | ✅ e2e + 启动校验实测 |
| 门店设置 | 8 项 9/9 真消费:必填项校验 · 报备时段/审核流 · 艺人自助下钟 · 轮台派单引擎(40914)+ 主管轮台报表 | ✅ e2e |
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

1. **上线现场动作**(软件侧 P0 已清):`.env.production` 填真值密钥(入 ~/.yyc3-keybackup)→ 主库 `migrate deploy` + `NODE_ENV=prod seed` + grants → NAS 首次构建(`deploy/nas` 手册 §4)→ 冒烟清单 → 网关反代 + CORS 正式域名;艺人端 H5 `API_BASE` 改网关域名重构建
2. 语音盒子**真机**接线:改 `VOICE_BOX_URL` → `POST /voice-box/test`
3. 双轨对账 14 天试点运行(每日录对侧 4 数;达标后切换演练)
4. P1 续:台票抵扣并入结算 · 台票两张报表进报表中心 + xlsx · 艺人订单视图 · 评价关联房账 · 预约到店联动叫钟/锁钟;III 期:CRM · 交接班 · 提成引擎 · 推送矩阵
