# Banana Stats — iPhone widget

Minimal SwiftUI app + WidgetKit extension showing Banana Airways Steam stats
from `https://3d.ar/api/banana-widget` (players in the demo, wishlists, +N today).
Home Screen sizes: small, medium. Lock Screen: rectangular, circular, inline.
Tapping the widget opens https://3d.ar/banana-stats/. Timeline refresh ≈ 15 min.

## Install on your iPhone (developer build, no App Store)

1. Xcode 16+ installed, signed in with your Apple ID (Xcode > Settings > Accounts).
   A free personal team is enough.
2. `brew install xcodegen`
3. Plug in the iPhone, unlock it, tap "Trust". On the phone enable
   Settings > Privacy & Security > Developer Mode.
4. Build + install:
   - On the 3DAR Apple team: `./push.sh`
   - Any other team: `TEAM_ID=<your 10-char team id> BUNDLE_PREFIX=com.<yourname> ./push.sh`
     (team id: Xcode > Settings > Accounts > your team, or developer.apple.com/account > Membership)
5. First launch: Settings > General > VPN & Device Management > trust your developer app.
6. Add the widget: long-press the Home Screen > Edit > Add Widget > search "Banana".

Personal-team builds expire after 7 days; rerun `./push.sh` to renew.
The project file is generated: edit `project.yml`, never `BananaStats.xcodeproj`.
