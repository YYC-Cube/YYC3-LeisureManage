---
file: YYC3-环境契约-环境矩阵与准入门禁.md
title: YYC³ 环境契约 — 环境矩阵与准入门禁
description: YYC³ LeisureManage 环境契约 — E0–E5 环境矩阵、端口/域名/数据/密钥纪律、准入检查表与审计提示词
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-03
updated: 2026-11-03
status: stable
tags: [environment, contract, gate, configuration, security]
category: policy
language: zh-CN
audience: developers,qa-engineers,devops,ops
complexity: intermediate
project: YYC3-LeisureManage
phase: 项目开发-智能协同
---

# YYC³ 环境契约 — 环境矩阵与准入门禁

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

本文件是**所有环境动作的前置契约**。任何开发、构建、联调、发布、排障会话，第一步都必须先过本文件的准入检查表。

- 不知道"现在在哪个环境"→ 先读 §二；
- 不知道"变量从哪来、能不能写进文档"→ 先读 §四；
- 不知道"能不能动生产"→ 先读 §五、§六；
- 需要一条可直接执行的审计提示词 → 用 §七。

## 二、环境矩阵（单一事实表）

| 维度 | E0 本地开发 | E1 集成构建 | E2 预发联调 | E3 生产运行 | E4 灾备回退 |
| ---- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 入口 | 本机 | GitHub Actions | 预发静态目录 / NAS 备实例 | `lm.0379.world` / `lm.0379.pro` | NAS / 旧产物 |
| Web | Vite dev 3040（规则：3030 起） | `pnpm build` 产物 | `web/` 预发目录 | ECS 边缘 `web/` 静态 | 上一版 `web/` |
| H5/小程序 | `dev:h5` / `dev:weapp` | `build:h5` / `build:weapp` | `h5/` 预发目录 | ECS 边缘 `h5/` + 微信后台 | 上一版 `h5/` |
| API | 本机 3001，`NODE_ENV=dev` | `pnpm build` + 测试 | Mac 主 3002 / NAS 备 3001 | Mac 主 3002（frp 8802） | NAS 备 3001（frp 8801） |
| 数据 | PG 5434 + Redis 6380 | 测试库/内存替身 | 预发库或只读副本 | PG15 主库 5433（Tailscale `100.87.159.21`） | NAS 流复制备库（只读） |
| 域名/来源 | localhost | 无 | 预发域名或直连 | `CORS_ORIGINS` 必须与域名严格一致 | 切流后沿用生产域名 |
| 密钥 | `.env`（dev-only 弱值） | GitHub Secrets | 部署副本（600） | 真值唯一来源：`~/.yyc3-keybackup/leisure-prod.env` | 同生产 |
| 观测 | 控制台 / 本地日志 | Actions 日志 | 边缘日志 + API 日志 | 边缘 nginx + API 日志 + 巡检 | 切流与备份日志 |

> **端口不变量**：开发服务器 3030 起；Web dev 3040；API dev 3001；开发库 5434；开发 Redis 6380。**禁止**连接生产 5433 做开发。

## 三、网络与拓扑（现状）

```
浏览器 / 微信小程序
        │  HTTPS
        ▼
ECS 边缘 nginx（lm.0379.world / lm.0379.pro）
        │  /api/v1/  → upstream 8802（默认）
        ▼
Mac 主 API :3002 ── SSH -R 8802 ──┐
        │                         │
        └── PG15 主库 :5433 ◄─────┘（与 API 同机）
                 │ 流复制
                 ▼
NAS 备库（只读） + NAS 备 API :3001 ── frp 8801（回退位）
```

- **切流**：边缘 `proxy_pass` 8802 ↔ 8801 → `nginx -s reload`；
- **回退目标**：RTO ≤ 15 分钟，RPO ≤ 24 小时（每日 `pg_dump` + WAL）；
- **只读降级**：主库故障切 NAS 备库后，必须关闭收银/开房等写入口并公告只读。

## 四、配置与密钥纪律

### 4.1 三处真值

| 位置 | 内容 | 权限 | 可否入 git |
| ---- | ---- | ---- | ---------- |
| `~/.yyc3-keybackup/leisure-prod.env` | 生产真值唯一来源（28 键） | 600 / 目录 700 | ❌ |
| NAS `/Volume3/docker/yyc3-leisure-api/.env.production` | 部署副本（scp） | 600 | ❌ |
| 仓库 `deploy/nas/.env.production.example` | 占位样例 | — | ✅（零真值） |

### 4.2 变量分组（按用途）

