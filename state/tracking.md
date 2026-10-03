# 每日情报日报 · 状态台账（云端任务读取/写入）

> 云端沙箱每次执行都是全新环境，本地工作目录不保留。
> 本文件是唯一持久状态：**期号台账** + **下期跟踪清单**。
> 每期执行末尾请用 Contents API PUT 回写本文件。

## 固定约定

- 收件人：`yanqing.lu@samsung.com`
- 邮件主题：`每日情报日报 YYYY-MM-DD · TV / Web / AI`
- 产物：`daily-briefing-YYYY-MM-DD.html`（深色 `#0d1117`、卡片式、样式内联、无外部依赖）
- 归档仓库：`denisyq/DailySensingRepo`（分支 main）
- Pages 首页：https://denisyq.github.io/DailySensingRepo/
- 发布方式：**GitHub Contents REST API**，不要尝试 `git push`（代理会拦截 CONNECT，必 502）
- 执行顺序：生成 HTML → GitHub 发布 → 发邮件（邮件正文才能带正确 Pages 链接）
- Pages 新文件详情页通常要 60–120 秒才从 404 变 200，校验要轮询，最多 3 分钟

## 期号台账

| 期号 | 日期 | GitHub | 邮件 | 备注 |
|---|---|---|---|---|
| 试刊 | 2026-09-29 | ✅ | — | 归档首个条目（本地任务） |
| 第 001 期 | 2026-10-01 | ✅ | — | 本地任务 dd9badfc |
| 第 002 期 | 2026-10-03 | ✅ | ✅ | 本地任务 30658e6d；34 条选题 |

**下一期期号：第 003 期**（若本表已更新到更晚日期，请以表内最大期号 +1 为准）

## 下期跟踪清单

- **成本**：DRAM / NAND / eMMC 10 月合约价与 Q4 报价；面板厂（BOE / 华星 / 惠科）Q4 涨价函实际落地幅度；是否有厂商跟进整机提价
- **竞争**：TCL / 海信 Q3 财报与 2027 产品线预告；海信 RGB Mini LED 在 100"+ 的份额变化；Roku 首款 OLED（Pro Series $999 起 / LX $1,299，LX 10 月发货）市场反馈
- **软件**：Chrome 154 是否追加 CVE；Vega OS 2.0 图标 Bug 修复进展；Google TV / Roku OS 版本更新
- **AI**：Kimi K3.1 是否正式发布；阶跃 Step 5 于 10/15 开源；Gemini 4 Argon 是否放开至付费 API 与 Ultra 订阅；加州 AG 与 FTC 调查下一步
- **代工 / License**：TPV 冠捷、MOKA 茂佳、KTC 康冠、兆驰 AMTC 在拉美 / 东欧的产能与 brand license 变动

## 已验证可用信源

- AOMedia 官方规范站（AV2）
- Chrome Releases 官方博客（版本号 + CVE）
- Electron Releases / endoflife.date
- AFTVnews（Fire TV / 流媒体设备）
- camelcamelcamel（价格走势）
- State of the Screens（电视 OS）
- SDMC 官网
- DataLearnerAI / ArtificialWatch（模型榜单）

## 信源规范

Omdia / TrendForce / 群智 / 洛图 / 奥维 等机构数据常只能经二手或 SEO 聚合站获取，
来源字段必须标注「经转载整理」，不得把聚合站伪装成一手媒体。
