# 04 · API 接口设计

> 版本:v1.1(2026-11-01 裁决修订)|**定位裁决:独立运营,完全脱离「智慧商家」**——/integration/sync 主系统同步接口废止;/artist-orders 由"镜像"改为自有订单
> 版本:v1.0(2026-11-01)|风格:REST + JSON;前缀 `/api/v1`;鉴权 Bearer JWT(管理端)/ wx session(艺人端)
> 通用响应:`{ code:0, msg:"ok", data:{} }`;错误码见文末;列表通用参数 `page,pageSize,storeId`(管理端)

## 0. 通用约定

- **幂等**:所有资金/单据写接口须带 `Idempotency-Key` 头(同 key 24h 内返回首次结果)
- **营业日**:服务端计算并回传 `businessDate`;客户端不得自传
- **打印/导出**:列表接口均支持 `format=xlsx|pdf`(对齐实测系统"打印"按钮)

## 1. 认证 auth

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | /auth/admin/login | 管理端登录(手机号+密码)→ JWT+角色功能码 |
| POST | /auth/wx/login | 艺人端 wx.login code → session;若未绑定返回 NEED_BIND + bindToken |
| POST | /auth/wx/bind | 凭 bindToken+档案校验绑定 openid;命中唯一性冲突走转移工单 |
| POST | /auth/logout | — |
| GET | /auth/me | 当前用户+权限码 |

## 2. 档案 artist

| 方法 | 路径 | 说明(实测对齐) |
|---|---|---|
| GET | /artists | 列表:筛选 groupId/levelId/status/keyword(姓名/艺名/腰牌号);分页 |
| POST | /artists | 新增(94 字段按域分块提交);校验:腰牌号唯一/组别等级存在 |
| GET | /artists/{id} | 详情(身份证/照片走脱敏+签名URL) |
| PUT | /artists/{id} | 更新(变更审计前后值) |
| DELETE | /artists/{id} | 软删(有流水者禁删→409) |
| POST | /artists/batch-update | 批量设置(等级/组别/状态) |
| POST | /artists/transfer | 跨店转移工单(确认后执行;留删除日志) |
| GET/POST/PUT/DELETE | /artist-groups[/{id}] | 组别 CRUD+员工增减(PUT /artist-groups/{id}/members) |
| GET/POST/PUT/DELETE | /artist-levels[/{id}] | 等级 CRUD+员工增减 |
| GET | /artists/{id}/dashboard | 艺人个人页数据(照片/等级/标签/台费余额/台票/近期评价) |

## 3. 考勤 attendance

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | /attendance/qrcode | 现场签到码(内容=带店参的小程序码;支持刷新) |
| POST | /attendance/checkin | 艺人端扫码签到:{reportType}+geo;校验当日未签;写定位 |
| POST | /attendance/checkout | 签退:校验"签到后 N 分钟"(配置);写定位 |
| GET | /attendance/reports | 报备明细:businessDate/groupId/type/keyword;列含地理位置;导出 |
| GET | /attendance/summary | 报备汇总:按 组别×主管 返回 {陪宴,签到,私事,早退,迟到,例假,其他,未报备,签退,汇总} |
| POST | /attendance/manual | 补打卡:{artistId,type,businessDate,reason};审计 |
| GET | /attendance/realtime | 实时看板:各状态计数+名单(Redis);`?groupId=&keyword=` |

## 4. 场次与台费 stagefee

| 方法 | 路径 | 说明 |
|---|---|---|
| GET/POST/PUT/DELETE | /stage-fee-rules[/{id}] | 规则:levelId+roomTypeIds[]+amount;当日已有该房型上钟时禁改(409) |
| POST | /sessions/start | 上钟起表:{artistId,roomId};前置校验:档案限制(总次数/串台数/未签到可上钟配置);写实时状态 |
| POST | /sessions/{id}/finish | 下钟:计算 fee=规则(快照)→生成 SESSION_DEDUCT 流水;若台票抵扣:核销 ticket |
| POST | /sessions/{id}/cross | 串台登记(校验 maxCrossRooms) |
| GET | /sessions | 检索:Tab 参维 `by=artist|room|group` + 状态 `status=all|onstage|cross` + 营业日 |
| POST | /stage-fee/recharge | 充值:{artistId,amount,payChannel=CASH|DOUYIN};现金即落流水;抖音走预下单→回调落流水 |
| POST | /stage-fee/manual-deduct | 手动扣费:{artistId,amount,remark!};≥阈值生成 approval,PENDING 时不落流水 |
| GET | /stage-fee/txns | 流水:type 可空(全)/RECHARGE/SESSION_DEDUCT/MANUAL_DEDUCT;营业日区间+组别+腰牌号/艺名;返回含 totalAmount 汇总 |
| GET | /stage-fee/balance/{artistId} | 台费余额(流水聚合,Redis 缓存) |

