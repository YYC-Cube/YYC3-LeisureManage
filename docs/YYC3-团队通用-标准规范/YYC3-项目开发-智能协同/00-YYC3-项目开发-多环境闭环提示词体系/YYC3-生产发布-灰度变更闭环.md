---
file: YYC3-生产发布-灰度变更闭环.md
title: YYC³ 生产发布 — 灰度与变更闭环提示词
description: E3 生产发布环境闭环提示词 — 发布前快照、变更分级、静态/API/数据库发布流、灰度与回退、发布后验证
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-03
updated: 2026-11-03
status: stable
tags: [prompt, production, release, canary, rollback]
category: prompt
language: zh-CN
audience: developers,devops,ops,managers
complexity: advanced
project: YYC3-LeisureManage
phase: 项目开发-智能协同
---

# YYC³ 生产发布 — 灰度与变更闭环提示词

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

- **环境**：E3 生产运行
- **阶段**：entry → execute → verify → verdict
- **适用**：Web/H5/小程序发版、API 版本更新、数据库迁移、生产配置变更
- **不适用**：日常巡检与故障处置（06 号文档）

> **铁律**：生产动作必须"可回退、可观测、有批准、有记录"。四项缺一，不得执行。

## 二、生产事实基线

| 项 | 事实 |
| -- | ---- |
| Web | ECS 边缘 `web/` 静态目录；同源 `/api/v1` |
| H5 | ECS 边缘 `h5/`；`TARO_APP_API_BASE` 编译期内联 |
| 小程序 | `build:weapp` + 微信后台合法域名 |
| API 主 | Mac `:3002`，launchd KeepAlive；frp/SSH 8802 |
| API 备 | NAS `:3001`，frp 8801 |
| 边缘 | ECS nginx；`proxy_pass 8802`（默认）/ `8801`（回退） |
| DB | PG15 主库 `:5433`（Tailscale `100.87.159.21`）；NAS 流复制备库（只读） |
| 账号 | 运行时 `leisure_app`（账务表无 UPDATE/DELETE）；迁移用 owner |
| 迁移 | 只加列/加表；迁移文件入 git；`migrate deploy` → grants → 必要时重启 API |
| Seed | `NODE_ENV=prod` 跳过测试账号 |
| 密钥 | 真值 `~/.yyc3-keybackup/leisure-prod.env`；部署副本 600 |
| 回退 | RTO ≤ 15 分钟；RPO ≤ 24 小时 |

## 三、变更分级与批准

| 级别 | 示例 | 批准 | 必备 |
| ---- | ---- | ---- | ---- |
| **A 只读** | 查日志、巡检、只读 SQL | 无 | 记录查询语句与结果 |
| **B 可逆** | 静态 rsync、API 重启、边缘 reload | 会话声明 | 上一版保留 + 验证命令 |
| **C 高风险** | 迁移、密钥轮换、切流、主备切换 | **人工显式批准** | 影响面 + 回退 + 验证 + 值守 |
| **D 禁止** | 删库、账务 UPDATE/DELETE、整库回滚覆盖 | 一律禁止 | 走反向流水/精准回灌 |

## 四、主提示词（可复制）

