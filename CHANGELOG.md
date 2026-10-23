# Changelog

## [3.0.0] - Unreleased

### Added

- `trackPayment({ eventName, paymentId, userId, amount, currency, status?, eventData?, eventId? })` records a payment as an event. This is the main way to send payments now. The event name becomes the payment type. `amount` must be a finite number >= 0, `paymentId` must not be empty, `currency` must be a 3-letter ISO 4217 code and `userId` must be a string (pass `''` to fall back to the user from `signup`). `status` defaults to `PAYMENT_COMPLETED` and is always sent. The call throws before dispatch when any of these is invalid.
- `trackEvent` takes an optional 4th argument `payment: { amount, paymentId, currency, userId, status? }` with the same rules, for attaching a payment to an event you already track. Calls without a payment work exactly as before.
- New `TrackPaymentOptions` and `EventPayment` types.
- Bumped the native Android SDK to `io.linkrunner:android-sdk:5.0.0`.
- Bumped the native iOS SDK to `LinkrunnerKit 5.0.0` (podspec and Package.swift).
- `PaymentStatus` is exported as a runtime object, so you can write `PaymentStatus.PAYMENT_COMPLETED` (`import { PaymentStatus } from 'capacitor-linkrunner'`). Plain strings such as `'PAYMENT_COMPLETED'` still work.

### Removed

- **Breaking:** `capturePayment` and `removePayment`. Send payments with `trackPayment` instead.
- **Breaking:** the `PaymentType` type and the `CapturePaymentOptions` / `RemovePaymentOptions` interfaces. `PaymentStatus` stays.

### Migration

Before:

```ts
await linkrunner.capturePayment({
  paymentId: 'order_123',
  userId: 'user_1',
  amount: 499,
  type: 'FIRST_PAYMENT',
  status: 'PAYMENT_COMPLETED',
});
```

After:

```ts
await linkrunner.trackPayment({
  eventName: 'FIRST_PAYMENT',
  paymentId: 'order_123',
  userId: 'user_1',
  amount: 499,
  currency: 'INR',
  status: 'PAYMENT_COMPLETED',
});
```

`type` becomes `eventName`, `currency` is now required, and `userId` stays required as before. There is no replacement for `removePayment`.

### Payment names and dashboard mappings

The event name you pass becomes the payment type in reports and in your dashboard event mappings, and mappings match it exactly. If you used one of the old payment types, pass the same name (in any case, for example `first_payment` or `DEFAULT`). Linkrunner stores it as the uppercase type, so your existing mappings, reports and partner templates keep working with no change. If you pick a new name such as `purchase`, add a mapping for it in the dashboard before you release, or those payments are not sent to ad networks. `capturePayment` without a type was stored as `DEFAULT`.

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
