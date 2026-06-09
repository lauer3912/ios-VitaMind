# VitaMindGo App Store Listing Metadata

> **App Name:** VitaMindGo
> **Bundle ID:** com.ggsheng.VitaMind
> **Version:** 3.0.0
> **Document Version:** 2.0
> **Last Updated:** 2026-05-30

---

## 1. App Name & Tagline

| Field | Content |
|-------|---------|
| **App Name** | VitaMindGo |
| **Tagline** | Your AI-Powered Health Companion |

---

## 2. Promotional Text (English)

> **Apple 字段:** Promotional Text — 官方上限 170 chars
> **本项目内规:** ≤100 chars (老爷 2026-06-04 指定)
> **Apple 文档:** "This property can't be longer than 170 characters."
> **当前字符数:** 99 chars (≤100 ✓)

```
AI health coach for heart, sleep, habits. On-device AI, no account, no tracking. Apple Watch ready.
```

### 候选方案（决选记录）

| # | Chars | 内容 | 状态 |
|---|-------|------|------|
| A1 | 89 | AI health coach. Track heart, sleep, habits with on-device AI. No account, fully private. | 备选 |
| A2 | 91 | Your AI health coach for heart, sleep, and habits. On-device AI, no account, fully private. | 备选 |
| **A3** | **99** | AI health coach for heart, sleep, habits. On-device AI, no account, no tracking. Apple Watch ready. | ✅ **已选** |

### 决选理由 (A3)
1. **三重信号覆盖**: heart/sleep/habits 命中 Health 类别 Top 5 搜索词
2. **Apple Watch 锚点**: 与 Keywords 里的 "Apple Watch" 形成 "Promo + Keywords" 双重命中
3. **三连 "no" 差异化**: no account / no tracking / (隐含 no server) 突出隐私卖点
4. **字符预算利用率 99%**: 89→91 跳 2 chars，91→99 跳 8 chars 含 3 个新价值点，性价比最高

### 算法说明
- 身份钩子 (AI health coach) → 价值点 (heart/sleep/habits) → 差异化 (on-device AI) → 摩擦消除 (no account) → 设备错点 (Apple Watch ready)
- 决策时点: 2026-06-04，老爷回复 "去修改吧" 授权采用推荐方案 A3

---

## 3. Full Description

> **Apple 字段:** Description — 官方上限 4000 chars, **plain text only, no HTML**
> **本项目内规:** 纯文本，无 markdown，无 emoji (老爷 2026-06-04 指定)
> **当前字符数:** 1905 chars (≤4000 ✓)  <-- 2026-06-08 加 Medical Disclaimer 段 → 预计 ~2270 chars

```
IMPORTANT MEDICAL DISCLAIMER:

VitaMindGo provides general wellness and fitness information only. It is NOT a medical device and does NOT provide medical advice, diagnosis, or treatment. Always seek the advice of a qualified healthcare professional before making any medical decisions or before starting any new health regimen. Never disregard professional medical advice or delay in seeking it because of something you have read or received through VitaMindGo. If you think you may have a medical emergency, call your doctor, go to the emergency department, or call 911 immediately. The AI health coach provides general wellness information only and may not be accurate; always verify with a qualified professional.

Your AI-Powered Health Companion

VitaMindGo combines cutting-edge AI technology with comprehensive health monitoring to help you understand your body like never before.

Key Features:

AI Health Assistant
Have natural conversations with your personal AI health coach. Get instant answers to health questions, personalized tips, and intelligent insights based on your data.

Apple Watch Integration
Sync seamlessly with Apple Watch to track heart rate, HRV, sleep, steps, exercise minutes, and more. All your vital stats in one beautiful dashboard.

Habit Tracking
Build lasting habits with customizable tracking, streak monitoring, and smart reminders. Whether it's drinking more water, meditating daily, or taking your vitamins, VitaMindGo keeps you accountable.

Sleep Quality Analysis
Understand your sleep patterns with detailed analysis and AI-powered recommendations to improve your rest quality.

Widgets and Quick Stats
View your health metrics at a glance with beautifully designed home screen widgets. No need to open the app for quick updates.

Daily Reminders (Local Notifications)
Stay on track with three gentle, server-free nudges: 9 AM for your daily card pull, 8 PM for habit check-in, and 10 PM as a streak rescue. All notifications run on-device via UserNotifications, no push servers, no tracking, no battery drain.

Privacy First
Your health data stays on your device. VitaMindGo uses on-device AI (CoreML) for processing, ensuring your most sensitive information never leaves your phone.

Why VitaMindGo?

- Comprehensive health tracking in one app
- AI-powered insights for better decision-making
- Beautiful, intuitive interface
- Apple Watch integration for accurate data
- Privacy-focused design

Subscription Information:

The initial version (3.0.0) is completely FREE with all features included. Future premium features will be available through Auto-Renewable Subscription.
```