| 分组 | 代表变量 | 规则 |
| ---- | -------- | ---- |
| 身份与环境 | `NODE_ENV`、`PORT` | 生产固定 `prod`，触发硬化校验 |
| 数据库 | `DATABASE_URL`、`DATABASE_URL_OWNER` | 运行时只用受限账号 `leisure_app`；owner 仅迁移 |
| 认证签名 | `JWT_SECRET`、`JWT_REFRESH_SECRET`、`SCENE_HMAC_KEY` | ≥32 位强随机；轮换 = 全员重登 |
| 网关前端 | `CORS_ORIGINS`、`SWAGGER_ENABLED` | 生产 `CORS` 必填；Swagger 默认关 |
| 业务规则 | `BUSINESS_DAY_CUT`、`BILL_ROUNDING_MINUTES`、限额组 | 门店级「销售经理设置」可覆盖 |
| 硬件/微信 | `VOICE_BOX_URL`、`WX_APPID`、`WX_SECRET` | 盒子地址限私网；微信凭据未填仅限 dev |

### 4.3 密钥红线

- ❌ 在对话、文档、截图、日志中出现真实密钥、口令、Token、数据库连接串；
- ❌ 把 `.env` 复制进仓库或提交历史；
- ❌ 用生产 owner 账号跑 API 进程；
- ✅ 文档只写变量名 + 占位符（`${VAR}` / `[REDACTED]`）；
- ✅ 生成、轮换、留痕统一走 `gen-prod-secrets.sh`（自动 `.bak-<时间戳>`）。

## 五、生产动作分级与批准

| 级别 | 动作示例 | 批准要求 | 回退路径 |
| ---- | -------- | -------- | -------- |
| **A 只读** | 读日志、查状态、跑只读巡检 | 无需批准 | — |
| **B 可逆变更** | 静态 `rsync`、API 重启、边缘 reload | 会话内声明 + 记录 | 上一版目录 / KeepAlive |
| **C 高风险变更** | 数据库迁移、密钥轮换、切流 | **人工显式批准** | 迁移只加列；切流 8801 |
| **D 禁止** | 删库、UPDATE/DELETE 账务、整库回滚覆盖线上 | 一律禁止 | 走反向流水/精准回灌 |

> 任何 C/D 级动作，AI 必须先输出"影响面 + 回退步骤 + 验证命令"，得到明确批准后才可执行。

## 六、准入检查表（每个环境都要过）

### 6.1 E0 本地

- [ ] `NODE_ENV=dev`，API 监听 3001，Web dev 3040；
- [ ] `DATABASE_URL` 指向 `127.0.0.1:5434`，`REDIS_URL` 指向 `6380`；
- [ ] `.env` 未入 git，弱密钥仅限本地；
- [ ] 已确认目标文件路径与基线（`git status` 干净或有明确未提交改动）。

### 6.2 E1 集成

- [ ] `pnpm install --frozen-lockfile` 成功；
- [ ] `scripts/verify-gates.sh` 通过（tsc / build / mock / i18n / 复用率）；
- [ ] 测试套件按 CI 串行执行，无 OOM；
- [ ] SAST（CodeQL）无新增高危。

### 6.3 E2 预发

- [ ] 预发 API 可达（3002 或 3001），边缘 upstream 指向预期实例；
- [ ] 预发静态目录与本次构建产物一致（校验文件名/时间戳）；
- [ ] H5 的 `TARO_APP_API_BASE` 已按预发域名重建；
- [ ] 数据为预发/只读副本，**不是**生产主库。

### 6.4 E3 生产

- [ ] 变更级别已定（A/B/C/D），C 级已获人工批准；
- [ ] 发布前快照：当前版本、当前 upstream、当前迁移位点；
- [ ] 回退路径已写明（静态上一版 / 旧 tag / 8801 切流）；
- [ ] 发布窗口与值守人已知；
- [ ] 发布后验证命令与观测项已列。

### 6.5 E4 灾备

- [ ] 判级 L1/L2/L3 已明确；
- [ ] 主备状态已知（主库是否在线、备库是否只读、WAL 位点）；
- [ ] 切流/回切命令已复核；
- [ ] 数据回灌只走"临时库 + 精准回灌"，禁止整库覆盖。

## 七、环境契约审计提示词（可复制）

