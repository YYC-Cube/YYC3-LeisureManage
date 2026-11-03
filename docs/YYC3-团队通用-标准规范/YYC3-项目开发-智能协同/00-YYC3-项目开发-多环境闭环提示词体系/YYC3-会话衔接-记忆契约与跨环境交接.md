---
file: YYC3-会话衔接-记忆契约与跨环境交接.md
title: YYC³ 会话衔接 — 记忆契约与跨环境交接提示词
description: 跨会话与跨环境连续性提示词 — 三层记忆、Kickoff 七步、next-hook 契约、断点续传、冲突仲裁与记忆卫生
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-03
updated: 2026-11-03
status: stable
tags: [prompt, continuity, memory, handoff, long-session]
category: prompt
language: zh-CN
audience: developers,ai-tutors,managers
complexity: intermediate
project: YYC3-LeisureManage
phase: 项目开发-智能协同
---

# YYC³ 会话衔接 — 记忆契约与跨环境交接提示词

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

本文件解决**跨会话、跨环境、跨导师**的上下文连续性：

- 新会话如何"接着上次"而不是重新开始；
- 长会话如何压缩记忆而不失关键决策；
- 一个环境闭环如何把上下文交给下一个环境；
- 上下文丢失时如何按固定顺序重建。

> **原则**：连续性不是"记得多"，而是"记得准、取得快、可校验"。

## 二、三层记忆（结构）

| 层 | 位置（建议） | 内容 | 写入时机 | 注入时机 |
| -- | ------------ | ---- | -------- | -------- |
| **锁定层** | `memory/pinned/tech-decisions.md`<br>`user-preferences.md`<br>`open-questions.md` | 不可轻易推翻的决策、偏好、待决问题 | 决策确认时 | 每次 kickoff 全量 |
| **会话层** | `{YYYY-MM-DD}-{slug}/summary.md`<br>`next-hook.md` | 单次会话压缩小结与交接钩子 | 阶段结束/会话结束 | kickoff 注入最近 1–2 条 |
| **状态层** | `.prompt-state/current-phase.md`<br>`active-memory-hash.md`<br>`last-session-pointer.md` | 当前环境/阶段/记忆指纹/上次指针 | 每阶段切换 | 每轮轻量注入 |

### 2.1 与团队既有会话目录的关系

团队规范已定义会话主目录 `{项目名}-{导师}-{YYYYMMDD}/` 与 `00-项目现状审核报告`、`01-任务规划`、`02-执行日志`、`03-总结`。本体系**不替换**它们：

| 团队文档 | 本体系记忆 | 关系 |
| -------- | ---------- | ---- |
| 02-执行日志 | 会话层 `summary.md` | 日志是过程，`summary` 是压缩结论 |
| 03-总结与状态同步 | `next-hook.md` | 总结面向人，hook 面向下一次执行 |
| 全局规范 | `pinned/` | 锁定层只存"本项目已确认"的决策 |

## 三、Kickoff 七步（新会话强制）

```
1. 定位最新会话目录（按时间倒序）
2. 读 last-session-pointer → 最近一次 summary + next-hook
3. 读 pinned/（技术决策 / 偏好 / 待决问题）
4. 校验 active-memory-hash（是否漂移）
5. 校验代码现状（git status / git log / 基线）
6. 声明本次定位：环境 + 端 + 阶段 + 基线
7. 向用户确认："从 {阶段} 的 {第一动作} 继续，是否确认？"
```

> **禁止**：跳过 1–6 直接回答；用"好的，我来帮你"替代定位。

## 四、主提示词 A：新会话 Kickoff（可复制）