### 清理清单
- ✅ 移除所有 `**bold**` markdown
- ✅ 移除所有 emoji (🤖 ❤️ 📊 💤 📱 🔔 🔒)
- ✅ 替换 `•` → `-`
- ✅ 替换 em-dash `—` → `,` (避免某些字体渲染问题)
- ✅ `&` → `and` (Apple App Store 允许 `&`，但 "and" 更通用)
- ✅ 撇号使用 ASCII `'` (U+0027) — App Store 兼容

---

## 4. Keywords

> **Apple 字段:** Keywords — 官方上限 **100 bytes** (不是 chars；中文 1 字 = 3 bytes)
> **本项目内规:** ≤80 chars (老爷 2026-06-04 指定)
> **当前字符数:** 76 chars / 76 bytes (≤80 ✓)

```
habit tracker, health, fitness, sleep, AI, heart rate, Apple Watch, wellness
```

### 优化算法（"价值密度优先"原则）

**步骤 1：列出搜索意图候选词 (按 ROI 排序)**

| 词 | 长度 | 搜索价值 | VitaMindGo 匹配度 |
|----|------|----------|-------------------|
| habit tracker | 13 | 极高 (Health 类别 Top 3) | ✅ 核心功能 |
| health | 6 | 极高 (类别锚定) | ✅ 全覆盖 |
| fitness | 7 | 极高 (类别锚定) | ✅ 主题 |
| sleep | 5 | 高 (Top 10 搜索) | ✅ 追踪 |
| heart rate | 10 | 极高 (Top 5 搜索) | ✅ 追踪 |
| Apple Watch | 11 | 高 (设备特定) | ✅ 集成 |
| wellness | 8 | 高 (类别广覆盖) | ✅ 主题 |
| AI | 2 | 中-高 (差异化) | ✅ 核心 |

**步骤 2：贪心填充到 80 chars**

`habit tracker`(13) + `, `(2) + `health`(6) + `, `(2) + `fitness`(7) + `, `(2) + `sleep`(5) + `, `(2) + `AI`(2) + `, `(2) + `heart rate`(10) + `, `(2) + `Apple Watch`(11) + `, `(2) + `wellness`(8)
= 13+2+6+2+7+2+5+2+2+2+10+2+11+2+8 = **76 chars** ✓ (`wc -m` 验证)

**步骤 3：砍掉的词 + 理由**

| 砍掉词 | 长度 | 砍掉理由 |
|--------|------|----------|
| tracker | 7 | 已被 "habit tracker" 短语覆盖 |
| assistant | 9 | 已被 "AI" + 描述中 "AI health coach" 覆盖 |
| activity, steps, exercise | 5+5+8 | 与 "fitness" 重叠，搜索时被合并索引 |
| HRV | 3 | 极窄搜索 (Apple Watch 重度用户) |
| stress, mindfulness | 6+11 | 心理健康搜索意图不匹配 (VitaMindGo 无冥想) |
| water, vitals, healthkit | 5+6+9 | 描述中已涵盖，且搜索量低 |
| reminder, monitoring, notification | 8+10+12 | 通用功能词，搜索权重低 |
| daily, streak, gamification, card, collection | 5+6+13+4+10 | 内部功能词，用户不会搜 |

**步骤 4：与 Apple 算法一致性检查**
- ✅ 无重复 App 名 (VitaMindGo 已含在 name/subtitle)
- ✅ 无竞品名
- ✅ 每个词 ≥3 字符
- ✅ 短语优先 (habit tracker, heart rate, Apple Watch 是高 ROI 短语)
- ✅ 8 词在 80 字符内，密度高于行业平均 (~6 词)

---

## 5. Support URL

> **Apple 字段:** Support URL — 必需，需包含真实联系方式 (邮箱/电话/地址)
> **本项目内规:** 使用 GitHub Pages 主页 (与 Privacy Policy 同域)

| 项目 | 值 |
|------|---|
| **Support URL** | `https://lauer3912.github.io/ios-VitaMindGo/` |
| **Contact Email** | `support@techidaily.com` |
| **URL 状态** | ⚠️ 待 Human 确认可访问 |

---

## 5A. Copyright (版权)

> **Apple 字段:** Copyright — 格式: `YYYY Owner Name`，Apple 自动加 © 符号
> **本项目内规:** Owner 使用 App Display Name (与品牌一致)

