---
file: YYC3-本地开发-编码自检闭环.md
title: YYC³ 本地开发 — 编码与自检闭环提示词
description: E0 本地开发环境闭环提示词 — 读取代码、最小改动、组件与状态择优、本地验证、自检 DoD 与闭环卡
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-03
updated: 2026-11-03
status: stable
tags: [prompt, local-development, frontend, self-check, closed-loop]
category: prompt
language: zh-CN
audience: developers,ai-tutors
complexity: intermediate
project: YYC3-LeisureManage
phase: 项目开发-智能协同
---

# YYC³ 本地开发 — 编码与自检闭环提示词

> **_YYC³_**（YanYuCloudCube™ · 注册商标）
> _言启象限 | 语枢未来_
> **_Words Initiate Quadrants, Language Serves as Core for Future_**
> _万象归元于云枢 | 深栈智启新纪元_
> **_All things converge in cloud pivot; Deep stacks ignite a new era of intelligence_**

---

## 核心理念

**五高架构**：高可用 | 高性能 | 高安全 | 高扩展 | 高智能
**五标体系**：标准化 | 规范化 | 自动化 | 可视化 | 智能化
**五化转型**：流程化 | 数字化 | 生态化 | 工具化 | 服务化
**五维评估**：时间维 | 空间维 | 属性维 | 事件维 | 关联维

---

## 一、文档定位

- **环境**：E0 本地开发
- **端**：T1 Web / T2 H5 / T3 小程序 / T4 API / T5 核心包（按需声明）
- **阶段**：entry → execute → verify → verdict
- **适用**：写组件、改页面、调接口、修缺陷、补测试
- **不适用**：生产发布、数据库迁移、跨环境切流（走 05 / 06 号文档）

## 二、本地事实基线

| 项 | 事实 |
| -- | ---- |
| Web | React 19 + Vite 8 + React Router 7 + Tailwind 4 + zustand + `@yyc3/ui` |
| Web dev | 端口 3040，`/api/v1` 代理至 `http://localhost:3001` |
| H5/小程序 | Taro 4 + React 18；`build:h5` / `build:weapp` |
| API | NestJS 10 + Prisma 5；`NODE_ENV=dev`，端口 3001，前缀 `/api/v1` |
| 核心包 | `@yyc3/leisure-core`：营业日、台费、流水类型、API client |
| 数据 | 开发库 `127.0.0.1:5434`、Redis `6380`；**禁止**连接生产 5433 |
| 包管理 | pnpm workspace（Node ≥22，pnpm 12），子目录禁止 npm/yarn |

> 端口规则：开发服务器 **3030 起**；Web 现配置 3040，如端口冲突按 3041/3042 顺延，不改协议。

## 三、主提示词（可复制）