```text
【0 角色】
你是 YYC³ 的生产发布指挥官 Agent。你的职责不是"尽快上线"，而是"在上线的同时保留完整回退能力"。任何结论必须有发布前快照、执行证据与发布后验证。

【1 上下文】
- 环境：E3 生产
- 端：{Web/H5/小程序/API/DB/配置}
- 阶段：{entry/execute/verify}
- 基线：commit {sha} / tag {v} / 产物 {path + hash}
- 上游证据：E1 闭环卡 {id} + E2 闭环卡 {id}
- 变更级别：{B/C}；批准人：{姓名/时间}
- 回退目标：{上一版目录 / 旧 tag / 8801 / 备份}

【2 目标】
在批准窗口内完成本次发布，并证明"发布成功且可回退"。
非目标：不夹带未验证改动；不顺手优化无关配置。

【3 约束】
硬约束：
1. 无 E1/E2 证据不得发布；
2. 发布前必须生成快照：当前版本、upstream、迁移位点、产物 hash；
3. 静态发布必须保留上一版（目录或 tag），否则禁止覆盖；
4. 数据库只允许"只加列/加表"，禁止破坏性变更；
5. 迁移使用 owner 账号，API 运行时只用受限账号；
6. 发布后必须执行验证清单并开启观测窗口；
7. 任何失败先回退再分析，禁止线上边修边猜。
软约束：优先低峰窗口；优先可灰度路径。
红线：跳过批准、无回退路径、把密钥写入命令历史/日志、账务表 UPDATE/DELETE → 立即停止。

【4 思考协议】
1. 事实：版本、产物 hash、实例、upstream、迁移位点、批准；
2. 假设：本次最可能出问题的 3 个点（静态缓存 / API 结构 / DB 迁移）；
3. 反证：对首选风险找一条"若发生则表现为何"的判据；
4. 影响：五维（窗口、影响端、可用性、事件链、依赖）；
5. 裁决：执行 / 有条件执行 / 不执行 + 置信度。

【5 技能路由】
- 部署配置草案：MCP yyc3_deployment_config（不写真实密钥）；
- 预览验证：deployment 技能仅用于预览，不自动发布生产；
- 提交与版本：git-commit（仅在用户要求时）；
- 安全评审：security-best-practices（显式请求时）。

【6 动作】
1. 发布前：核对上游闭环卡、生成快照、确认回退路径；
2. 静态：构建 → 校验产物 → 保留上一版 → rsync → 刷新/校验；
3. API：构建 → 确认迁移兼容 → 重启（KeepAlive）→ 验证实例；
4. H5/小程序：以生产 API_BASE 重建 → 发布 → 校验内联地址；
5. DB：`migrate deploy`（owner）→ grants → 必要时重启；
6. 发布后：执行验证清单 + 观测窗口；
7. 输出发布闭环卡与 next-hook。

【7 输出】
- 发布闭环卡（§七）
- 发布前快照（版本/upstream/迁移位点/hash）
- 执行记录（命令 + 时间 + 结果）
- 验证记录（每项判据 + 证据）
- 回退预案（触发条件 + 命令）
- 结论：PASS / CONDITIONAL（带观察项）/ ROLLBACK
- next_hook（观测窗口与巡检重点）

【8 自检】
DoD 逐条核对；"已验证"必须有命令或产物证据。
```

## 五、发布流程（按类型）

### 5.1 Web 静态

```bash
cd apps/app-leisure-web
pnpm type-check && pnpm build
# 校验产物（示例：记录 hash，便于回滚比对）
shasum -a 256 dist/index.html
# 保留上一版后同步（上一版目录命名需人工确认）
rsync -az --delete dist/ <edge-host>:/root/yyc3-leisure-edge/web/
```

### 5.2 H5 / 小程序

```bash
cd apps/app-mp-artist
TARO_APP_API_BASE='https://lm.0379.pro/api/v1' pnpm build:h5
TARO_APP_API_BASE='https://lm.0379.pro/api/v1' pnpm build:weapp
# 发布后必须核对产物内联地址，确认不是旧域名
```

### 5.3 API

```bash
cd services/leisure-api
pnpm type-check && pnpm build
# 重启由 KeepAlive 拉起；重启前后必须记录实例与版本
```

### 5.4 数据库迁移

```bash
# 只加列/加表；owner 账号执行
DATABASE_URL="$DATABASE_URL_OWNER" pnpm --dir services/leisure-api exec prisma migrate deploy
psql "$OWNER_URL" -d leisure -f services/leisure-api/scripts/apply-pg-grants.sql
# Prisma client 结构变化时重启 API
```

> 迁移前必须确认：备份可用、迁移脚本只增不删、回退兼容（旧代码能读新结构）。

## 六、灰度策略（现状与建议）

### 6.1 现网可用能力

| 能力 | 说明 | 适用 |
| ---- | ---- | ---- |
| 双 API 实例 | Mac 主 3002 / NAS 备 3001，边缘可切流 | 回退、短时降级 |
| 静态目录切换 | 保留上一版目录可快速回切 | Web/H5 回退 |
| 迁移向后兼容 | 旧代码可读新结构 | 降低回退阻力 |
| 只读降级 | 主库故障时关闭写入口 | 数据层保护 |

### 6.2 建议灰度路径（执行前需人工确认）

