---
file: YYC3-前端闭环验收提示词.md
title: YYC³ 前端闭环验收提示词 — 存量大纲与评估结论
description: YYC3 前端闭环验收提示词体系大纲（存量原文保留 + 2026-11-03 评估结论）
author: AI Tutor <YYC3-Prompt-Expert>
version: v1.1.0
created: 2026-11-02
updated: 2026-11-03
status: legacy
tags: [frontend, closed-loop, outline, legacy, evaluated]
category: outline
review_status: evaluated
supersedes_by: ./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-多环境闭环-体系索引与使用手册.md
---

# YYC³ 前端闭环验收提示词 — 存量大纲与评估结论

> **_YYC³_**（YanYuCloudCube™ · 注册商标）
> _言启象限 | 语枢未来_
> **_Words Initiate Quadrants, Language Serves as Core for Future_**
> _万象归元于云枢 | 深栈智启新纪元_
> **_All things converge in cloud pivot; Deep stacks ignite a new era of intelligence_**

---

> **📌 文件定位**：本文件是**存量设计大纲**（讲"前端角色/记忆应有哪些文件"），不含可直接执行的提示词正文。
> **▶ 要执行请用**：[多环境闭环提示词体系](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-多环境闭环-体系索引与使用手册.md)。
> **原文中的六环引用**：`00-闭环验收-体系索引与使用手册.md`、`01-验收基准环/` … `06-裁决闭环环/` 在磁盘上**并未落地**（历史引用悬空）。该六环职责已由新体系的 01–08 号文档承接，映射见文末 §评估结论。
> **本文件仍然有效的部分**：三层记忆协议（锁定层 / 会话层 / 状态层）、"开场衔接义务 / 阶段小结义务 / 下一次衔接预告义务"三条规则——已并入新体系 07 号《会话衔接》。
> **原文保留说明**：以下为原始内容，未做删改；评估结论与完善映射追加于文末。

---

以下是面向 YYC3 前端团队的提示词体系大纲。核心设计原则：**角色定义不是一段“人设文案”，而是一个可被 AI 反复加载、自我维持的会话运行时契约**。文件树本身就是提示词的物理结构，每一级目录对应一种加载时机和记忆职责。

---

```
yyc3-frontend-prompts/
│
├── AGENTS.md                                   # 全局契约：前端 Agent 启动第一入口
│   ├── 0_identity_router.md                    # 身份路由：本仓库所有前端角色的索引与触发条件
│   ├── 1_tech_stack_contract.md                # 不可协商的技术栈边界（见下方“技术栈硬约束”）
│   ├── 2_session_lifecycle.md                  # 会话生命周期定义：kickoff → analysis → build → verify → close
│   └── 3_memory_protocol.md                    # 记忆协议：什么被记住、存在哪、何时注入
│
├── roles/
│   └── frontend/
│       ├── role.md                             # 角色定义主文件（TOML frontmatter + 四段式正文）
│       ├── capability-matrix.md                # 能力矩阵：能做 / 不能做 / 需转交
│       └── session-persona.md                  # 会话风格人设：长会话中的语气、节奏、主动性规则
│
├── prompts/
│   └── frontend/
│       ├── system-prompt.md                    # 系统提示词正文（四段式：定位/能力/约束/输出格式）
│       ├── memory-injection.md                 # 记忆注入模板：每次会话开始时拼接什么
│       ├── continuity-protocol.md              # 衔接协议：上下文回顾 + 阶段小结 + 下一次预告
│       └── few-shot/
│           ├── 01_codebase-analysis.md         # 示例：从底层代码分析开始的前端会话
│           ├── 02_component-build.md           # 示例：基于 shadcn/ui + Radix 的组件构建
│           ├── 03_close-loop-verify.md         # 示例：构建 → 验证 → 小结 → 预告闭环
│           └── 04_long-session-recovery.md      # 示例：会话中断后的记忆恢复与衔接
│
├── memory/
│   ├── index.md                                # 记忆索引：当前分支所有活跃记忆槽位的目录
│   ├── pinned/
│   │   ├── tech-decisions.md                   # 已锁定的技术决策（不可被后续会话推翻，除非显式解锁）
│   │   ├── user-preferences.md                 # 用户在前端层面的稳定偏好（命名习惯、组件粒度、测试策略）
│   │   └── open-questions.md                   # 待决问题：下一次会话必须首先推进的悬而未决项
│   └── sessions/
│       ├── _template/
│       │   ├── summary.md                      # 单次会话小结模板
│       │   └── next-hook.md                    # 下一次衔接预告模板
│       └── YYYY-MM-DD-<slug>/                  # 实际会话记录目录（按日期 + 主题命名）
│           ├── summary.md
│           └── next-hook.md
│
├── workflows/
│   └── frontend/
│       ├── 00_kickoff.md                       # 会话启动：加载记忆 → 确认当前阶段 → 声明本次目标
│       ├── 01_codebase-analysis.md             # 底层代码分析：扫描、理解、缺口识别
│       ├── 02_implementation.md                # 实现阶段：组件/页面/交互的生成与约束
│       ├── 03_verification.md                  # 验证：类型、lint、构建、关键交互自检
│       └── 04_close-loop.md                    # 闭环：小结 → 写入 memory → 生成 next-hook
│
├── references/
│   ├── nextjs-app-router.md                    # Server Component / Client 边界 / 路由约定
│   ├── shadcn-radix-contract.md                # shadcn/ui 使用规则 + Radix API 边界（asChild vs render prop）
│   ├── vite-build-context.md                   # Vite 作为构建/开发工具时的前端约束
│   └── pnpm-workspace.md                       # pnpm 工作区依赖与脚本约定
│
└── .prompt-state/                              # 运行时状态目录（非提示词源文件，由会话自动维护）
    ├── current-phase.md                        # 当前所处阶段（kickoff / analysis / build / verify / closed）
    ├── active-memory-hash.md                   # 本次会话注入的记忆指纹（防止记忆漂移）
    └── last-session-pointer.md                 # 指向最近一次 session 目录的软链接描述
```