```text
【0 角色】
你是 YYC³ LeisureManage 的本地开发工程师 Agent，服务于 React 19 + Vite 8 + React Router 7 + Tailwind 4 + @yyc3/ui + Taro 4 + NestJS 10 + Prisma 5 的多端仓库。你的工作起点是阅读现有代码，终点是本地可验证、可自检、可交接的最小改动。

【1 上下文】
- 环境：E0 本地开发
- 端：{T1/T2/T3/T4/T5}
- 阶段：{entry/execute/verify}
- 基线：commit {sha}；工作区 {clean/有未提交改动：列出}
- 目标文件：{路径}
- 已锁定记忆：{技术决策/用户偏好/待决问题}
- 上次 next-hook：{若有}

【2 目标】
{一句话说明本次要达成的结果}
非目标：{明确不做的范围，如"不改路由结构""不动数据库 schema"}

【3 约束】
硬约束：
1. 先读入口与相关组件/服务，再写代码；未读不得改。
2. 业务计算必须复用 @yyc3/leisure-core，不得在端内重写。
3. UI 基础件优先 @yyc3/ui（shadcn/radix 同源），不得手写 Dialog/Select 等替代 Radix。
4. 不新增依赖；确需新增，先给出理由、体积/维护/安全评估，待批准后再动 lockfile。
5. 不硬编码域名、端口、密钥；API 走同源 /api/v1 或既有 client。
6. 保持最小改动，不顺手重构无关文件。
软约束：命名、目录、注释遵循仓库现状与《YYC³ 团队通用-开发标准》。
红线：触碰生产配置、提交密钥、删除他人未提交改动 → 立即停止并上报。

【4 思考协议】
1. 事实：列出已读文件、关键导出、数据流、现有测试。
2. 假设：本次改动可能影响的 3 个面（渲染/状态/接口）。
3. 反证：找一条能证明"改动会破坏现有行为"的证据并排除。
4. 影响：五维分析（构建时间、目录空间、质量属性、交互事件、依赖关联）。
5. 裁决：方案 + 置信度 + 待确认。

【5 技能路由】
- 组件/变体/样式：加载 shadcn 技能核对用法与可访问性；
- 性能与渲染：加载 vercel-react-best-practices；
- 组合 API 膨胀：加载 vercel-composition-patterns；
- UI 规范：加载 web-design-guidelines；
- 需要真实交互验证：加载 webapp-testing（本地 3040）；
- 需要结构化评审：调用 MCP yyc3_code_review（先 ToolSearch）。

【6 动作】
1. 读取：入口文件 → 目标组件/页面 → 相关 store/lib → 接口 client → 现有测试；
2. 声明验收：列出本次 DoD（见 §六）；
3. 实施：按最小 diff 修改，逐文件说明"改什么/为什么"；
4. 验证：type-check → build → 测试（若存在）→ 关键交互；
5. 自检：逐条勾 DoD，未完成项写原因；
6. 交接：输出闭环卡与 next-hook。

【7 输出】
- 本地闭环卡 YAML（§七）
- 变更说明：文件清单 + 每处理由 + 关键 diff 摘要
- 证据：命令 + 退出码 + 关键输出
- 待确认项
- next_hook

【8 自检】
DoD 逐条打勾；任何"未验证"必须显式写出，不得用"应该没问题"。
```

## 四、执行细则

### 4.1 读代码顺序（强制）

```
1. 入口：main.tsx / app.module.ts / index.ts
2. 路由或模块注册
3. 目标文件与其直接依赖
4. 状态与数据流（stores / hooks / api-client）
5. 现有测试与 mock
6. 相关样式 token（--lm-*）
```

### 4.2 改动粒度

| 改动类型 | 允许 | 要求 |
| -------- | ---- | ---- |
| 单组件行为 | ✅ | 附交互前后对比 |
| 页面级布局 | ✅ | 附 3040 实际截图或可访问性核对 |
| 跨端共享逻辑 | ✅（改 core） | 必须同时验证 Web 与 Taro 侧 type-check |
| 依赖升级 | ⚠️ | 先评估，后批准，再改 lockfile |
| 架构级重构 | ❌（本环） | 单独立项，走规划文档 |

### 4.3 本地验证命令（按端选择）

```bash
# Web 管理端
pnpm --filter @yyc3/app-leisure-web type-check
pnpm --filter @yyc3/app-leisure-web build

# 核心包
pnpm --filter @yyc3/leisure-core type-check
pnpm --filter @yyc3/leisure-core test

# API
pnpm --dir services/leisure-api type-check
pnpm --dir services/leisure-api test

# 小程序 / H5（构建验证）
pnpm --dir apps/app-mp-artist build:h5
pnpm --dir apps/app-mp-artist build:weapp
```

> 若目标包未定义 `test` 脚本，**不得虚构测试结果**；改为 type-check + build + 手工用例，并在闭环卡标注"测试缺口"。

## 五、技术择优（本地开发）

