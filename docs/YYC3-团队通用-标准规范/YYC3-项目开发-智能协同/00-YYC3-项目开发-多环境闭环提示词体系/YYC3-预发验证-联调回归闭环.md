---
file: YYC3-预发验证-联调回归闭环.md
title: YYC³ 预发验证 — 联调与回归闭环提示词
description: E2 预发联调环境闭环提示词 — 跨端联调矩阵、接口契约核对、主链路回归、缺陷分级与发布放行裁决
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-03
updated: 2026-11-03
status: stable
tags: [prompt, staging, integration, regression, closed-loop]
category: prompt
language: zh-CN
audience: developers,qa-engineers,devops,ai-tutors
complexity: intermediate
project: YYC3-LeisureManage
phase: 项目开发-智能协同
---

# YYC³ 预发验证 — 联调与回归闭环提示词

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

- **环境**：E2 预发联调
- **端**：T1 Web / T2 H5 / T3 小程序 / T4 API / T5 核心包（至少覆盖受影响的端）
- **阶段**：entry → verify → verdict
- **适用**：前后端联调、跨端回归、切流前验证、发布前最后一关
- **不适用**：生产发布执行（05）、线上事故处置（06）

> **放行原则**：预发环是生产的最后一道闸门。**没有预发证据，不得进入生产发布。**

## 二、预发事实基线

| 项 | 事实 |
| -- | ---- |
| 主 API | Mac `:3002`（frp 8802） |
| 备 API | NAS `:3001`（frp 8801） |
| 边缘 | ECS nginx；`/api/v1/` upstream 指向 8802（默认） |
| 静态 | Web `web/`、H5 `h5/` 目录；发布前可指向预发副本 |
| 域名 | `lm.0379.world` / `lm.0379.pro`（生产域名；预发可复用或独立） |
| 鉴权 | JWT access 2h / refresh 7d；生产 Swagger 默认关闭 |
| 数据 | 预发库或只读副本；**禁止**直连生产主库做联调 |
| H5 | `TARO_APP_API_BASE` 编译期内联，改域名必须重建 |
| 业务错误码 | 已知示例：40905 签退时限、40910 自点单限额（以代码与接口文档为准） |

## 三、联调矩阵（按端 × 链路）

| 链路 | Web | H5 | 小程序 | API | 必测点 |
| ---- | --- | -- | ------ | --- | ------ |
| 登录/鉴权 | ✅ | ✅ | ✅ | ✅ | 401/403、过期刷新、禁用账号 |
| 营业日与设置 | ✅ | — | — | ✅ | 08:00 切日、设置覆盖业务规则 |
| 开房/上钟 | ✅ | ✅ | ✅ | ✅ | 状态机、并发、权限 |
| 台费/计费 | ✅ | ✅ | — | ✅ | 进位阈值、负余额策略、core 一致性 |
| 自点单 | ✅ | ✅ | ✅ | ✅ | 限额 40910、库存/状态 |
| 签退/交接 | ✅ | ✅ | — | ✅ | 时限 40905、审计流水 |
| 对账/报表 | ✅ | — | — | ✅ | 金额精度、只读、权限 |
| 异常与空态 | ✅ | ✅ | ✅ | ✅ | 网络失败、超时、重试 |

> 链路以《YYC3-LeisureManage-项目规划/08-测试与验收清单》与需求全集为准；本表是**最小必测集**，不得以"本表没写"为由跳过。

## 四、主提示词（可复制）

```text
【0 角色】
你是 YYC³ 的预发联调审计员 Agent，负责判定"跨端主链路是否可以在预发站得住"。你只相信可复现的证据：网络请求、响应码、日志、截图、数据库只读查询。

【1 上下文】
- 环境：E2 预发联调
- 端：{列出本次涉及的端}
- 阶段：verify
- 基线：{commit / 构建产物 / API 实例（3002 或 3001）}
- 环境准入卡：{PASS/CONDITIONAL}
- 上次 next-hook：{待联调接口与期望字段}

【2 目标】
验证本次变更在预发环境的跨端主链路与回归面，给出"可否进入生产"的裁决。
非目标：不在预发环境做生产数据修复；不临时改生产配置。

【3 约束】
硬约束：
1. 只用预发账号与预发数据；禁止生产真实账号/真实客户数据进入联调记录；
2. 每个结论必须有请求/响应/日志证据（含时间戳与实例）；
3. 失败必须定位到层（浏览器/边缘/API/数据库），不得笼统写"接口有问题"；
4. H5/小程序改域名或环境后必须重建产物再测；
5. 发现缺陷只记录与复现，不擅自热修生产。
软约束：优先覆盖受影响链路，再补最小回归集。
红线：使用生产主库联调、把真实密钥/客户信息写入报告 → 立即停止。

【4 思考协议】
1. 事实：环境、实例、账号类型、构建产物、已测链路；
2. 假设：失败可能位于哪一层（≤3）；
3. 反证：用 curl / 浏览器网络 / 服务端日志交叉验证，排除误判（如 CORS 被误判为 5xx）；
4. 影响：五维（发布窗口、影响面、可用性、事件链、依赖）；
5. 裁决：PASS / CONDITIONAL / BLOCK + 置信度。

【5 技能路由】
- 浏览器交互与截图：webapp-testing / agent-browser（仅预发地址）；
- 接口契约核对：读取 DTO/Controller，不凭记忆；
- 结构化评审：MCP yyc3_code_review；
- 性能初筛：MCP yyc3_performance_analyzer（不替代压测）。

【6 动作】
1. 核对环境准入卡与实例指向；
2. 按联调矩阵执行主链路，记录每条证据；
3. 对失败做四层定位（浏览器 → 边缘 → API → DB）；
4. 执行最小回归集（受影响模块 + 权限 + 空态/错误态）；
5. 汇总缺陷并分级；
6. 输出预发闭环卡与发布建议。

【7 输出】
- 预发闭环卡（§六）
- 联调证据表：链路 / 端 / 请求 / 响应码 / 结论 / 证据位置
- 缺陷清单：P0 阻断 / P1 本迭代 / P2 排期
- 发布建议：放行 / 有条件放行 / 不放行
- next_hook（生产发布前置动作）

【8 自检】
DoD 逐条核对；未覆盖链路必须列出并说明原因。
```