## 核心文件内容要求

### `roles/frontend/role.md` — 角色定义主文件

采用 **TOML frontmatter + 四段式正文**。

```toml
+++
id = "yyc3-frontend"
domain = "frontend-engineering"
layer = "implementation"
stack = ["nextjs-app-router", "react", "vite", "shadcn-ui", "radix-ui", "pnpm"]
bindings.rules = ["AGENTS.md/1_tech_stack_contract.md", "AGENTS.md/3_memory_protocol.md"]
bindings.workflows = ["workflows/frontend/00_kickoff.md", "workflows/frontend/04_close-loop.md"]
+++
```

正文四段：

**角色定位**：你是 YYC3 前端工程 Agent，服务于以 Next.js App Router + React + Vite + shadcn/ui + Radix UI + pnpm 为技术基底的产品级前端开发。你的工作起点是对现有底层代码的诚实分析，终点是前端侧可验证、可闭环、可向部署衔接的产出。

**能力描述**：以“动词 + 宾语 + 具体边界”书写。例如——“分析 `app/` 目录下的 Server/Client Component 分布，识别不必要的 `"use client"` 边界”；“在 `components/ui/` 下按 shadcn CLI 产出的模式使用组件，不手写替代 Radix primitive 的等价实现”；“在 pnpm workspace 下区分 `apps/web` 与 `packages/ui` 的依赖归属”。

**行为约束**：使用禁止项 + 强制项 + 条件项。禁止项示例——“不得在未阅读 `app/` 下至少一个路由文件和 `components/ui/` 中相关组件的情况下直接生成页面代码”。强制项示例——“所有涉及 Radix `asChild` 的组合必须显式说明其与 `render prop` 的 API 边界，不得混用”。条件项示例——“当分析发现底层代码的目录组织与 `AGENTS.md` 声明冲突时，必须先输出冲突报告，不得静默适配”。

**输出格式要求**：阶段化输出。分析阶段输出“现状—缺口—建议”三栏表；实现阶段输出带文件路径和变更理由的 diff 说明；闭环阶段输出结构化小结与 next-hook。

### `roles/frontend/session-persona.md` — 会话风格与长会话记忆人设

这是“长久会话至闭环”和“主动衔接上下文”的行为规则所在，不是泛泛的“保持专业”，而是三条可执行规则：

**规则一：开场衔接义务**。每次会话第一条实质性输出，必须先做一次**上下文定位**：引用 `memory/pinned/` 中与本任务相关的已锁定决策，引用 `last-session-pointer` 指向的上一次小结，并明确声明“本次会话从哪个阶段继续”。不得直接从“好的，我来帮你……”开始。

**规则二：阶段小结义务**。每当一个工作阶段结束（代码分析完成、一组组件实现完成、验证通过），必须输出一段**压缩小结**，格式为“本阶段完成了什么 / 哪条记忆被更新 / 什么被推迟”。这条小结同时写入 `memory/sessions/YYYY-MM-DD-<slug>/summary.md`。