```
1) 新版本先部署到 NAS 备实例（3001），不改主实例；
2) 通过内网/Tailscale 直连 3001 做最小验证；
3) 边缘切流 8801，观察一个窗口（错误率/关键链路）；
4) 稳定后升级主实例 3002，再切回 8802；
5) 任一环节异常：立即切回 8802（旧主）或 8801（旧备）。
```

> 该路径利用现有双实例，但**不是现网既定流程**。执行前必须确认 NAS 容量、DB 连接权限与版本兼容性。未确认前，按"直接发布 + 回退"执行。

## 七、发布闭环卡示例

```yaml
loop_card:
  loop_id: "LM-E3-T1T4-20261103-04"
  env: E3
  ends: [T1, T4]
  stage: verdict
  baseline: "tag v0.1.4；web dist sha256=xxxx；API commit 1a2b3c4"
  verdict: PASS
  evidence:
    - cmd: "发布前快照"
      result: "upstream=8802；上一版 web 目录=/root/.../web.prev；迁移位点=20261103_add_col"
      artifact: "运维台账 2026-11-03 10:20"
    - cmd: "rsync web dist"
      result: "exit 0；index.html hash 与本地一致"
      artifact: "edge web/index.html"
    - cmd: "API 重启后登录验证"
      result: "200；登录/刷新正常"
      artifact: "API 日志 request-id=xxx"
    - cmd: "H5 产物内联地址核对"
      result: "grep 到 https://lm.0379.pro/api/v1"
      artifact: "h5 构建产物"
  deviations:
    - plan: "灰度到 NAS 备实例"
      actual: "直接发布主实例"
      reason: "NAS 容量未确认，按既定回退路径执行"
  risks:
    p0: []
    p1: ["无独立健康端点，实例存活靠业务请求判断"]
    p2: ["静态发布依赖人工保留上一版，建议脚本化"]
  pending_confirmation: ["观测窗口内错误率基线"]
  memory_writes:
    pinned: ["生产发布 v0.1.4 完成，回退位=8802/上一版目录"]
    session: "2026-11-03-release/summary.md"
    state: "E3/observe"
  next_hook:
    env: E3
    stage: observe
    first_action: "开启 30 分钟观测窗口：错误日志、登录、开房、收银主链路"
    required_memory: ["06 运行观测环", "03 运维巡检手册"]
    rebuild_order: ["00", "06", "01"]
```

## 八、发布后验证清单

- [ ] 静态资源 200 且 hash/版本与本地一致
- [ ] API 实例存活，`/api/v1` 返回预期鉴权响应
- [ ] 登录 / 刷新 token 正常
- [ ] 受影响主链路最小冒烟（只读优先，写操作须批准）
- [ ] H5/小程序内联 API_BASE 为生产域名
- [ ] 数据库迁移位点正确，账号权限未被放宽
- [ ] 边缘 upstream 指向预期实例
- [ ] 错误日志无新增异常峰值
- [ ] 观测窗口与值守人已记录
- [ ] 回退命令已复核可用

## 九、DoD（发布闭环验收）

- [ ] E1 + E2 证据齐全
- [ ] 变更级别与批准记录完整
- [ ] 发布前快照可复原（版本/upstream/迁移/hash）
- [ ] 上一版产物保留
- [ ] 执行命令与结果逐条记录
- [ ] 发布后验证清单全部执行
- [ ] 观测窗口已开启并有明确结束条件
- [ ] 回退预案写明触发条件
- [ ] 密钥未出现在任何命令输出/日志
- [ ] 发布闭环卡与 next-hook 已产出

## 十、失败模式与正反例

| 反例 | 后果 | 正例 |
| ---- | ---- | ---- |
| 直接 `--delete` 覆盖且无上一版 | 无法回退 | 先保留上一版目录 |
| 改 H5 域名后只重启 | 请求旧 API | 重新构建并核对内联地址 |
| 迁移删列/改名 | 旧代码崩溃 | 只加列/加表 |
| 用 owner 账号跑 API | 权限越界 | 运行时 `leisure_app` |
| 发布失败边修边猜 | 故障窗口拉长 | 先回退再分析 |
| 把密钥写进 shell history | 泄露 | 从密钥库注入，命令脱敏 |
| 未验证就宣称"上线成功" | 虚假交付 | 附验证证据 |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-03 | 新建生产发布闭环提示词：分级批准、快照、发布流、灰度建议、验证与回退 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
