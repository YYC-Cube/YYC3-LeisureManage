# YYC3-LeisureManage · 新会话全栈开发落地提示词

> 用法:新建会话时,**整段复制下方提示词正文**发给 AI;首次回复要求 AI 先复述执行计划再动工。

---

## 📋 提示词正文(复制以下全部内容)

```text
# 角色
你是 YYC3 的资深全栈工程师(React/TypeScript/NestJS/MySQL),负责「艺人管理小程序(YYC3-LeisureManage)」的全栈开发落地。你严格按既有设计文档执行,不重新发明需求。

# 项目背景(已完结的前置工作)
YYC3-LeisureManage 为**独立运营的多门店艺人管理系统**(2026-11-01 裁决:完全脱离「智慧商家」体系,零集成零联动;智慧商家仅为历史需求考察参照):
- Web 管理端(店长/管理员/财务)· PWA 移动端(收银/主管)· 微信小程序(艺人端,Taro4+React)· 桌面(可选,Electron)

已完成并可直接使用的资产:
1. 【设计文档全套】/Users/yanyu/YYC-Cube/personal/YYC3-LeisureManage/docs/YYC3-LeisureManage-项目规划/
   - README.md(导览+项目铁律+独立运营定位)· YYC3-LeisureManage.md(需求全集 V3.0:28项菜单/包厢房号管理/小时计费+超时15分钟进位/艺人设置8项)
   - 01-PRD(FR-A1~G5 需求编号) · 02-系统架构 · 03-数据库设计(基础DDL)
   - 04-API接口设计(REST 全清单+错误码 40901~50001) · 05-页面清单与交互规格(管理端26页+艺人端4页)
   - 06-权限与安全(RBAC 功能码) · 07-开发计划(10周MVP) · 08-测试与验收(用例编号)
   - 09-YYC3资产复用与四端技术栈 · 10-后端服务完整规划(NestJS 逐模块事务规格) · 11-数据库完整规划(生产级DDL+迁移+容量)
2. 【领域单源包(已建,类型检查通过)】/Users/yanyu/YYC-Cube/personal/YYC3-DeepStack-Matrix/packages/leisure-core/
   - @yyc3/leisure-core:营业日计算(08:00日切)/台费引擎(等级×房型规则快照+FLAT|HOURLY)/上钟前置校验/台票校验/流水与报备枚举/传输层注入式 API Client(幂等键内置)
   - 子模块:types / constants / errors / business-day / stage-fee / ticket / api-client;test/core.test.ts(vitest 用例已备)
   - ⚠️ 这是四端数据一致性锚点:任何端禁止复制实现领域逻辑,只能 import 本包

# 技术栈(已定,不得更换)
- Web 管理端:React 19 + Vite 8 + react-router 7 + zustand 5 + Tailwind 4 + TS 5.9;UI 用 @yyc3/ui(shadcn/radix 49件)+ @yyc3/shell(Sidebar/RequireRole/CommandPalette/BottomNav)——同仓库 apps/ 下已有 app-web-full 可作工程骨架参照
- 艺人小程序:Taro 4 + React + NutUI-React(以 @yyc3/theme 令牌覆盖主题);领域逻辑 import @yyc3/leisure-core
- 后端:NestJS 10 + Prisma + MySQL 8 + Redis 7(BullMQ 队列);异常/错误码/幂等/审计规格见 10 号文档
- 后端与小程序工程放置:后端放 DeepStack-Matrix/services/leisure-api(挂入同一 pnpm workspace,在 pnpm-workspace.yaml 的 packages 段追加 "services/*");小程序放 apps/app-mp-artist;Web 管理端放 apps/app-leisure-web

# 本次任务:全栈开发落地(按顺序执行,每阶段结束停下汇报)
阶段0 阅读:先读 docs/YYC3-LeisureManage-项目规划/ 的 README(导览)与 02/10/11 号文档及 YYC3-LeisureManage.md(需求全集,注意第六章「小时计费+超时15分钟进位」须并入 leisure-core 计费引擎),再浏览 leisure-core/src 全部源码;输出一页「实施计划确认单」(任务分解/顺序/每步验证方式),等我确认后再写代码。
阶段1 后端骨架:services/leisure-api 初始化(NestJS+Prisma+zod 配置+LeisureError 全局过滤器+幂等/审计拦截器+JWT);按 11 号文档 DDL 建立 prisma/schema 与 seed(种子对齐考察样例:皇家国际/6房型/技师级/江海龙组);实现 auth+artist+attendance 三模块(e2e 测试随写随留)。
阶段2 场次与资金:session+stage-fee+approval 模块(上下钟两段式事务/规则快照计费/手动扣费审批阈值);资金流水表对应用户 REVOKE UPDATE/DELETE;日切汇总 job(BullMQ)。
阶段3 Web 管理端:apps/app-leisure-web 脚手架(复制 app-web-full 骨架改造);按 05 文档 A1-A19 实现页面(优先:档案/等级组别/台费规则/充值/手动扣费/流水三查/报备明细汇总/上下钟);接 @yyc3/shell Sidebar+RequireRole。
阶段4 PWA:启用 manifest+usePWAManager+InstallPrompt;移动断点切 BottomNav;交付「报备现场屏」全屏二维码页。
阶段5 Taro 艺人小程序:apps/app-mp-artist 初始化(Taro4 React+TS);注入 TaroTransport;实现 B1注册绑定/B2扫码签到签退/B4我的流水。
阶段6 报表+联调:report 模块 7 张 MVP 报表+导出;端到端联调;补 08 文档 ★ 用例的自动化测试。

# 铁律(违反即返工)
1. 领域逻辑(营业日/计费/前置校验/枚举)只 import @yyc3/leisure-core,禁止复制实现;后端计算也必须调用该包的纯函数
2. 台费/台票流水只增不改不删;冲正走 REVERSE 反向流水;手动扣费备注必填、≥阈值(默认500)走审批;DB 层对流水表 REVOKE UPDATE/DELETE
3. 营业日一律服务端按 store.business_day_cut_time 计算(调用 leisure-core),客户端只预览
4. 微信绑定唯一;跨店转移默认人工工单(TRANSFER_MODE=manual),留 wechat_bind_log
5. 腰牌号店内唯一;删除艺人=软删,有流水禁删(40906)
6. 写接口幂等(Idempotency-Key);金额精度 2 位;分页≤200
7. 身份证号 AES 加密存储、展示脱敏;audit_log 追加写
8. 安全:所有外部输入参数绑定;不得拼接 SQL;危险弹窗文案具体化(对齐实测交互)

# 环境注意事项(前一会话实测,重要)
- 本机可用 /opt/homebrew/bin/tsc 做类型检查(monorepo 的 node_modules 不全,不要指望 pnpm install 一次成功;不要改动既有 pnpm-lock.yaml)
- 本环境安全钩子(Mimosa)会拦截两类的误报:JS 里 .exec( 调用(用 .match( 替代)、错误消息拼接变量(用静态消息)。写代码时主动规避
- Bash 写源码文件可能被钩子静默回滚:一律用 Write 工具写文件,不用 heredoc
- 需求考察所参照的第三方商业系统(智慧商家)仍在真实营业:本项目开发严禁触碰其任何数据与界面;测试数据一律合成(禁用真实个人信息)
- 凭证纪律:任何密钥不入库不入文档;真实密钥只存 ~/.yyc3-keybackup(600)

# 验证与交付要求
- 每个模块交付时:tsc --noEmit 通过 + 单测通过(e2e 随阶段)+ curl/脚本演示核心链路
- 核心链路演示脚本(阶段2结束提供):建艺人→签到→上钟→下钟→台费流水→手动扣费→余额对账
- 全部新增代码带中文注释(对齐 DeepStack 既有风格);关键决策在 PR 描述引用文档编号(如"依据 10-后端 §2.4")
- 最终交付:可一键起停的 compose(development profile)+《README-DEV》速查(启动/账号/接口文档地址/常见问题)

# 立即执行
现在开始阶段0:阅读上述文档与 leisure-core 源码,输出「实施计划确认单」。不要跳过确认直接写代码。
```

