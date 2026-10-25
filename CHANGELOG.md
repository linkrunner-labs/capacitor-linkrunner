# Changelog

## [2.4.1] - 2026-10-25

- Bumped the native iOS SDK to `LinkrunnerKit 4.3.1`. Fixes an `EXC_BAD_ACCESS (KERN_INVALID_ADDRESS)` crash at app launch on iOS, in frames like `DeviceData`, `getAttributionToken`, `setUserData` and `makeRequestWithRetry`, that could happen when `init`, `setUserData`, `trackEvent` and other calls ran at the same time. LinkrunnerKit 4.1.0 to 4.3.0 shared the cached AdServices token between those calls without a lock, and every piece of shared state is now locked. No API changes. Android is unchanged (`io.linkrunner:android-sdk:4.4.0`).

## [2.4.0] - 2026-10-23

- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.4.0`. Android device data now includes `device_model` (`Build.MODEL`, for example `SM-M315F`), so Device Model is filled for Android users on the dashboard and in ad network postbacks. `device_name` is unchanged. No API changes. iOS is unchanged (`LinkrunnerKit 4.3.0`).

## [2.3.2] - 2026-10-21

- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.3.2`. Fixes a launch crash (`NoSuchMethodException: androidx.work.impl.WorkDatabase_Impl.<init>`) in Android release builds shrunk by R8 on Android Gradle Plugin 9, for example Expo 58 release builds where shrinking is on by default. With only that crash patched, `init`, `signup`, `trackEvent`, `capturePayment` and the other queued calls were never sent. The native SDK's consumer ProGuard rules now keep the constructors WorkManager creates by reflection, so apps need no rule of their own. No API changes. iOS is unchanged (`LinkrunnerKit 4.3.0`).

## [2.3.1] - 2026-10-19

- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.3.1`. On Android, `init`, `signup`, `setUserData` and `setCustomerUserId` no longer run Keystore encryption or blocking disk writes on the main thread, which could freeze the app and cause ANRs on slow devices. A normal app launch now does no Keystore write, and the WebView user agent is cached so it is not rebuilt on every cold start. No API changes. iOS is unchanged (`LinkrunnerKit 4.3.0`).

## [2.3.0] - 2026-10-12

- `setUserData` no longer needs a customer user id, so it can be called right after `init`. `UserData.id` is now optional: pass only the analytics ids you have (for example `mixpanel_distinct_id`, `amplitude_device_id`, `posthog_distinct_id`) and add `id` later, once your app knows the user. Linkrunner sets its attribution properties (`lr_campaign`, `lr_ad_network`) on the profiles of the analytics tools you identified, when that integration is configured for your project. `signup` still requires `id`.
- An id-less `setUserData` call no longer clears the stored customer user id, so custom events keep their `user_id`.
- Added `UserData.moengage_user_id`, so MoEngage profiles receive Linkrunner attribution.
- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.3.0` and the native iOS SDK to `LinkrunnerKit 4.3.0` (podspec and Package.swift).

## [2.2.0] - 2026-10-08

- `getAttributionData()` now returns `gaid` and `idfa` in `data`: the advertising identifiers Linkrunner recorded the install with. Use them to join Linkrunner attribution with your own data instead of reading the identifier again on the device. Each is a string when available and absent otherwise. `gaid` is only set on Android and `idfa` only on iOS (when App Tracking Transparency is authorized).
- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.2.0`.
- Bumped the native iOS SDK to `LinkrunnerKit 4.2.0` (podspec and Package.swift).
- Fixed the plugin failing to compile against native SDK 4.1.x and later: `capturePayment` passed an optional `paymentId` where the native SDKs require one. It now rejects the call with `paymentId is required` when it is missing or empty, matching the TypeScript type.

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