```text
【0 角色】
你是 YYC³ 的会话衔接官 Agent。你的首要任务不是立刻干活，而是先证明"你已经准确接上了上一次"。

【1 上下文】
- 项目：YYC3-LeisureManage
- 本次环境/端/阶段：{待确认}
- 上次 next-hook：{路径与内容摘要}
- 锁定层记忆：{tech-decisions / user-preferences / open-questions 摘要}
- 记忆指纹：{hash 或"未建立"}
- 代码现状：{git log 最近 3 条 / git status}

【2 目标】
在 5 分钟内完成上下文定位，给出"继续点"，并声明本次目标。
非目标：不在未定位前开始改代码。

【3 约束】
1. 必须引用具体记忆文件与具体字段，不得泛指"之前的上下文"；
2. 发现记忆与代码冲突，以代码为准，并记录冲突；
3. 指纹不匹配时，先人工确认，不自动覆盖；
4. 不得在记忆中写入密钥、真实账号、客户隐私。

【4 思考协议】
1. 事实：上次做到哪、证据在哪、当前代码是否一致；
2. 假设：本次可能有 1–3 个延续点；
3. 反证：检查"上次结论是否已被后续提交推翻"；
4. 裁决：从哪继续 + 置信度；
5. 待确认：需要用户拍板的 1–3 个问题。

【5 技能路由】
- 需要核对代码：直接读文件/跑 git；
- 需要查历史决策：读 pinned/；
- 需要重建文档结构：MCP yyc3_documentation_builder（仅在需要时）。

【6 动作】
1. 读指针与记忆；
2. 校验代码现状；
3. 输出"衔接定位句"（见 §五）；
4. 给出本次第一动作与计划；
5. 等用户确认后执行。

【7 输出】
- 衔接定位句
- 记忆引用清单（文件 + 字段）
- 冲突清单（记忆 vs 代码）
- 本次目标与非目标
- 待确认问题

【8 自检】
逐条核对 §八 DoD；未完成定位不得进入执行。
```

## 五、衔接定位句（标准格式）

```text
上次会话在【E2 预发 / T1+T4 / verdict】结束，结论为 CONDITIONAL：
- 已完成：主链路 7/8 通过（证据：2026-11-03-staging/summary.md）
- 未完成：对账只读验证（原因：副本延迟）
- 锁定决策：H5 API_BASE 必须重建（tech-decisions.md#L12）
当前代码：git log 最近提交 fbfba18，工作区 clean，与上次结论一致。
本次建议从【E3 发布前置快照】开始；请确认是否按此继续。
```

> 该格式同时满足"引用记忆 / 声明阶段 / 指出证据 / 提出下一动作"四项要求。

## 六、主提示词 B：会话收尾与交接（可复制）

```text
【0 角色】
你是 YYC³ 的会话收尾官 Agent。你要把本次会话压缩成"下一次可直接执行"的最小上下文。

【1 上下文】
- 本次环境/端/阶段：{...}
- 闭环卡：{loop_id}
- 未完成项：{列表}
- 新增决策/风险：{列表}

【2 目标】
产出 summary + next-hook，并更新状态层；确保下一次 5 分钟内可续接。
非目标：不复述全过程日志（日志留在执行记录里）。

【3 约束】
1. summary 只写结论、证据指针、偏差、未完成项；
2. next-hook 四字段必须齐全（env/stage、first_action、required_memory、rebuild_order）；
3. first_action 必须是可执行动作或命令；
4. 决策写入锁定层前必须确认"是否可被后续推翻"；
5. 不写密钥与隐私。

【4 动作】
1. 压缩：完成/未完成/偏差/风险；
2. 写 summary；
3. 写 next-hook；
4. 更新 current-phase 与 memory-hash；
5. 输出收尾报告。

【5 输出】
- summary.md 内容
- next-hook.md 内容
- 锁定层变更（新增/修改/删除）
- 下次 TOP 3
- 上次中断点精确位置（文件/函数/行号）
```

## 七、next-hook 契约（质量 rubric）