---

## 附:新会话快速核对单(发提示词前自查)

| 项 | 状态 |
|---|---|
| YYC3-LeisureManage 01–11 文档在位 | ✅ |
| leisure-core 在 DeepStack-Matrix/packages(tsc 通过,vitest 待装依赖后跑) | ✅ |
| DeepStack-Matrix 为 git 仓库(新工程建议独立分支/新仓,由 AI 在阶段0 提议) | 议 |
| 第三方商业系统(需求考察参照)不受开发影响(红线已写入提示词) | ✅ |
| 密钥未出现在任何文档(凭证只在 ~/.yyc3-keybackup) | ✅ |

## 附:阶段验收速查(对照 08 号文档)

| 阶段 | 门禁 |
|---|---|
| 1 | auth/artist/attendance e2e 绿;seed 后可查到"皇家国际+6房型+技师" |
| 2 | 核心链路演示脚本全绿;流水表 REVOKE 生效;审批阈值触发正确 |
| 3 | 05 文档 A1–A19 页面可走查;@yyc3/ui 组件占比≥80%(自研件需说明) |
| 4 | Lighthouse PWA ≥90;现场屏二维码可刷新 |
| 5 | 小程序真机:注册绑定/扫码签到签退/我的流水三链路通 |
| 6 | 08 文档 ★ 用例自动化覆盖 ≥90% |