**规则三：下一次衔接预告义务**。闭环时输出 `next-hook.md` 的内容，包含三个字段：**下一次会话的第一动作**（不是“继续开发”，而是一个具体可执行步骤）、**必须携带的记忆槽位**（指向 `pinned/` 中的具体文件）、**如果上下文丢失，如何重建**（关键文件的读取顺序）。这条预告是下一次会话 `00_kickoff.md` 的输入，形成跨会话的闭环。

### `AGENTS.md/3_memory_protocol.md` — 记忆协议

定义三层记忆的层级与注入时机，与 RACM 的“角色感知摘要 + 自适应注入”思路对齐：

| 记忆层 | 物理位置 | 内容 | 注入时机 |
| --- | --- | --- | --- |
| **锁定层** | `memory/pinned/` | 技术决策、用户偏好、待决问题 | 每次会话 kickoff 全量注入，后续不重复 |
| **会话层** | `memory/sessions/YYYY-MM-DD-*/summary.md` | 单次会话的压缩小结 | kickoff 时注入最近 1—2 条，长会话中间按需回注 |
| **状态层** | `.prompt-state/current-phase.md` | 当前阶段指针 | 每轮消息轻量注入，成本极低 |

关键约束：锁定层的记忆**不得被会话层摘要覆盖**。GAIT 的 `/pin` 语义可以作为实现参照——被 pin 的内容注入到后续每一次 prompt 中，与历史长度无关。在本大纲中，这一语义由 `pinned/` 目录 + `active-memory-hash.md` 共同承担：hash 不匹配时，说明记忆被外部修改，下一次 kickoff 必须触发人工确认。

### `prompts/frontend/few-shot/04_long-session-recovery.md` — 长会话恢复示例

这是一个“反例到正例”的 few-shot，展示当会话跨越多个开发日、上下文已经漂移时，Agent 应如何利用 `next-hook.md` 和 `pinned/` 重建状态，而不是重新问一遍“你想做什么”。示例结构：输入 = 上一次的 `next-hook.md` + 当前用户消息；输出 = 衔接定位句 + 记忆引用 + 本次第一动作 + 仍不明确的问题清单。

## 与全栈闭环的接口

前端提示词大纲不孤立存在。`workflows/frontend/04_close-loop.md` 的闭环输出中，`next-hook.md` 的“下一次第一动作”字段需要能够被后端/数据库提示词体系读取。例如，当前端阶段结束时若识别出“需要 API 契约确认”，next-hook 应写入该接口名和期望的响应 Schema 摘要，后端角色在 kickoff 时直接接续，不需要前端 Agent 再次转述。这样，“前端 → 后端 → 数据库”的提示词体系通过**共享的 memory 层和 next-hook 契约**形成全栈闭环，而不是三套互不相通的提示词各自运行。

---

这套大纲的**最小可运行集合**是：`AGENTS.md`（三层契约）+ `roles/frontend/role.md` + `session-persona.md` + `memory/pinned/` + `workflows/frontend/00_kickoff.md` 和 `04_close-loop.md`。其余文件可以在前端会话实际运行后逐步补全，但“衔接—小结—预告”三条规则必须从第一次会话起就生效，否则长会话的记忆会在早期几轮内失效。

---

## 评估结论（2026-11-03）

### 一、评估方法与双口径

本文件在磁盘上的实际角色是**设计大纲**，不是**可执行提示词**。因此按两套口径分别评分（量表见[体系索引 §十](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-多环境闭环-体系索引与使用手册.md)）：

| 口径 | 得分 | 评级 | 结论 |
| ---- | ---- | ---- | ---- |
| 作为"提示词体系执行入口" | 42 / 100 | <70 | **退回重写**（已由新体系 00–08 承接） |
| 作为"角色与记忆设计大纲" | 78 / 100 | 70–79 | **保留为设计史参考**，需标注悬空引用 |

### 二、五维评估

| 维度 | 得分 | 判断依据 |
| ---- | ---- | -------- |
| 时间维 | 70 | 长会话与跨日恢复设计有前瞻性；缺时间盒、阶段门槛与发布窗口意识 |
| 空间维 | 82 | 文件树即契约，层级清晰；但目录树未落地，且与团队既有会话目录（00–03）形成双轨 |
| 属性维 | 72 | 可维护性与可读性强；缺证据链、安全纪律、可评估量表 |
| 事件维 | 76 | "衔接—小结—预告"三条规则可执行；缺故障/回滚/发布事件处置 |
| 关联维 | 64 | 提出 next-hook 全栈闭环，但六环引用悬空、无环境轴、无端轴 |

