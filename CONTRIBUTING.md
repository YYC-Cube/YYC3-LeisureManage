---
file: "CONTRIBUTING.md"
description: "YYC³ LeisureManage 贡献指南(团队权威框架 + 项目专属段:文档库工作流/规划文档修订规则/工程落位约定)"
author: "YanYuCloudCube Team <admin@0379.email>"
version: "v1.0.0"
created: "2026-11-01"
updated: "2026-11-01"
status: "active"
license: "MIT"
tags: [community, contributing, workflow]
category: governance
---

# 贡献指南（CONTRIBUTING）

> ***YanYuCloudCube*** · *言启象限 | 语枢未来*
> 感谢你为 YYC³ 家族项目贡献力量！请先阅读 [行为准则](CODE_OF_CONDUCT.md)；安全问题按 [安全政策](SECURITY.md) 私下报告。

---

## 🌿 分支与 PR（团队铁律）

| 类型 | 格式 | 示例 |
| ---- | ---- | ---- |
| 功能 | `feat/<scope>-<简述>` | `feat/session-billing-engine` |
| 修复 | `fix/<scope>-<简述>` | `fix/badge-no-unique` |
| 文档 | `docs/<简述>` | `docs/independent-operation-ruling` |

- **`main` 分支受保护：禁止直接 push，一律走 PR**（CI 检查即保护策略要求；用 `--auto` 合规挂自动合并，不使用 `--admin` 绕过）
- 一个 PR 聚焦一个主题；避免混入无关格式化改动
- 合并方式：**Squash Merge**（保持线性历史）
- 未经仓库所有者指示，不执行 `git push --force`

### PR 自检清单

- [ ] 动机与影响面写清楚（Why > What）
- [ ] 项目质量门禁全绿（CI 必过，失败不合并）
- [ ] 无「空断言」或「恒真断言」；未实现能力显式跳过并写明原因
- [ ] 文档相对链接可达，无死链
- [ ] 无密钥、Token、真实生产数据

---

## 🔄 开发工作流（PDCA+）

1. **Plan**：明确目标与验收标准；结构性变更先在 `docs/` 立项
2. **Do**：小步提交，一个 commit 聚焦一件事
3. **Check**：跑通项目质量门禁
4. **Act**：不通过则修复；通过则更新执行记录
5. **Archive**：总结变更并留下衔接上下文

### 提交信息（Conventional Commits）

```text
<type>(<scope>): <subject>

[body: 为什么改，而非改了什么]
```

- type：`feat` / `fix` / `docs` / `refactor` / `test` / `chore` / `perf` / `ci`
- scope（本项目）：`docs` / `prd` / `arch` / `api` / `db` / `prompt` / `community` / `ci`

---

## ✅ 质量门禁通则

| 检查项 | 标准 |
| ---- | ---- |
| CI 全量门禁 | 全绿；任一用例失败即不合并 |
| 显式跳过 | 必须带原因，禁止静默跳过掩盖缺陷 |
| 文档链接 | 相对链接检查，无死链 |
| 敏感信息 | 无 `.env`、密钥、Token、真实生产数据 |
| 结果如实 | 门禁产物不可手工伪造；失败如实上报，不谎报通过 |

### 文档规范

- YAML Front Matter 必填：`file` / `description` / `version` / `created` / `status`
- 术语以各项目《命名注册表》为准；禁用历史旧称
- 品牌规范：文档顶图 `public/yyc3-family.png`、shields 家族徽章、文末四行署名块
- 敏感信息使用占位符：`${ENV_VAR}` 或 `[REDACTED]`

---

## 🧩 项目专属段（YYC3-LeisureManage）

### 仓库性质与结构

本仓库当前为**规划文档库**（docs-driven），工程设计已完备、代码工程按六阶段落位（见 `docs/YYC3-LeisureManage-项目规划/PROMPT-新会话-全栈开发落地.md`）：

```text
YYC3-LeisureManage/
├── docs/
│   ├── YYC3-LeisureManage-项目规划/     # 00 需求全集 + 01–11 工程规划 + PROMPT(核心)
│   └── YYC3-团队通用-标准规范/          # 团队标规随仓副本(参照,修订以团队真身为准)
├── public/                              # 品牌资产(yyc3-family.png 顶图/图标)
├── .github/workflows/ci.yml             # 文档门禁 CI
├── LICENSE / CODE_OF_CONDUCT.md / CONTRIBUTING.md / SECURITY.md
└── README.md
```

代码工程**不在本仓库**，落位于姊妹仓 `YYC3-DeepStack-Matrix`（pnpm workspace）：

| 工程 | 位置 | 说明 |
| ---- | ---- | ---- |
| `@yyc3/leisure-core`（已建） | `packages/leisure-core/` | 领域单源包：营业日/台费引擎/前置校验/枚举/API Client——四端唯一事实源，**任何端禁止复制实现** |
| `leisure-api` | `services/leisure-api/` | NestJS 10 后端 |
| `app-leisure-web` | `apps/app-leisure-web/` | React 19 Web 管理端 + PWA |
| `app-mp-artist` | `apps/app-mp-artist/` | Taro 4 销售经理小程序 |

### 规划文档修订规则（重要）

- **修订头模式**：对既有规划文档的裁决/口径变更，不整篇重写——在文档头部追加 `> 版本:vN.N(日期 裁决修订)|变更摘要` 行，并对涉及段落做精准替换；历史版本行保留
- **需求 vs 工程**：`YYC3-LeisureManage.md`（需求全集）与 01–11（工程规划）冲突时，以**最新裁决修订头**为准并在两文档互相引用说明
- **定位红线（2026-11-01 裁决）**：本系统为独立运营的多门店系统，**完全脱离「智慧商家」体系**——不得引入任何主系统集成/联动需求；"实测依据"仅作为历史需求来源表述保留

### 本地门禁命令

```bash
# 文档门禁(对齐 CI):四件套在位 + Front Matter 必填 + 规划目录导览链接可达
bash scripts/verify-docs.sh
```

### 安全敏感变更清单

涉及以下内容的 PR 需维护者额外评审：资金流水规则（只增不改/审批阈值）、身份证等敏感个人信息处理、支付渠道回调、权限矩阵（RBAC 功能码）、以及任何包含第三方商业系统界面/数据的取样内容（**严禁**，测试数据一律合成）。

---

## 🆘 需要帮助

- 问题反馈：[GitHub Issues](https://github.com/YYC-Cube/YYC3-LeisureManage/issues)
- 联系邮箱：<admin@0379.email>

> 「***YanYuCloudCube***」 · **© 2025-2026 YanYuCloudCube™. All Rights Reserved.**