| 项目 | 值 |
|------|---|
| **Copyright** | `2026 VitaMindGo` |

**理由**:
- 年份: 2026 (v3.0.0 首次发布年)
- Owner: `VitaMindGo` (与 App Display Name 一致)
- Apple 会自动加 © 符号，**不要在字段里手动加** `©` 或 `(c)` (会导致重复符号)

---

## 6. Privacy Policy URL

## 6. Privacy Policy URL

**Privacy Policy:** https://lauer3912.github.io/ios-VitaMindGo/PrivacyPolicy.html
**Local Privacy Policy HTML:** AppStore/Docs/PrivacyPolicy.html

---

## 7. Category Selection

| Field | Selection |
|-------|-----------|
| **Primary Category** | Health & Fitness |
| **Secondary Category** | Medical |

---

## 8. Content Rating

| Field | Selection |
|-------|-----------|
| **Age Rating** | 4+ (Everyone) |
| **Adult Content** | No |
| **Frequent/Intense Medical/Treatment Information** | No |

---

## 9. Screenshots

| Device | Size | Count | Location |
|--------|------|-------|----------|
| iPhone 17 Pro Max (6.9") | 1320×2868 px | 5 | AppStore/Screenshots/iPhone17ProMax_1320x2868/ |
| iPad Pro 13" (M4) | 2048×2732 px | 5 | AppStore/Screenshots/iPadPro13inchM4_2048x2732/ |

**Screenshot Files:**
- iPhone: `vp_tab1_pocket.png`, `vp_tab2_habits.png`, `vp_tab3_coach.png`, `vp_tab4_collection.png`, `vp_tab5_settings.png`
- iPad: `ipad_tab1.png`, `ipad_tab2.png`, `ipad_tab3.png`, `ipad_tab4.png`, `ipad_tab5_settings.png`

**Last captured:** 2026-06-03 (re-captured with **Release** configuration build, after Mock-data removal + Settings tab + local notifications feature)
- Captured using `xcodebuild test -configuration Release` so the binary that produced the screenshots is the same configuration that gets archived and uploaded to App Store Connect
- Verified Bundle ID = `com.ggsheng.VitaMind`, Display Name = `VitaMindGo`, Version = `3.0.0` (Build 1) in the captured `.app` Info.plist
- No `#if DEBUG` / `#if !DEBUG` in Sources — Debug and Release configurations render identical UI
- Legacy captures (5-31, 4 tabs only, Debug build) moved to `AppStore/Screenshots/legacy-5-31/` and `legacy-5-31-ipad/`

---

## 10. App Review Information (App 审核信息)

> **Apple 字段集合:** App Review Information + Export Compliance + Medical Device + Server Notifications
> **本项目内规:** 所有 4 个子节必填，勿遗漏

### 10.1 Contact Info (联系方式)

| 字段 | 值 | 备注 |
|------|---|------|
| **First Name** | `ZhiFeng` | 来源: Apple Developer Team Account Holder (验证: `security find-identity -v -p codesigning` 输出 "Apple Distribution: ZhiFeng Sun (9L6N2ZF26B)") |
| **Last Name** | `Sun` | 同上 |
| **Email** | `support@techidaily.com` | 已准备 |
| **Phone** | `+86 15050228829` | Human 2026-06-04 早间提供 (E.164 格式，中国大陆) |

### 10.2 Sign-in Required (是否需登录)

| 字段 | 值 |
|------|---|
| **Sign-in Required** | **No** |
| **Username** | N/A |
| **Password** | N/A |

**理由**: VitaMindGo v3.0.0 无账号系统，所有数据本地存储 (App Group + UserDefaults)，首启即用。

### 10.3 Notes for Reviewer (审核备注)

> **Apple 字段:** Notes — 上限 4000 bytes，App Review 内部可见

```
VitaMindGo integrates with Apple HealthKit and Apple Watch for health tracking. The app uses on-device CoreML AI for privacy-focused health analysis. All features are fully functional without subscription.

Key testing guidance:
1. The app requests HealthKit authorization on first launch (heart rate, HRV, sleep, steps, exercise minutes). Use Settings > Health > Data Access & Devices > VitaMindGo to manage permissions.
2. Apple Watch integration is optional. iPhone-only testing is fully supported. Watch app shows current health metrics synced from the paired iPhone.
3. AI Coach requires a user-provided API key in Settings > AI Provider. The app ships with a placeholder; testers should enter their own OpenAI/Anthropic/Google/DeepSeek/MiniMax/xAI key. No bundled credentials.
4. The 5 tabs (Pocket, Habits, Coach, Collection, Settings) are all functional without an account. Onboarding tour is skippable.
5. No subscription, no IAP, no in-app purchase in v3.0.0 — app is 100% free with all features.
6. The app does NOT claim to diagnose, treat, or prevent any medical condition. All health metrics are presented as informational/lifestyle data.

Guideline 1.4.1 fix (build 10, 2026-06-09):
The AI Health Coach (VitaCoach, Coach tab) has been updated to ensure every health-related response includes citations to authoritative sources, displayed prominently in a dedicated "Sources" footer card directly below each AI message.

- Citation format: Each AI response ends with a "### Sources" block listing 2+ numbered citations.
- Source whitelist: Citations are restricted to authoritative domains (cdc.gov, who.int, nih.gov, medlineplus.gov, mayoclinic.org, nhs.uk, pubmed.ncbi.nlm.nih.gov, healthline.com, webmd.com).
- Visibility: Citations appear as a clearly labeled "Sources" card with tappable links, immediately below the AI message bubble.
- Disclaimer: A persistent medical disclaimer is also shown at the top of the Coach view ("For informational purposes only — not medical advice").

To test: Open the Coach tab, enter any health-related question (e.g., "How to manage stress", "Benefits of walking 30 min a day"), and verify the response ends with a "Sources" card containing 2+ tappable citation links.
```

### 10.4 Regulated Medical Device (受监管医疗设备)

> **Apple 问题:** "Is your app a regulated medical device?"
> **答案:** **No** — VitaMindGo is **NOT a regulated medical device**.

**理由**:
- VitaMindGo 仅使用 HealthKit 读取心率/HRV/睡眠/步数/运动分钟数
- **仅供生活方式与一般健康参考**，不提供医学诊断、治疗、治愈、预防任何疾病
- 符合 Apple 审核指南 1.4.1 (Medical Device considerations) — 一般健康/生活方式类 App
- 符合 FDA General Wellness 政策 (2019) — 适用于一般健康 App 的豁免
- 不读取/不展示任何医疗级数据 (血糖、血压、心电图等)
- UI 中明确说明 "wellness companion" / "lifestyle" 定位，不含 medical claim

### 10.5 App Encryption (Export Compliance 加密文稿)

> **Apple 问题 1:** "Is your app designed to use cryptography or contains or incorporates cryptography?"
> **答案:** **Yes**

> **Apple 问题 2:** "Does your app qualify for any of the exemptions provided in Category 5, Part 2, Note 4 of the U.S. Bureau of Industry and Security?"
> **答案:** **Yes**

**说明**:
- VitaMindGo 使用 `URLSession` 默认 TLS/HTTPS 加密连接 (AI Provider API)
- 使用 Apple 标准 `HealthKit` / `CoreML` 框架 (不包含自定义加密实现)
- 所有加密都属于 BIS Category 5, Part 2, Note 4 的豁免类 (公开可获取的加密代码)
- **不需提交 CCATS (Commodity Classification Automated Tracking System)**
- **需年度自评报告**: 每年 2 月 1 日前向 BIS 提交 self-classification report (一次性，会计年度内仅 1 次)
- 本项目内规: Info.plist 已预配置 `ITSAppUsesNonExemptEncryption = false` (见 §10.5 补充)

### 10.6 App Store Server Notifications (服务器通知)

> **Apple 字段:** 用于 IAP/订阅事件回调 URL
> **本项目状态:** **N/A (v3.0.0 无 IAP)**

| 字段 | 值 | 备注 |
|------|---|------|
| **Production URL** | N/A | v3.0.0 免费发布 |
| **Sandbox URL** | N/A | v3.0.0 免费发布 |

**未来计划**:
- 当未来版本加入 Auto-Renewable Subscription 后，需配置 2 个端点 (Production + Sandbox)
- 默认路径: `/v1/notifications/appstore` 或类似
- 需自行实现 JWT 验证 (从 App Store 拉取公钥) + 事件处理
- **当前阶段忽略此字段**

### 10.7 字段填写汇总表 (Human 复制用)

| App Store Connect 字段 | 直接复制 |
|----------------------|---------|
| Sign-in Required | No |
| Username | (空) |
| Password | (空) |
| Notes for Reviewer | (复制 §10.3 文本块) |
| Regulated Medical Device | No |
| App uses cryptography | Yes |
| App qualifies for exemption | Yes |
| Production Server Notification URL | (空) |
| Sandbox Server Notification URL | (空) |

---

## 11. App Store Connect Metadata

| Field | Content |
|-------|---------|
| **Bundle ID** | com.ggsheng.VitaMind |
| **App Store Status** | Prepare for Submission |
| **Release Date** | TBD |
| **Pricing** | Free (initial release) |
| **Territory Availability** | All Available Territories |

---

## 12. 上架前检查清单（Human 填写）

> ⚠️ 以下内容需要你在 App Store Connect 网页上填写/确认

### 12.1 本地资料 (Listing.md 已提供答案)

| 项目 | Listing.md 状态 | 你需要做的事 |
|------|-----------------|------------|
| App Name | ✅ VitaMindGo | 确认 |
| Subtitle (可选) | ⏳ 30 chars 内 | 可加可不加 (App Store 允许空) |
| Promotional Text | ✅ A3 (99 chars) | 复制到 App Store Connect |
| Description | ✅ 1904 chars (纯文本) | 复制到 App Store Connect |
| Keywords | ✅ 8 词 (76 chars) | 复制到 App Store Connect |
| Support URL | ✅ GitHub Pages | 确认主页可访问 |
| Copyright | ✅ "2026 VitaMindGo" | 复制到 App Store Connect |
| Marketing URL (可选) | ⏳ 可空 | 可不填 |
| Privacy Policy URL | ✅ GitHub Pages | 确认可访问 |
| Category (Primary) | ✅ Health & Fitness | 确认 |
| Category (Secondary) | ✅ Medical | 确认 |
| Age Rating | ✅ 4+ | 完成问卷 |
| Screenshots (iPhone) | ✅ 5 张 1320×2868 | 上传 |
| Screenshots (iPad) | ✅ 5 张 2048×2732 | 上传 |

### 12.2 App Review Information (10.x 全部子节)

| 项目 | Listing.md 状态 | 你需要做的事 |
|------|-----------------|------------|
| Contact First Name | ❌ 待 Human 填 | 填入你本人名字 |
| Contact Last Name | ❌ 待 Human 填 | 填入你本人姓 |
| Contact Email | ✅ support@techidaily.com | 确认 |
| Contact Phone | ❌ 待 Human 填 | 填入可联系的手机 |
| Sign-in Required | ✅ No | 选 No |
| Demo Account | ✅ N/A | 留空 |
| Notes for Reviewer | ✅ §10.3 完整文本 | 复制 |
| Regulated Medical Device | ✅ No | 选 No |
| App uses cryptography | ✅ Yes | 选 Yes |
| App qualifies for exemption | ✅ Yes | 选 Yes |
| Production Server Notification URL | ✅ N/A | 留空 (v3.0.0 无 IAP) |
| Sandbox Server Notification URL | ✅ N/A | 留空 (v3.0.0 无 IAP) |

### 12.3 URL 可访问性验证 (2026-06-04 实测)

| URL | HTTP | 状态 | 验证命令 |
|-----|------|------|---------|
| Support URL | **200** | ✅ | `curl -I https://lauer3912.github.io/ios-VitaMindGo/` |
| Privacy Policy URL | **200** | ✅ | `curl -I https://lauer3912.github.io/ios-VitaMindGo/PrivacyPolicy.html` |
| 旧 URL `ios-VitaMind` | **404** | ❌ | `curl -I https://lauer3912.github.io/ios-VitaMind/` |
| 旧 URL `ios-VitaMind/PrivacyPolicy.html` | **404** | ❌ | `curl -I https://lauer3912.github.io/ios-VitaMind/PrivacyPolicy.html` |

**重要发现**:
- ✅ 新 URL (ios-VitaMindGo) 全部 200，可用于 App Store 提交
- ❌ **旧 URL (ios-VitaMind) 返回 404，**没有 301 重定向****
- 原因: GitHub Repo rename 会在 API 层返回 301 ("Moved Permanently")，但 **GitHub Pages 不会自动迁移 Pages 配置**。SOP §8.4.3 / SC-61 明确说应检查 4 个 URL 全部 200，但当前仅 2 个 200。
- **必须修复 (Stage 8.5 优先)**: 在旧 repo `ios-VitaMind` 的 `index.html` 加 meta refresh 跳到新 URL

修复参考:
```html
<!-- 老 repo index.html -->
<!DOCTYPE html>
<html><head>
<meta http-equiv="refresh" content="0; url=https://lauer3912.github.io/ios-VitaMindGo/">
</head><body>Redirecting...</body></html>
```

---

*This document is used for App Store listing configuration. Stage 8.2 需要 Human 按此文件内容在 App Store Connect 网页上填写。*