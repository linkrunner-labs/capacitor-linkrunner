# Changelog

## [2.0.0] - 2026-06-30

- **Breaking:** `paymentId` is now required in `capturePayment`; the call throws before dispatch when it is missing
- Bumped underlying `LinkrunnerKit` (iOS) dependency to `4.0.0`
- Bumped underlying `io.linkrunner:android-sdk` (Android) dependency to `4.0.0`

## [1.2.0] - 2026-06-05

- Added `setPushToken` method for registering FCM (Android) and APNs (iOS) push notification tokens
- Added `handleDeeplink` method for re-engagement attribution when the app is opened via a deeplink
- Bumped underlying `LinkrunnerKit` (iOS) dependency to `3.10.0`
- Bumped underlying `io.linkrunner:android-sdk` (Android) dependency to `3.8.1`

## [1.1.0] - 2026-03-21

- Added `netcore_device_guid` field to `UserData` interface for Netcore integration support

## [1.0.1] - Initial Release

- Initial release of Capacitor Linkrunner plugin
