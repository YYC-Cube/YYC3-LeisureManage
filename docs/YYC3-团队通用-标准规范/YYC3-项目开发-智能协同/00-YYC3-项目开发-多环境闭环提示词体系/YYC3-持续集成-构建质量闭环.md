---
file: YYC3-持续集成-构建质量闭环.md
title: YYC³ 持续集成 — 构建与质量门禁闭环提示词
description: E1 集成构建环境闭环提示词 — CI 门禁矩阵、红灯分诊、修复优先级、证据链与发布前置裁决
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-03
updated: 2026-11-03
status: stable
tags: [prompt, ci, quality-gate, build, closed-loop]
category: prompt
language: zh-CN
audience: developers,devops,qa-engineers,ai-tutors
complexity: intermediate
project: YYC3-LeisureManage
phase: 项目开发-智能协同
---

# YYC³ 持续集成 — 构建与质量门禁闭环提示词

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

- **环境**：E1 集成构建（GitHub Actions）
- **阶段**：execute → verify → verdict
- **适用**：提交 PR、CI 红灯排障、门禁规则修订、发布前置验证
- **不适用**：生产发布（05）、线上回滚（06）

## 二、CI 事实基线

| 工作流 | 触发 | 关键内容 |
| ------ | ---- | -------- |
| `.github/workflows/ci.yml` | push / PR → main | 安装依赖（含 audit）→ 三端同源一致性 → 质量门禁 → 四端测试；另有 CodeQL SAST |
| `.github/workflows/release.yml` | tag `v*` / 手动 | 门禁前置 → Electron 三平台 → Docker GHCR |

### 2.1 门禁矩阵（`scripts/verify-gates.sh`）

| 门禁 | 内容 | 通过标准 | 备注 |
| ---- | ---- | -------- | ---- |
| G1 | 十二包 `tsc --noEmit` | 全部 0 error | theme/core/store/ui/business/ai/ops/admin/monitor/ai-family/ide/shell |
| G2 | 四端 `tsc --noEmit` | 全部 0 error | app-web-full / app-desktop / app-web-classic / app-sandbox-lite |
| G3 | 四端 build | 全部成功 | `--skip-build` 可跳过（仅本地临时） |
| G4 | 失效 `vi.mock` 扫描 | STALE = 0 | `scripts/mock-audit.mjs` |
| G5 | i18n 裸键扫描 | 0 为通过；存量登记时 ⚠️ 不阻断 | `scripts/i18n-bare-key-scan.mjs` |
| G6 | 复用率报表 | 生成并留档 | `scripts/reuse-report.mjs` |
| 附加 | `check-test-sync.mjs` | 三端同源一致 | 测试/electron/deploy |

### 2.2 CI 测试执行口径

- 四端 vitest **串行**执行，避免 worker fork 触发 V8 堆上限 OOM；
- `NODE_OPTIONS=--max-old-space-size=4096`；
- 安装必须 `--frozen-lockfile`，保证与 `packageManager`（pnpm@12）一致。

### 2.3 已识别的门禁缺口（评估结论，P1）

| 缺口 | 影响 | 建议 |
| ---- | ---- | ---- |
| 门禁脚本覆盖 CloudPivot 的 4 个应用，未覆盖 LeisureManage 的 `app-leisure-web` / `app-mp-artist` / `services/leisure-api` | LeisureManage 改动可能"CI 全绿但实际未验证" | 新增 Leisure 专用 job：type-check + build + test（见 §八 建议片段） |
| `pnpm audit --audit-level high || true` | 高危依赖不阻断 | 保留豁免登记（`auditConfig.ignoreGhsas`），但要求新增豁免必须留痕并限期复核 |
| 无独立 API 健康端点 | 部署后探测只能靠业务接口 | 建议新增 `/api/v1/health`（低成本、收益高） |

## 三、主提示词（可复制）

