# App Store Connect 提交分步 Check-list

> 截止 2026-06-03 16:03 GMT+8
> 佛罗多老爷 (Human) 在 Xcode + App Store Connect 网站完成

---

## Phase 1: 上传 Archive (Xcode 操作, 5-10 分钟)

1. 打开 Xcode → `Window` → `Organizer` → `Archives` 标签
2. 找到 **`VitaPocket` at 6/3/2026 15:57`** (本次会话生成的 archive)
   - 验证: Bundle ID = `com.ggsheng.VitaMind`, Version = `3.0.0 (1)`
3. 选中 archive → 点击 `Distribute App` (右上角蓝色按钮)
4. 选择分发方式:
   - ✅ `App Store Connect`
   - ✅ `Upload` (不是 Export)
5. 签名选项:
   - ✅ `Automatically manage signing`
   - Team: `9L6N2ZF26B` (VitaMind 个人 team)
6. 等待上传完成 (通常 2-5 分钟, 取决于网速)
7. 看到 ✅ "Upload Successful" 后, 切到浏览器

---

## Phase 2: 填 App Store Connect 元数据 (10-15 分钟)

1. 打开 https://appstoreconnect.apple.com
2. 选 App: **VitaMindGo** (Bundle: com.ggsheng.VitaMind)
3. 左侧栏 → `1.0 待处理版本` 或新版本号

### 必填字段 (对照 `AppStore/Listing.md` 填)

| 字段 | 内容 |
|---|---|
| **App 名称** | VitaMindGo |
| **副标题** (Promotional Text) | Your AI-Powered Health Companion |
| **类别** | 健康健美 (Health & Fitness) + 医疗 (Medical) |
| **价格** | 免费 |
| **Bundle ID** | com.ggsheng.VitaMind (验证) |
| **版本号** | 3.0.0 |
| **Build** | 选刚才上传的 archive |
| **隐私政策 URL** | https://lauer3912.github.io/ios-VitaMind/docs/privacy |
| **Support URL** | https://lauer3912.github.io/ios-VitaMind/docs/ |
| **营销 URL** | (选填, 同 Support) |

### 描述 (拷贝自 Listing.md §3)

```
**Your AI-Powered Health Companion**

VitaMindGo combines cutting-edge AI technology with comprehensive health monitoring to help you understand your body like never before.

[... 完整描述见 AppStore/Listing.md §3 全文 ...]
```

### 关键词 (Listing.md §4)

```
health, fitness, Apple Watch, heart rate, sleep, tracker, habit,
wellness, AI, assistant, activity, steps, exercise, HRV, stress,
mindfulness, water, reminder, vitals, healthkit, monitoring,
notification, daily, streak, gamification, card, collection
```

### What's New (本次更新日志)

```
- 全新: 本地通知 (Daily Reminders) - 早 9 点 / 晚 8 点 / 晚 10 点三个温柔提醒
- 修复: 移除了演示用 mock 数据, 首次安装现在是真实的初始状态
- 全新: Settings tab - 控制通知 / 主题 / HealthKit / AI provider
- 新增 5 tab 导航: Pocket / Habits / Coach / Collection / Settings
```

---

## Phase 3: 上传截图 (5 分钟)

### iPhone 6.9" (iPhone 17 Pro Max)

上传 5 张到 iPhone 6.9" 槽位:
1. `AppStore/Screenshots/iPhone17ProMax_1320x2868/vp_tab1_pocket.png`
2. `vp_tab2_habits.png`
3. `vp_tab3_coach.png`
4. `vp_tab4_collection.png`
5. `vp_tab5_settings.png` ⭐ Settings tab 是亮点

### iPad 13" (iPad Pro M4)

上传 5 张到 iPad 13" 槽位:
1. `AppStore/Screenshots/iPadPro13inchM4_2048x2732/ipad_tab1.png`
2. `ipad_tab2.png`
3. `ipad_tab3.png`
4. `ipad_tab4.png`
5. `ipad_tab5_settings.png` ⭐ 8 个 AI provider 列表

### Apple Watch (如果有)

`AppStore/Screenshots/AppleWatchUltra3_396x484/watch_396x484.png` (旧版, 可选)

---

## Phase 4: 内容审查问卷 (3 分钟)

左侧 → `App Review`

- 联系人姓名 + 邮箱 + 电话
- 备注 (示例):

```
VitaMindGo is an iOS app that uses HealthKit (read-only) to display
health metrics. Local notifications are scheduled via UserNotifications
when the user grants permission. No account / login required, no
network requests beyond the optional AI coach chat.
```

- 内容版权: ✅ (我自己的代码 + 公开资源)
- 广告: ❌ 不含 IDFA
- 加密: ❌ 没用自定义加密 (ITSAppUsesNonExemptEncryption 已在 Info.plist 设为 false)
- 儿童: ❌ 13+ (默认)

---

## Phase 5: 提交审核 (1 分钟)

1. 顶部 `添加以供审核` → `提交以供审核`
2. 等邮件确认 (通常 5-30 分钟)
3. 等待审核 (通常 24-48 小时, 第一次审核可能更久)
4. 状态: `等待审核` → `正在审核` → `可供销售` ✅

---

## 📁 配套文件位置

- 完整 Listing 草稿: `AppStore/Listing.md`
- 隐私政策 (HTML): `AppStore/Docs/PrivacyPolicy.html`
- 服务条款 (HTML): `AppStore/Docs/TermsOfService.html`
- 功能清单: `AppStore/Docs/FeatureList.md`
- 截图源文件: `AppStore/Screenshots/iPhone17ProMax_1320x2868/` + `iPadPro13inchM4_2048x2732/`
- Archive: `/tmp/VitaPocket-Release.xcarchive`
- 通知功能演示 GIF: `docs/notifications/vitapocket-notif-demo.gif` (用于 PR 描述, 非 App Store 必填)

---

## ⚠️ 易错点提醒

1. **Build 必须选刚才上传的 archive** — 否则会报"build 不存在"
2. **Bundle ID 不能改** — `com.ggsheng.VitaMind` 必须在 App Store Connect 已注册 (已注册)
3. **截图顺序** — iPhone 第一张最重要, 放最能展示功能的 (建议 Pocket / Settings 之一)
4. **导出合规** — 如果被问"是否使用加密", 选 ❌ (我们用 HTTPS, NSAllowsArbitraryLoads 在 Info.plist 是 true 但实际只发请求到 AI API, 不算"自定义加密")
5. **不要在 What's New 写代码细节** — 写用户能感知的改动