## 5. 台票 ticket

| 方法 | 路径 | 说明 |
|---|---|---|
| GET/POST/PUT/DELETE | /ticket-rules[/{id}] | 台票规则 CRUD |
| POST | /tickets/purchase | 购买:{artistId,qty,payChannel};落 BUY 流水 |
| POST | /tickets/use | 核销:{artistId,qty,refSessionId};落 USE 流水 |
| GET | /tickets/txns | type=BUY|USE;结构同台费流水(含 totalAmount) |

## 6. 订单/评价/预约 order

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | /artist-orders | 自有订单查询:orderNo/日期/支付状态/订单类型(独立运营闭环) |
| GET | /reviews | 评价:type/keyword(艺名) |
| GET/POST | /bookings | 预约列表(预约号/时间/包厢/组别/艺名腰牌号)+登记 |
| PUT | /bookings/{id}/status | 状态流转:ARRIVED/CANCELLED/NO_SHOW |

## 7. 展示 showcase

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | /showcase/cast | 投放:{artistId,roomId?,groupId?};实时状态→被选中 |
| POST | /showcase/cast/{id}/end | 撤投放 |
| GET | /showcase/current | 当前投放(控制台/艺人端主页用) |
| GET | /showcase/artist-page/{artistId} | 艺人对外主页数据(脱敏) |

## 8. 报表 report(对齐 PC 10 张)

| 方法 | 路径 | 对齐 PC 报表 |
|---|---|---|
| GET | /reports/stage-fee/deduct-detail | 台费扣款明细 |
| GET | /reports/stage-fee/recharge | 台费充值 |
| GET | /reports/stage-fee/summary | 台费流水汇总 |
| GET | /reports/attendance/detail | 报备明细 |
| GET | /reports/attendance/summary | 报备汇总 |
| GET | /reports/session/detail | 上下钟明细 |
| GET | /reports/session/summary | 上下钟汇总 |
| GET | /reports/supervisor-round | 主管轮台 |
| GET | /reports/ticket/purchase | 台票购买明细 |
| GET | /reports/ticket/use | 台票使用明细 |
| 全部支持 | `format=xlsx|pdf` 导出 | — |

## 9. 系统与审批

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | /approvals[?status=] | 审批列表 |
| POST | /approvals/{id}/decide | 通过/驳回(通过才落对应流水) |
| GET | /audit-logs | 审计检索(管理员) |
| GET | /meta/dict | 字典:报备类型/支付渠道/订单类型/包厢类型(门店自维护) |
| ~~POST~~ | ~~/integration/sync~~ | 已废止(v1.1 裁决:不做主系统同步;开放 API 生态预留) |
| GET | /reports/business-daily | 营业日汇总(daily_summary) |

## 10. 错误码(节选)

| code | 含义 |
|---|---|
| 0 | 成功 |
| 40001 | 未登录/会话过期 |
| 40301 | 无权限(功能码缺失) |
| 40401 | 资源不存在 |
| 40901 | 腰牌号重复 |
| 40902 | 微信已被他店绑定(返回占用门店信息) |
| 40903 | 该房型当日已有上钟,规则禁改 |
| 40904 | 超出允许串台数 / 上台次数上限 |
| 40905 | 签到未满 N 分钟,禁止签退 |
| 40906 | 有流水档案禁止删除(走软删/已停用) |
| 40907 | 包厢房号店内唯一冲突(需求全集 §5.2) |
| 41201 | 审批中,资金操作挂起(202 Accepted) |
| 42901 | 触发限流 |
| 50001 | 支付渠道异常(抖音) |