```text
【0 角色】
你是 YYC³ 的持续集成守门员 Agent。你的唯一职责是判断"这次变更能否进入下一环境"，而不是"帮开发者把红灯变绿"。所有结论必须基于 CI 日志、门禁命令输出与仓库事实。

【1 上下文】
- 环境：E1 集成构建
- 端：{受影响的端，按实际改动列出}
- 阶段：{execute/verify}
- 基线：commit {sha} / PR #{n} / tag {v}
- CI 运行：{run id 或本地复现命令}
- 已锁定记忆：{门禁规则、豁免登记、已知存量}

【2 目标】
判定本次变更的门禁结论（PASS / CONDITIONAL / BLOCK），并给出最小修复路径。
非目标：不扩大重构范围；不通过删除测试、放宽规则来"变绿"。

【3 约束】
硬约束：
1. 必须引用失败步骤的真实日志行，不得转述；
2. 修复必须触及根因，禁止 skip/only/禁用断言/注释门禁；
3. 不得修改 `verify-gates.sh` 的判定逻辑来绕过失败；
4. 不得无记录地扩大 `auditConfig.ignoreGhsas` 或安全豁免；
5. 依赖变更必须保持单一 lockfile（根 workspace）。
软约束：修复范围限定在失败链路；顺带问题记为 P2 另开项。
红线：为了让 CI 变绿而删测试、跳过类型检查、关闭 SAST → 直接 BLOCK 并上报。

【4 思考协议】
1. 事实：失败步骤、失败命令、首条错误、影响包；
2. 假设：≤3 条根因（类型/依赖/环境/用例/工具链）；
3. 反证：对首选根因做一次反证（本地能否复现？是否仅 CI 环境差异？）；
4. 影响：时间（CI 时长）、空间（包体积）、属性（质量）、事件（失败链）、关联（依赖图）；
5. 裁决：BLOCK / CONDITIONAL / PASS + 置信度。

【5 技能路由】
- 测试缺口：MCP yyc3_test_generator 生成草案，本地跑通后再收录；
- 安全告警：security-best-practices（仅显式要求时）；
- 提交规范：git-commit（仅在用户要求提交时）；
- 同类问题历史：检索仓库既有踩坑台账，不重复造轮子。

【6 动作】
1. 复现：本地执行与 CI 相同命令（必要时 `--skip-build` 分步）；
2. 定位：首个失败点 → 影响包 → 依赖链；
3. 修复：最小改动，说明"为什么这样改能消除根因"；
4. 回归：受影响包 type-check + build + test；必要时全量门禁；
5. 裁决：输出 CI 闭环卡；
6. 交接：为 E2 预发准备 next-hook（含联调重点与风险）。

【7 输出】
- CI 闭环卡（§六）
- 失败分诊表：步骤 / 首错 / 根因 / 修复 / 回归证据
- 结论与 P0/P1/P2
- 待确认项（环境差异、缓存、权限）
- next_hook

【8 自检】
逐条核对 DoD；任何"本地通过但 CI 未验证"必须标注。
```

## 四、红灯分诊流程

```
CI 红灯
  │
  ├─ 安装失败（lockfile / registry / allowBuilds）
  │    → 检查 pnpm 版本、frozen-lockfile、allowBuilds、blockExoticSubdeps
  │
  ├─ G1/G2 类型失败
  │    → 定位首个 error；检查是否跨包导出变更、React 18/19 类型差异
  │
  ├─ G3 构建失败
  │    → 检查 Vite/Taro 配置、base 路径、环境变量内联、产物路径
  │
  ├─ G4 mock 失效
  │    → 检查被 mock 模块的导出签名是否变化
  │
  ├─ G5 i18n 裸键
  │    → 存量登记则记录；新增裸键必须修复
  │
  ├─ 测试失败
  │    → 区分"用例过期 / 代码回归 / 环境差异"；串行复跑排除 OOM
  │
  └─ SAST 告警
       → 判断可达性；不可达也须登记，不得静默关闭
```

### 4.1 本地复现命令

```bash
pnpm install --frozen-lockfile
node scripts/check-test-sync.mjs
bash scripts/verify-gates.sh            # 全量
bash scripts/verify-gates.sh --skip-build  # 快速分诊

# LeisureManage 受影响包（当前需手工补跑）
pnpm --filter @yyc3/app-leisure-web type-check && pnpm --filter @yyc3/app-leisure-web build
pnpm --dir services/leisure-api type-check && pnpm --dir services/leisure-api test
pnpm --dir apps/app-mp-artist build:h5
```

## 五、技术择优（CI 修复）

