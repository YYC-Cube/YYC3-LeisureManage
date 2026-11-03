---
file: README.md
title: YYC³ 项目开发-智能协同 — 目录索引
description: YYC³ 智能协同开发目录索引 — 多环境闭环提示词体系（00–08）与存量前端大纲的归档、入口与阅读顺序
author: YYC³ Team <admin@0379.email>
version: v1.0.0
created: 2026-11-03
updated: 2026-11-03
status: stable
tags: [index, prompt, multi-environment, closed-loop, navigation]
category: general
language: zh-CN
audience: developers,qa-engineers,devops,ai-tutors,managers
complexity: basic
project: YYC3-LeisureManage
phase: 项目开发-智能协同
---

# YYC³ 项目开发-智能协同 — 目录索引

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

## 一、目录职责

本目录承载 **AI 协同开发的提示词契约**：把"开发—构建—联调—发布—观测—归档"的全链路，收敛为可加载、可执行、可裁决、可交接的提示词与闭环卡。

> **执行入口**：[多环境闭环提示词体系](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-多环境闭环-体系索引与使用手册.md)

## 二、文档清单

| 序号 | 文档 | 类别 | 状态 | 说明 |
| ---- | ---- | ---- | ---- | ---- |
| 00 | [多环境闭环-体系索引与使用手册](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-多环境闭环-体系索引与使用手册.md) | 总纲 | stable | 环境轴×端轴、七段闭环、九段式骨架、技能路由、闭环卡契约、质量量表 |
| 01 | [环境契约-环境矩阵与准入门禁](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-环境契约-环境矩阵与准入门禁.md) | A 契约层 | stable | E0–E5 矩阵、拓扑、密钥纪律、动作分级与准入卡 |
| 02 | [本地开发-编码自检闭环](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-本地开发-编码自检闭环.md) | B 环境环 | stable | 读码顺序、最小改动、择优矩阵、本地验证 DoD |
| 03 | [持续集成-构建质量闭环](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-持续集成-构建质量闭环.md) | B 环境环 | stable | G1–G6 门禁、红灯分诊、Leisure 专用 CI job 建议 |
| 04 | [预发验证-联调回归闭环](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-预发验证-联调回归闭环.md) | B 环境环 | stable | 跨端联调矩阵、契约核对、四层故障定位、放行裁决 |
| 05 | [生产发布-灰度变更闭环](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-生产发布-灰度变更闭环.md) | B 环境环 | stable | 分级批准、发布前快照、静态/API/DB 发布流、灰度与回退 |
| 06 | [运行观测-监控回滚闭环](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-运行观测-监控回滚闭环.md) | C 横切环 | stable | 判级、五维观测、故障树、回滚矩阵、事件卡 |
| 07 | [会话衔接-记忆契约与跨环境交接](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-会话衔接-记忆契约与跨环境交接.md) | C 横切环 | stable | 三层记忆、Kickoff 七步、next-hook 契约、断点续传 |
| 08 | [裁决归档-验收结论与文档同步](./00-YYC3-项目开发-多环境闭环提示词体系/YYC3-裁决归档-验收结论与文档同步.md) | C 横切环 | stable | PASS/CONDITIONAL/BLOCK、五维记分卡、裁决书、文档同步 |
| — | [前端闭环验收提示词（存量）](./YYC3-前端闭环验收提示词.md) | 设计大纲 | legacy | 保留原文；2026-11-03 追加评估结论、缺口分级与映射 |

## 三、推荐阅读顺序

| 目标 | 顺序 |
| ---- | ---- |
| 首次进入 | 00 → 01 → 07 → 02 |
| 单环境作业 | 00 → 对应环境环 → 08 |
| 全链路发布 | 00 → 01 → 02 → 03 → 04 → 05 → 06 → 08 |
| 事故处置 | 00 → 06 → 01 → 08 |
| 追溯设计动机 | 存量《前端闭环验收提示词》§评估结论 |

## 四、目录不变量

1. 文件夹与文档名使用 ASCII `YYC3`，正文品牌使用 `YYC³`；
2. 每份文档必须含标准 front matter、品牌标头、核心理念与标尾；
3. 每份环境环文档必须含：主提示词、深度思考协议、技能路由、技术择优、输出契约、DoD、反例、next-hook；
4. 任何闭环必须产出闭环卡；任何裁决必须可追溯到证据；
5. 任何密钥只以变量名/占位符出现；
6. 新增文档需在本索引登记，并在文末维护变更历史。

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v1.0.0 | 2026-11-03 | 新建目录索引：登记多环境闭环提示词体系 00–08 与存量前端大纲评估状态 | YYC³ Team |

---

<p align="center">
  <b>YYC³</b>（YanYuCloudCube™ · 注册商标）<br>
  言启象限 | 语枢未来<br>
  <i>Words Initiate Quadrants, Language Serves as Core for Future</i><br>
  万象归元于云枢 | 深栈智启新纪元<br>
  <i>All things converge in cloud pivot; Deep stacks ignite a new era of intelligence</i><br>
  <sub>© 2026 YanYuCloudCube™（YYC³）· <a href="mailto:admin@0379.email">admin@0379.email</a></sub>
</p>
