# NAS 45 恢复后写路径回归清单(2026-11-17 事故配套 Runbook)

> 适用场景:NAS 45(生产主库宿主)掉线事故恢复后(物理恢复或 promote-22 切换后),对生产写路径做最小回归。
> 前置:`bash scripts/deploy-prod.sh` 链路探针通过;生产 API :3002 应答;本清单逐项打勾留痕(008 回写)。

## A. 恢复确认(三探)
- [ ] `nc -z 100.65.172.88 5433` 可达(或 promote 后本机 5433 为主)
- [ ] `prisma migrate status`(OWNER)up to date——掉线期间无人写库,应无漂移;若有=人工核对
- [ ] 生产 API 日志(prod-*.log)无持续 P1001/连接错误;登录接口 401(而非 50000)=查库恢复

## B. 写路径回归(登录/点单/开房各一笔;生产数据,真实账号)
- [ ] **登录**:管理端账号登录成功(code=0;非 50000)
- [ ] **点单**:任一 OPEN 房账下一笔测试单(self-orders POST;或经 web 房卡点单)→ PLACED 落库 → 队列可见 → 送达
- [ ] **开房**:任一 FREE 房开房(绑签到艺人)→ session OPEN 落库 → 房卡消费中 → 关房结算 CASH
- [ ] **客资跟进**(可选加验):快录客资 → 记跟进 → 时间线可见
- [ ] 日切 job 下一轮 tick 正常(job_run_log 新 OK 行;客资日报/履约提醒照常)

## C. 挂起批补发(恢复后一条链)
- [ ] deploy-prod(API:履约深化批 OrderFulfillmentJob 双档+lm_db_up)
- [ ] web build+rsync → 公网 index hash 双域一致
- [ ] H5 TARO_APP_API_BASE=prod build+rsync → **/m/** 内容核验(chunk 含新页字串)
- [ ] 双域 401 守卫 + lm_db_up=1(metrics)
- [ ] 三端推送补齐:NAS GitBucket(f4e4426+)+NAS 文档仓快照

## D. 预案沉淀到位确认
- [ ] deploy-prod 首步探针已实测(离线时正确拒绝)
- [ ] Mac watchdog launchd 已装载(`launchctl list | grep nas45`)且状态翻转通知实测
- [ ] NAS prometheus seed:leisure-db.rules.yml 已入 0379-World seed 源(NAS 恢复后 reseed 生效:拷至 NAS prometheus rules 目录+main yml rule_files 注册)
- [ ] promote-22.sh 若已执行:45 恢复后按脚本尾「回切」节降级回从(窗口期)

---
*本清单=2026-11-17 NAS45 掉线事故(008 🚨节)配套;执行记录回写 008。*