| 场景 | 首选 | 依据 | 反模式 |
| ---- | ---- | ---- | ------ |
| 类型错误 | 修正类型/导出 | 根因修复 | `as any` 掩盖 |
| 测试过期 | 更新用例断言 | 行为已变更需同步 | 删测试 |
| 仅 CI 失败 | 对齐 Node/pnpm/缓存 | 环境一致性 | 本地"我这边能跑" |
| 依赖漏洞 | 线内补丁升级 | 兼容性优先 | 直接忽略告警 |
| 豁免登记 | 记录 GHSA + 理由 + 复核期 | 可审计 | 永久静默 |
| 构建慢 | 缓存依赖、分 job | 时间维 | 跳过 build |
| 跨端一致性 | `check-test-sync.mjs` | 防三端漂移 | 手工比对 |

## 六、CI 闭环卡示例

```yaml
loop_card:
  loop_id: "LM-E1-ALL-20261103-02"
  env: E1
  ends: [T1, T4]
  stage: verify
  baseline: "commit 1a2b3c4 / PR #12"
  verdict: BLOCK
  evidence:
    - cmd: "bash scripts/verify-gates.sh --skip-build"
      result: "exit 1；G2 app-leisure-web tsc 失败"
      artifact: "apps/app-leisure-web/src/pages/xxx.tsx:42"
    - cmd: "pnpm --filter @yyc3/app-leisure-web type-check"
      result: "exit 2；TS2322"
      artifact: "同上"
  deviations:
    - plan: "一次修复全部红灯"
      actual: "仅修复类型错误，测试缺口保留"
      reason: "该包暂无 test 脚本"
  risks:
    p0: ["类型错误阻断发布"]
    p1: ["LeisureManage 未纳入 verify-gates，存在门禁盲区"]
    p2: ["CI 未缓存 pnpm store，时长可优化"]
  pending_confirmation: ["是否本周补齐 Leisure 专用 CI job"]
  memory_writes:
    pinned: ["门禁缺口：Leisure 应用未纳入 G1–G3"]
    session: "2026-11-03-ci-triage/summary.md"
    state: "E1/verdict"
  next_hook:
    env: E2
    stage: verify
    first_action: "在预发环境复跑受影响的登录与收银主链路"
    required_memory: ["04 预发验证环", "01 环境契约"]
    rebuild_order: ["00", "01", "04"]
```

## 七、DoD（CI 闭环验收）

- [ ] 失败步骤已定位到具体命令与首条错误
- [ ] 根因说明可被证据支持（非猜测）
- [ ] 修复未删除/跳过任何测试或门禁
- [ ] 受影响包 type-check + build 通过
- [ ] 受影响测试通过；无测试则明确标注缺口
- [ ] 安全告警已分级处理（修复或登记豁免 + 复核期）
- [ ] lockfile 未被无关变更污染
- [ ] CI 闭环卡与 next-hook 已产出

## 八、建议：Leisure 专用 CI job（P1 落地片段）

```yaml
  leisure:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Leisure 类型与构建
        run: |
          pnpm --filter @yyc3/leisure-core type-check
          pnpm --filter @yyc3/app-leisure-web type-check
          pnpm --filter @yyc3/app-leisure-web build
          pnpm --dir services/leisure-api type-check
          pnpm --dir services/leisure-api test
          pnpm --dir apps/app-mp-artist build:h5
```

> 落地前需确认 `app-mp-artist` 的 CI 构建时长与缓存策略；Taro 构建较慢时可拆为独立 job 并行。

## 九、失败模式与正反例

| 反例 | 问题 | 正例 |
| ---- | ---- | ---- |
| 删掉失败用例让 CI 变绿 | 掩盖回归 | 判断行为是否变更，更新断言 |
| `// @ts-ignore` 批量压制 | 类型体系失效 | 修正类型或导出 |
| 关闭 SAST / 扩大豁免 | 安全盲区 | 记录 GHSA + 理由 + 期限 |
| 本地只跑 build | 漏类型/测试 | 跑与 CI 相同命令 |
| 在子包生成第二锁文件 | 依赖漂移 | 仅根 workspace 维护 |
| 宣称"CI 通过"但未看日志 | 虚假结论 | 附 run id 与关键行 |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-03 | 新建 CI 闭环提示词：门禁矩阵、红灯分诊、修复红线、Leisure 专用 job 建议与闭环卡 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
