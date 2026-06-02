# VitaPocket — Notifications Feature

Visual assets for the local-notification feature added in v3.1.

## What this folder contains

| File | Purpose |
|---|---|
| `vitapocket-notif-demo.gif` | End-to-end demo of the full notification flow (20 s, 1.5 MB) |
| `screenshots/01-permission-alert.png` | iOS system permission prompt on first launch |
| `screenshots/02-settings-section.png` | New Notifications section in Settings (toggle + Send Test button) |
| `screenshots/03-test-banner.png` | Test notification banner (foreground, UNUserNotificationCenterDelegate) |
| `screenshots/04-real-banner.png` | Real "Today's card is ready" banner delivered via simctl push |

## How the feature works

See `Sources/Services/NotificationManager.swift` for the implementation. Short version:

- Three daily reminders scheduled with `UNCalendarNotificationTrigger`:
  - **09:00** — "🎴 Today's card is ready" (daily pull)
  - **20:00** — "⏰ Habit check-in" (streak maintenance)
  - **22:00** — "🔥 Last call" (only if user has habits)
- Permission requested on first launch via `bootstrapNotifications()`.
- User can disable from Settings → Notifications → Daily Reminders.
- `UNUserNotificationCenterDelegate.willPresent` returns `[.banner, .sound]` so banners appear **even when the app is in the foreground** (otherwise iOS silently drops them — common dev gotcha).

## Reproducing the demo

```bash
# 1. Record simulator screen
xcrun simctl io <device> recordVideo --codec h264 /tmp/demo.mp4 &

# 2. Run the auto-driving UI test (taps Allow, navigates to Settings, fires test notification)
xcodebuild test -project VitaPocket.xcodeproj -scheme VitaPocket \
  -only-testing:VitaPocketUITests/NotifDemoTests

# 3. Stop recording
kill -INT %1

# 4. Trim + palette + GIF (1.5 MB, 420×913, 10 fps)
ffmpeg -ss 12 -t 18 -i /tmp/demo.mp4 \
  -vf "fps=10,scale=420:-1,palettegen" /tmp/pal.png
ffmpeg -ss 12 -t 18 -i /tmp/demo.mp4 -i /tmp/pal.png \
  -filter_complex "fps=10,scale=420:-1,paletteuse" vitapocket-notif-demo.gif
```

## Testing status

- 19/19 unit tests passing
- 10/10 UI tests passing (including `NotifDemoTests`)
- Build: ✅ `BUILD SUCCEEDED` (iPhone 17 Pro Max, iOS 26.5 simulator)
