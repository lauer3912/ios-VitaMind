# VitaMindGo - Game-Inspired Health Card Collection

## Design Philosophy
Pokémon TCG Pocket 的核心魅力：3D动效 + 物理反馈 + 收集成就感
融合到健康App：让打卡变成"抽卡"，让健康数据变成"收集图鉴"

## Color Palette
```
Primary:    #6B4EFF (Royal Purple - 神秘感)
Secondary:  #00D9A (Teal - 生命力)  
Accent:     #FFD700 (Gold - 稀有感/成就)
Background: #0D0B1E (Deep Navy - 沉浸感)
Surface:    #1A1730 (Card Background)
Card Rare:  #FF6B6B (Red - 稀有卡)
Card Epic:  #9B59B6 (Purple - 史诗卡)
Card Common:#4ECDC4 (Teal - 普通卡)
Success:    #2ECC71
Warning:    #F39C12
```

## Typography
- 标题: SF Pro Display Bold (游戏感)
- 正文: SF Pro Text Regular
- 数字: SF Mono Bold (计分感)

## Card Design System
```
卡牌结构:
┌────────────────────┐
│  [稀有度标识]  [图标] │  ← 顶栏
│                    │
│   [3D 卡牌图案]     │  ← 主图区 (Lottie/3D渲染)
│                    │
│   [数值/进度条]     │  ← 数据区
│                    │
│   [名称]  [描述]    │  ← 底部
└────────────────────┘

卡牌动画:
1. 获得卡牌: 抽卡翻转动画 + 闪光粒子
2. 查看卡牌: 3D旋转 + 物理弹性
3. 升级卡牌: 进化闪光 + 震动反馈
4. 打卡完成: 卡牌翻转 + 粒子爆发
```

## Screen Structure
```
Tab 1 - Vita Pocket (首页)
├── 顶部: 用户等级 + XP进度条
├── 今日任务卡组 (滚动)
├── 健康数据卡牌展示 (网格)
└── 抽卡入口

Tab 2 - Habits (习惯/卡牌战斗)
├── 今日习惯列表 (卡牌形式)
├── 打卡按钮 (触发卡牌动画)
├── 连续打卡计数器 (进化条)
└── 奖励预览

Tab 3 - AI Coach (AI教练)
├── AI教练形象 (卡片形态)
├── 对话界面 (气泡+卡片混合)
├── 健康建议卡片
└── 快速操作按钮

Tab 4 - Collection (图鉴)
├── 图鉴网格 (已收集/未解锁)
├── 卡牌详情 (3D展示)
├── 成就系统
└── 统计面板
```

## Animation Library
```
Core Animations:
- card_flip: 卡牌翻转 (0.6s ease-in-out)
- card_shine: 闪光特效 (particle burst)
- card_shake: 震动反馈 (physics-based)
- card_glow: 发光效果 (稀有卡专用)
- xp_gain: 经验值飞升 (+数字飘字)
- evolution: 进化动画 (1.2s flash + scale)
- pull_card: 抽卡动画 (gacha-style)
- tab_bounce: Tab切换弹性动画
```

## Features -> Card Mapping
```
健康指标 -> 卡牌:
- Heart Rate  -> 爱心卡 (稀有度: ⭐⭐)
- Steps       -> 运动卡 (稀有度: ⭐⭐⭐)  
- Sleep       -> 月亮卡 (稀有度: ⭐⭐)
- Water       -> 水滴卡 (稀有度: ⭐)
- Meditation  -> 冥想卡 (稀有度: ⭐⭐⭐⭐)
- Exercise    -> 力量卡 (稀有度: ⭐⭐⭐)

习惯 -> 卡牌收集:
- 每日打卡 -> 解锁新卡牌
- 连续7天  -> 卡牌升级 (进化)
- 连续30天  -> 闪卡 (发光版)
```

## Technical Approach
```
Framework: SwiftUI + UIKit混编
动画:      SwiftUI Animations + Lottie (复杂动效)
状态管理:   @Observable (iOS17+)  
数据:      UserDefaults + App Groups (Widget共享)
AI:        MiniMax API (对话)
健康:      HealthKit
```
