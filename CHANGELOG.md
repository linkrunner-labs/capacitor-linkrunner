# Changelog

## [2.2.0] - 2026-10-08

- `getAttributionData()` now returns `gaid` and `idfa` in `data`: the advertising identifiers Linkrunner recorded the install with. Use them to join Linkrunner attribution with your own data instead of reading the identifier again on the device. Each is a string when available and absent otherwise. `gaid` is only set on Android and `idfa` only on iOS (when App Tracking Transparency is authorized).
- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.2.0`.
- Bumped the native iOS SDK to `LinkrunnerKit 4.2.0` (podspec and Package.swift).

## [2.1.2] - 2026-10-04

- `enablePIIHashing(true)` now hashes `name`, `email` and `phone` on Android. Before, the native Android SDK stored the flag but never applied it, so `signup` and `setUserData` sent those fields in plain text while iOS sent SHA-256 hashes. Android now sends the same lowercase SHA-256 hex as iOS, so the same input gives the same hash on both platforms. Nothing changes when hashing is off.
- Calling `enablePIIHashing()` before `init()` no longer fails on Android (native SDK used to throw `Context not set`).
- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.1.1`.
- Bumped the native iOS SDK to `LinkrunnerKit 4.1.0` (podspec and Package.swift).

## [2.1.1] - 2026-07-23

- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.0.2` to prevent signup from sending an empty install instance ID when it runs concurrently with initialization.

## [2.1.0] - 2026-07-09

- Exposed ad-network attribution fields in `campaign_data`: `adNetworkCampaignId`, `adSetId`, `adSetName`, `adCreativeId`, `adCreativeName`.
- Bumped underlying `LinkrunnerKit` (iOS) dependency to `4.0.1`
- Bumped underlying `io.linkrunner:android-sdk` (Android) dependency to `4.0.1`

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