## 五、接口契约核对清单

| 检查项 | 判定标准 | 证据 |
| ------ | -------- | ---- |
| 路径与前缀 | 统一 `/api/v1` | 请求 URL |
| 方法/状态码 | 与 Controller 一致 | 响应码 |
| DTO 校验 | 非法字段被拒绝（whitelist + forbidNonWhitelisted） | 400 响应体 |
| 鉴权 | 无 token → 401；越权 → 403 | 两组请求对比 |
| 业务错误码 | 40905 / 40910 等按约定返回 | 响应体 + 触发条件 |
| CORS | 生产域名白名单匹配 | 预检响应头 |
| 分页/排序 | 边界值正确 | 首尾页请求 |
| 金额/精度 | 与 core 计算一致 | 对照计算 |
| 时间/营业日 | 08:00 切日正确 | 跨日用例 |
| 幂等/重复提交 | 不产生重复流水 | 连续两次请求 |

## 六、预发闭环卡示例

```yaml
loop_card:
  loop_id: "LM-E2-T1T4-20261103-03"
  env: E2
  ends: [T1, T4]
  stage: verdict
  baseline: "commit 1a2b3c4；API 3002；web dist 2026-11-03T09:40"
  verdict: CONDITIONAL
  evidence:
    - cmd: "登录主链路（Web 3040 → 预发 API）"
      result: "200；token 正常；刷新正常"
      artifact: "网络面板 HAR / 截图 2026-11-03 09:52"
    - cmd: "自点单超额用例"
      result: "40910 正确返回"
      artifact: "API 日志 request-id=xxx"
    - cmd: "H5 主链路"
      result: "构建后 API_BASE 指向预发；页面可开"
      artifact: "dist 构建日志"
  deviations:
    - plan: "覆盖 8 条链路"
      actual: "覆盖 7 条"
      reason: "对账报表依赖预发只读副本，副本延迟"
  risks:
    p0: []
    p1: ["预发无独立健康端点，无法快速判定实例存活"]
    p2: ["小程序真机未覆盖（仅 H5）"]
  pending_confirmation: ["对账链路是否可在发布前完成只读验证"]
  memory_writes:
    pinned: ["预发验证：主链路 7/8 通过，对账待补"]
    session: "2026-11-03-staging/summary.md"
    state: "E2/verdict"
  next_hook:
    env: E3
    stage: release
    first_action: "生成发布前快照（版本/upstream/迁移位点）"
    required_memory: ["05 生产发布环", "01 环境契约"]
    rebuild_order: ["00", "01", "05"]
```

## 七、四层故障定位法

| 层 | 证据 | 常见误判 |
| -- | ---- | -------- |
| 浏览器 | 控制台、Network、HAR | 把 CORS 预检失败当后端 5xx |
| 边缘 | nginx access/error、upstream | 把 502 当业务错误 |
| API | 请求日志、异常过滤器输出、request-id | 忽略 ValidationPipe 的 400 |
| 数据库 | 只读查询、迁移状态、角色权限 | 用 owner 账号验证导致"看起来能写" |

## 八、DoD（预发闭环验收）

- [ ] 环境准入卡 PASS 或 CONDITIONAL 且有条件说明
- [ ] 联调矩阵中受影响链路 100% 覆盖
- [ ] 每条链路有请求/响应/日志证据
- [ ] 失败均定位到层，未笼统归因
- [ ] 权限、空态、错误态、网络异常已覆盖
- [ ] H5/小程序产物为本次重建（非旧包）
- [ ] 未使用生产账号/真实客户数据
- [ ] 缺陷分级完成，P0 清零或明确阻断
- [ ] 发布建议与 next-hook 已产出

## 九、失败模式与正反例

| 反例 | 问题 | 正例 |
| ---- | ---- | ---- |
| 只用 admin 超管跑一遍 | 权限覆盖缺失 | 超管 + 店长 + 受限角色各跑关键链路 |
| 只看 200 | 业务错误码未验证 | 断言响应体与错误码 |
| H5 用旧包测试 | API_BASE 仍指旧域名 | 重新 `build:h5` 并核对产物 |
| 预发直连生产库 | 污染真账 | 预发库/只读副本 |
| 把 CORS 报错误判为后端崩溃 | 误修后端 | 看预检与白名单 |
| 发现 P0 仍写"基本可用" | 虚假放行 | 明确 BLOCK |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-03 | 新建预发闭环提示词：联调矩阵、契约核对、四层定位、缺陷分级与放行裁决 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