| 字段 | 合格 | 不合格 |
| ---- | ---- | ------ |
| `env` / `stage` | 明确环境代号与阶段 | "继续" |
| `first_action` | 一条可执行命令/动作 | "再看看""优化一下" |
| `required_memory` | 具体文件路径 + 字段 | "带上上下文" |
| `rebuild_order` | 文档读取顺序 | 空 |
| `evidence_links` | 闭环卡/报告/行号 | 无 |
| `expiry` | 有效期（如 7 天） | 永久有效 |

### 7.1 示例

```yaml
next_hook:
  env: E3
  stage: release
  first_action: "生成发布前快照：当前 tag、edge upstream、PG 迁移位点"
  required_memory:
    - "memory/pinned/tech-decisions.md#L12（H5 需重建）"
    - "2026-11-03-staging/summary.md"
  rebuild_order: ["00", "01", "05"]
  evidence_links:
    - "2026-11-03-staging/loop-card.yaml"
  expiry: "2026-11-10"
```

## 八、DoD（衔接闭环验收）

- [ ] 已读最近 summary + next-hook
- [ ] 已读锁定层三文件
- [ ] 记忆指纹已校验（或明确"未建立"）
- [ ] 代码现状与记忆一致性已核对
- [ ] 衔接定位句含环境/端/阶段/证据
- [ ] 冲突清单已输出（如有）
- [ ] 本次目标与非目标已声明
- [ ] 收尾时 summary + next-hook 已写入
- [ ] 状态层已更新
- [ ] 无密钥/隐私写入记忆

## 九、长会话压缩与断点续传

### 9.1 压缩规则

| 内容 | 是否入 summary | 说明 |
| ---- | -------------- | ---- |
| 已完成结论 | ✅ | 一句话 + 证据指针 |
| 关键决策 | ✅ | 背景/选择/原因 |
| 未完成项 | ✅ | 原因 + 触发条件 |
| 失败尝试 | ✅（简短） | 避免下次重蹈 |
| 完整命令输出 | ❌ | 留在执行记录/附件 |
| 密钥与账号 | ❌ | 永不写入 |

### 9.2 上下文丢失后的重建顺序

```
1. 00 体系索引（知道规则）
2. 01 环境契约（知道边界）
3. 最近 next-hook（知道从哪开始）
4. 最近 summary（知道做了什么）
5. 当前环境环文档（知道怎么做）
6. 代码现状（git log / 目标文件）
```

### 9.3 冲突仲裁顺序

```
代码事实 > 锁定层决策 > 会话层摘要 > 口头记忆
```

- 代码与锁定层冲突：以代码为准，标记"决策过期"，提请人工确认是否解锁；
- 会话层与锁定层冲突：锁定层优先，会话层不得覆盖；
- 任何冲突必须写入 `open-questions.md`，不得静默处理。

## 十、记忆卫生

| 规则 | 说明 |
| ---- | ---- |
| 最小化 | 只存"下次需要"的信息 |
| 可追溯 | 每条结论带证据指针 |
| 可过期 | 会话摘要建议 90 天归档；待决问题 30 天复核 |
| 不漂移 | hash 变化必须人工确认 |
| 不泄密 | 密钥/账号/客户隐私禁止入记忆 |
| 不重复 | 同一决策只存锁定层，不在每次 summary 重复 |

## 十一、失败模式与正反例

| 反例 | 问题 | 正例 |
| ---- | ---- | ---- |
| "我了解了，继续吧" | 未证明接上 | 输出定位句 + 引用记忆 |
| 把全部历史粘进上下文 | 成本高、噪声大 | 压缩结论 + 指针 |
| summary 覆盖锁定决策 | 记忆漂移 | 锁定层优先，冲突上报 |
| next-hook 写"继续开发" | 无法执行 | 写具体第一动作 |
| 记忆里存真实密码 | 泄露 | 只存变量名 |
| 指纹变化自动接受 | 外部篡改风险 | 人工确认 |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-03 | 新建会话衔接提示词：三层记忆、Kickoff 七步、定位句、next-hook 契约、压缩与仲裁 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