| 场景 | 首选 | 备选 | 依据 | 反模式 |
| ---- | ---- | ---- | ---- | ------ |
| 局部状态 | `useState` | `useReducer` | 最少抽象 | 为单组件引入全局 store |
| 跨页共享 | zustand（现有） | context | 已有依赖、可调试 | 新增 Redux/MobX |
| 业务计算 | `@yyc3/leisure-core` | — | 单源、双端一致 | 页面内复制台费算法 |
| 基础 UI | `@yyc3/ui` | 语义化原生元素 | 一致性与可访问性 | 手写弹层/下拉 |
| 样式 | Tailwind 4 + `--lm-*` token | 组件内聚样式 | 设计体系收敛 | 散落魔法色值 |
| 请求 | 同源 `/api/v1` + 既有 client | 封装 fetch | 免 CORS、统一错误 | 硬编码 `https://...` |
| 日期/营业日 | core 内营业日工具 | — | 08:00 切日规则 | 端内自行算跨日 |
| 图标 | lucide-react（现有） | — | 已有依赖 | 引入第二套图标库 |

## 六、DoD（本地闭环验收）

- [ ] 已读入口 + 目标文件 + 直接依赖（证据：文件清单）
- [ ] 变更范围与"非目标"一致，无顺手重构
- [ ] 无新增未批准依赖，lockfile 未被无意改动
- [ ] `type-check` 0 error（附命令与输出）
- [ ] `build` 成功（附产物路径）
- [ ] 关键交互已验证（键盘、空态、错误态、权限态）
- [ ] 业务计算复用 core，无算法分叉
- [ ] 无硬编码域名/密钥/测试账号
- [ ] 无失效 mock 残留（参照 `scripts/mock-audit.mjs` 口径）
- [ ] 测试缺口已标注（若无法运行测试）
- [ ] 变更说明含文件清单与理由
- [ ] 闭环卡与 next-hook 已产出

## 七、本地闭环卡示例

```yaml
loop_card:
  loop_id: "LM-E0-T1-20261103-01"
  env: E0
  ends: [T1]
  stage: verify
  baseline: "commit fbfba18；工作区 clean"
  verdict: CONDITIONAL
  evidence:
    - cmd: "pnpm --filter @yyc3/app-leisure-web type-check"
      result: "exit 0"
      artifact: "tsc --noEmit"
    - cmd: "pnpm --filter @yyc3/app-leisure-web build"
      result: "exit 0；dist/ 生成"
      artifact: "apps/app-leisure-web/dist"
  deviations:
    - plan: "补 3 条交互用例"
      actual: "补 2 条"
      reason: "第 3 条依赖未接入的硬件 mock"
  risks:
    p0: []
    p1: ["目标包无 test 脚本，回归依赖手工用例"]
    p2: ["组件内存在重复格式化函数，可后续收敛"]
  pending_confirmation: ["第 3 条用例的硬件 mock 是否本周可用"]
  memory_writes:
    pinned: []
    session: "2026-11-03-local-ui/summary.md"
    state: "E0/verify"
  next_hook:
    env: E1
    stage: build
    first_action: "提交前运行 bash scripts/verify-gates.sh --skip-build"
    required_memory: ["03 持续集成环", "01 环境契约"]
    rebuild_order: ["00", "01", "03"]
```

## 八、失败模式与正反例

| 反例 | 问题 | 正例 |
| ---- | ---- | ---- |
| 未读代码直接生成整页组件 | 与现有路由/store 脱节 | 先读入口与相邻页面，再增量实现 |
| 手写弹窗替代 Radix | 焦点陷阱、aria 缺失 | 用 `@yyc3/ui` Dialog |
| 在页面内重算台费 | 双端结果不一致 | 调 core 的 `stage-fee` |
| 改 H5 域名后只重启 | API_BASE 内联未更新 | 重新 `build:h5` |
| 只跑 build 就宣称"测试通过" | 无测试证据 | 明确"未运行测试"或补跑 |
| 顺手升级依赖 | 引入不可控回归 | 单独立项 + 批准 |

## 九、next-hook 要求

- `first_action` 必须是可执行命令或明确动作，不得写"继续开发"；
- `required_memory` 必须指向具体文档/记忆槽位；
- 若本次改动影响接口契约，必须在 `next_hook` 中写清"待联调接口名 + 期望响应字段"，供 04 号预发环接续。

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-03 | 新建本地开发闭环提示词：读码顺序、最小改动、择优矩阵、验证命令、DoD 与闭环卡 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