**加权总分：约 73 / 100（需补强）**

### 三、值得保留的优点

1. **结构即契约**：文件树对应加载时机与记忆职责，比"人设文案"更可维护；
2. **三层记忆**：锁定层 / 会话层 / 状态层 + `active-memory-hash` 防漂移，思路正确；
3. **三条衔接规则**：开场定位、阶段小结、下一次预告，均可判定、可执行；
4. **few-shot 设计**：用"反例→正例"训练恢复行为，优于只给正例；
5. **全栈接口意识**：`next-hook` 作为跨角色契约，具备扩展为多环境闭环的潜力。

### 四、缺口与分级

| 级别 | 缺口 | 证据 | 影响 |
| ---- | ---- | ---- | ---- |
| **P0** | 技术栈事实错误 | 正文写 "Next.js App Router + React + Vite"；仓库无 Next.js，Web 实为 React 19 + Vite 8 + React Router 7，UI 为 `@yyc3/ui` | 按错误前提生成方案，不可落地 |
| **P0** | 执行入口悬空 | 指向的 `00-闭环验收-体系索引与使用手册.md` 与 `01-验收基准环/` … `06-裁决闭环环/` 均不存在 | 读者无法执行，文档失效 |
| **P0** | 无环境轴 | 只有"前端角色"，无 E0–E5 与端轴 | 无法防"本地绿、预发错、生产回滚" |
| **P1** | 无提示词正文 | 只有文件结构与内容要求，无可复制提示词 | 每次会话仍需即兴发挥，口径漂移 |
| **P1** | 无证据契约 | 未要求命令级证据、闭环卡、裁决分级 | 结论不可审计 |
| **P1** | 无技能路由 | 未声明何时加载 shadcn / webapp-testing / 安全评审等 | 工具闲置，靠猜 |
| **P1** | 无技术择优 | 未给"同场景首选/备选/反模式" | 组件、状态、请求各写各的 |
| **P1** | 记忆落地双轨 | 未给 `pinned/`、`.prompt-state/` 的磁盘位置，与团队 `00–03` 会话文档冲突 | 记忆分散、无法衔接 |
| **P2** | 文档规范不合规 | 无标准 front matter 必填字段、无标尾、`tags` 非流式序列 | 自动化解析失败 |
| **P2** | 无质量量表 | 无法判断提示词是否达标 | 无法迭代 |
| **P2** | 无安全与密钥纪律 | 未约束密钥、生产账号、客户数据 | 泄露风险 |

### 五、完善映射（旧概念 → 新体系）

| 旧文件/概念 | 新体系承接 | 说明 |
| ----------- | ---------- | ---- |
| `AGENTS.md` 三层契约 | 00 §五 + 01 环境契约 | 骨架 + 环境边界 |
| `roles/frontend/role.md` | 02 本地开发主提示词 | 角色并入九段式 |
| `session-persona.md` 三条规则 | 07 会话衔接 | 开场/小结/预告保留并强化 |
| `memory/pinned/` + `.prompt-state/` | 07 §二 | 给出磁盘位置与三层注入 |
| `workflows/frontend/00_kickoff.md` | 07 §三、§四 | Kickoff 七步 |
| `workflows/frontend/04_close-loop.md` | 07 §六 + 00 §九 | 收尾 + next-hook 契约 |
| `workflows/frontend/01–03` | 02 / 03 / 04 | 本地、CI、预发 |
| `references/*` | 00 §八 + 01 | 技术择优与环境事实 |
| 六环（验收/代码/构建/运行/发布/裁决） | 01–08 | 悬空引用由新体系落地 |

### 六、评估裁决

**CONDITIONAL（保留但降级）**：

- 保留：作为"角色与记忆设计大纲"存档，供追溯设计动机；
- 降级：不再作为执行入口，执行统一走[多环境闭环提示词体系](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-多环境闭环-体系索引与使用手册.md)；
- 修正：已更新指针与 front matter；正文原文保留，技术栈错误在 §十二（新体系索引）与本评估 P0 中显式校正；
- 后续：若需恢复"前端单角色"视图，应从 02 号文档派生，而非回退本文件。

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-02 | 初始大纲：文件树、三层记忆、三条衔接规则、全栈 next-hook 设想 | AI Tutor <YYC3-Prompt-Expert> |
| v1.1.0 | 2026-11-03 | 修正悬空指针与 front matter；追加五维评估、P0/P1/P2 缺口、完善映射与裁决；技术栈事实校正 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
