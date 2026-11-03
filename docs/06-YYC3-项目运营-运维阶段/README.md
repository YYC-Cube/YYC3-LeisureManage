---
file: README.md
title: YYC³ LeisureManage · 运维文档目录索引
description: YYC3-LeisureManage 生产系统运维文档全集索引——部署架构/变量清单/发布手册/日常巡检/故障排查/多端设计架构/应急预案/未执行与未达项
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-02
updated: 2026-11-02
status: active
tags: [operations, index, deployment, architecture, checklist]
category: 项目运营
language: zh-CN
audience: ops, developers, managers
complexity: intermediate
project: YYC3-LeisureManage
phase: 项目运营-维护阶段
---

# YYC³ LeisureManage · 运维文档目录索引

> **_YYC³_**（YanYuCloudCube™ · 注册商标）
> _言启象限 | 语枢未来_
> **_Words Initiate Quadrants, Language Serves as Core for Future_**
> _万象归元于云枢 | 深栈智启新纪元_
> **_All things converge in cloud pivot; Deep stacks ignite a new era of intelligence_**

---

## 目录职责

本目录存放 YYC³ LeisureManage（销售管理系统）**生产系统运维阶段全量文档**，遵循《YYC³ 团队通用-命名规范》《YYC³ 团队通用-标头标尾》《YYC³ 团队通用-文档闭环》。代码与部署资产真源在 `personal/YYC3-DeepStack-Matrix`（代码仓），本目录承载运维口径（How-to-Run）。

## 文档清单

| 序号 | 文档 | 说明 | 适用对象 |
| ---- | ---- | ---- | ---- |
| 001 | [部署架构与全端链路总览](./001-部署架构与全端链路总览.md) | 双机拓扑/隧道/域名/端口/数据流全图 | 全员 |
| 002 | [生产环境变量完整清单](./002-生产环境变量完整清单.md) | 全量变量逐项说明/生成/轮换/密钥纪律 | ops/dev |
| 003 | [部署与发布手册](./003-部署与发布手册.md) | 首次部署/版本发布/双 API 实例/回退 | ops |
| 004 | [日常运维与巡检手册](./004-日常运维与巡检手册.md) | 日切/备份/对账试点/巡检清单 | ops |
| 005 | [故障排查与已知问题](./005-故障排查与已知问题.md) | 症状→根因→处置（含已踩坑台账） | ops/dev |
| 006 | [多端设计架构与设计体系](./006-多端设计架构与设计体系.md) | Web/H5/小程序/API 四端架构 + --lm-* token 体系 + logo 全端 | dev/design |
| 007 | [应急预案与回退手册](./007-应急预案与回退手册.md) | DB/API/边缘/隧道 四类事故的处置与回退 | ops |
| 008 | [未执行项与未达项清单](./008-未执行项与未达项清单.md) | 全量 Backlog：未执行/未达标/待验收 三级台账 | 全员/验收 |

## 快速入口

- **系统入口**: <https://lm.0379.world>（Web 管理端）· <https://lm.0379.pro>（同配置别名）/ 销售端 H5: `/m/`
- **代码仓**: `personal/YYC3-DeepStack-Matrix`（pnpm monorepo）
- **密钥真值**: `~/.yyc3-keybackup/leisure-prod.env`（600；本机生成器 `scripts/gen-prod-secrets.sh`）
- **文档关联**: 需求全集 V3.1 第十四章《实现状态对照》· 《15-全链路审核与闭环分析》（同仓 `YYC3-LeisureManage-项目规划/`）

---

> ***YYC³ Team*** · © 2026 YanYuCloudCube™（YYC³）
> _万象归元于云枢 | 深栈智启新纪元_