```text
【角色】你是 YYC³ 的环境契约审计员，遵循「五高五标五化五维」，只依据代码、配置与命令输出作结论。

【上下文】
- 项目：YYC3-LeisureManage
- 目标环境：E0/E1/E2/E3/E4（明确其一）
- 目标端：T1 Web / T2 H5 / T3 小程序 / T4 API / T5 核心包
- 基线：commit/tag/产物路径 = {BASELINE}
- 已知事实：{从仓库或运维文档中已核实的事实}

【目标】判定本次动作是否满足该环境准入条件，并给出最小必要修正。
【非目标】不执行任何 C/D 级动作；不读取或输出真实密钥。

【约束】
1. 必须先读取相关配置与入口文件，再给结论；
2. 密钥只允许以变量名或占位符出现，发现明文立即标记 P0 并停止引用；
3. 每条结论附证据：文件:行号 / 命令输出摘要；
4. 不确定项一律标注「待确认」，不得猜测。

【思考协议】
1. 列已核实事实（环境、端口、数据源、密钥来源、产物）；
2. 提假设（≤3）：当前配置可能导致的漂移点；
3. 对首选假设做反证（找一条能推翻它的证据）；
4. 五维影响分析（时间/空间/属性/事件/关联）；
5. 裁决 + 置信度 + 待确认清单。

【动作】
1. 核对环境矩阵（端口/域名/数据源/密钥来源）；
2. 核对变量分组与红线（是否使用受限账号、CORS 是否匹配）；
3. 核对准入检查表逐项；
4. 输出环境准入卡与修正方案。

【输出】
- 环境准入卡 YAML（见 §八）
- 结论：✅ 准入 / ⚠️ 有条件准入 / ❌ 拒绝准入
- P0 阻断项（含最小改动）
- P1/P2 项
- 待确认项
- next_hook（下一环境、第一动作、必带记忆、重建顺序）
```

## 八、环境准入卡（输出契约）

```yaml
env_gate_card:
  env: E2
  ends: [T1, T4]
  baseline: "commit abc1234 / dist 2026-11-03T10:00"
  checks:
    - item: "预发 API 可达"
      result: "PASS"
      evidence: "curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:3002/api/v1 → 401（需鉴权，链路通）"
    - item: "H5 API_BASE 与预发域名一致"
      result: "PASS"
      evidence: "构建日志 grep TARO_APP_API_BASE"
  verdict: PASS
  risks:
    p0: []
    p1: ["预发缺少独立健康端点，建议补 /api/v1/health"]
    p2: []
  pending_confirmation: ["预发库是否为只读副本"]
  next_hook:
    env: E3
    stage: release
    first_action: "生成发布前快照并核对回退路径"
    required_memory: ["01 环境契约", "05 生产发布环"]
    rebuild_order: ["00", "01", "05"]
```

## 九、主动技能与工具路由

| 场景 | 使用 | 说明 |
| ---- | ---- | ---- |
| 环境/流水线配置草案 | MCP `yyc3_deployment_config` | 先 `ToolSearch` 装载，再调用；不得写入真实密钥 |
| 安全评审（显式请求） | `security-best-practices` | 重点：密钥纪律、CORS、鉴权、注入 |
| 预览部署 | `deployment` | 仅预览；生产发布不在技能内自动执行 |
| 依赖与漏洞 | `pnpm audit` / CI SAST | 结论须附命令输出 |

## 十、技术择优（环境相关）

| 场景 | 首选 | 依据 | 反模式 |
| ---- | ---- | ---- | ------ |
| 环境变量读取 | 启动时集中校验（现有 `config/env`） | 早失败、硬化校验 | 业务代码内散落 `process.env` |
| 生产配置分发 | 密钥库 → 部署副本（600） | 单一真值来源 | 把真值写进 compose/git |
| 环境区分 | `NODE_ENV` + 显式环境代号 | 与矩阵一致 | 用域名猜环境 |
| 只读降级 | 关闭写入口 + 公告 | 保护账务一致性 | 让备库接收写入 |
| 健康探测 | 建议新增 `/api/v1/health`（P1） | 现网无独立端点 | 以"页面能开"代替探测 |

## 十一、失败模式与反例

| 反例 | 后果 | 正确做法 |
| ---- | ---- | -------- |
| 用生产 5433 做本地开发 | 污染真账、权限越界 | 固定用 5434 开发库 |
| 把 `.env` 内容贴进对话 | 密钥泄露 | 只报变量名与是否配置 |
| 改 H5 域名后只重启服务 | `API_BASE` 内联未更新，请求旧域名 | 重新 `build:h5` |
| 生产直接 `rsync` 覆盖且无上一版 | 无法回退 | 保留上一版目录或 tag |
| 未获批准执行迁移 | 破坏性变更不可逆 | C 级动作先批准 + 只加列 |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-03 | 新建环境契约：E0–E5 矩阵、拓扑、密钥纪律、动作分级、准入检查表、审计提示词与准入卡 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
