# capacitor-linkrunner

Linkrunner Capacitor Plugin

## Install

```bash
npm install capacitor-linkrunner
npx cap sync
```

## API

<docgen-index>

* [`init(...)`](#init)
* [`signup(...)`](#signup)
* [`setUserData(...)`](#setuserdata)
* [`capturePayment(...)`](#capturepayment)
* [`removePayment(...)`](#removepayment)
* [`trackEvent(...)`](#trackevent)
* [`getAttributionData()`](#getattributiondata)
* [`setAdditionalData(...)`](#setadditionaldata)
* [`enablePIIHashing(...)`](#enablepiihashing)
* [`getPackageVersion()`](#getpackageversion)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

Main Linkrunner plugin interface

### init(...)

```typescript
init(options: InitOptions) => Promise<void>
```

Initialize the Linkrunner SDK

| Param         | Type                                                | Description                                                    |
| ------------- | --------------------------------------------------- | -------------------------------------------------------------- |
| **`options`** | <code><a href="#initoptions">InitOptions</a></code> | Initialization options including token and optional parameters |

--------------------


### signup(...)

```typescript
signup(options: SignupOptions) => Promise<void>
```

Register a new user signup

| Param         | Type                                                    | Description                                                     |
| ------------- | ------------------------------------------------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#signupoptions">SignupOptions</a></code> | Signup options including user data and optional additional data |

--------------------


### setUserData(...)

```typescript
setUserData(options: SetUserDataOptions) => Promise<void>
```

Update user data

| Param         | Type                                                              | Description         |
| ------------- | ----------------------------------------------------------------- | ------------------- |
| **`options`** | <code><a href="#setuserdataoptions">SetUserDataOptions</a></code> | User data to update |

--------------------


### capturePayment(...)

```typescript
capturePayment(options: CapturePaymentOptions) => Promise<void>
```

Capture a payment event

| Param         | Type                                                                    | Description                                                 |
| ------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------- |
| **`options`** | <code><a href="#capturepaymentoptions">CapturePaymentOptions</a></code> | Payment details including user ID, amount, type, and status |

--------------------


### removePayment(...)

```typescript
removePayment(options: RemovePaymentOptions) => Promise<void>
```

Remove or refund a payment

| Param         | Type                                                                  | Description                                                       |
| ------------- | --------------------------------------------------------------------- | ----------------------------------------------------------------- |
| **`options`** | <code><a href="#removepaymentoptions">RemovePaymentOptions</a></code> | Payment removal details including user ID and optional payment ID |

--------------------


### trackEvent(...)

```typescript
trackEvent(options: TrackEventOptions) => Promise<void>
```

Track a custom event

| Param         | Type                                                            | Description                                         |
| ------------- | --------------------------------------------------------------- | --------------------------------------------------- |
| **`options`** | <code><a href="#trackeventoptions">TrackEventOptions</a></code> | Event details including name, data, and optional ID |

--------------------


### getAttributionData()

```typescript
getAttributionData() => Promise<AttributionDataResult>
```

Retrieve attribution data

**Returns:** <code>Promise&lt;<a href="#attributiondataresult">AttributionDataResult</a>&gt;</code>

--------------------


### setAdditionalData(...)

```typescript
setAdditionalData(options: SetAdditionalDataOptions) => Promise<void>
```

Set additional integration data for third-party platforms

| Param         | Type                                                                          | Description                                     |
| ------------- | ----------------------------------------------------------------------------- | ----------------------------------------------- |
| **`options`** | <code><a href="#setadditionaldataoptions">SetAdditionalDataOptions</a></code> | Integration data including platform identifiers |

--------------------


### enablePIIHashing(...)

```typescript
enablePIIHashing(options: EnablePIIHashingOptions) => Promise<void>
```

Enable or disable PII hashing

| Param         | Type                                                                        | Description                              |
| ------------- | --------------------------------------------------------------------------- | ---------------------------------------- |
| **`options`** | <code><a href="#enablepiihashingoptions">EnablePIIHashingOptions</a></code> | Options to enable or disable PII hashing |

--------------------


### getPackageVersion()

```typescript
getPackageVersion() => Promise<{ version: string; }>
```

Get the SDK package version

**Returns:** <code>Promise&lt;{ version: string; }&gt;</code>

--------------------


### Interfaces


#### InitOptions

Options for SDK initialization

| Prop                 | Type                 | Description                                     |
| -------------------- | -------------------- | ----------------------------------------------- |
| **`token`**          | <code>string</code>  | Required authentication token                   |
| **`secretKey`**      | <code>string</code>  | Optional secret key for request signing         |
| **`keyId`**          | <code>string</code>  | Optional key ID for request signing             |
| **`disableIdfa`**    | <code>boolean</code> | Optional flag to disable IDFA collection on iOS |
| **`debug`**          | <code>boolean</code> | Optional flag to enable debug logging           |
| **`packageVersion`** | <code>string</code>  | SDK package version                             |


#### SignupOptions

Options for user signup

| Prop           | Type                                                         | Description              |
| -------------- | ------------------------------------------------------------ | ------------------------ |
| **`userData`** | <code><a href="#userdata">UserData</a></code>                | Required user data       |
| **`data`**     | <code><a href="#record">Record</a>&lt;string, any&gt;</code> | Optional additional data |


#### UserData

User data interface for Linkrunner SDK

| Prop                       | Type                 | Description                                           |
| -------------------------- | -------------------- | ----------------------------------------------------- |
| **`id`**                   | <code>string</code>  | Required user identifier                              |
| **`name`**                 | <code>string</code>  | Optional user name                                    |
| **`phone`**                | <code>string</code>  | Optional user phone number                            |
| **`email`**                | <code>string</code>  | Optional user email address                           |
| **`user_created_at`**      | <code>string</code>  | Optional user creation timestamp                      |
| **`is_first_time_user`**   | <code>boolean</code> | Optional flag indicating if this is a first-time user |
| **`mixpanel_distinct_id`** | <code>string</code>  | Optional Mixpanel distinct ID                         |
| **`amplitude_device_id`**  | <code>string</code>  | Optional Amplitude device ID                          |
| **`posthog_distinct_id`**  | <code>string</code>  | Optional PostHog distinct ID                          |
| **`braze_device_id`**      | <code>string</code>  | Optional Braze device ID                              |
| **`ga_app_instance_id`**   | <code>string</code>  | Optional Google Analytics app instance ID             |


#### SetUserDataOptions

Options for setting user data

| Prop           | Type                                          | Description        |
| -------------- | --------------------------------------------- | ------------------ |
| **`userData`** | <code><a href="#userdata">UserData</a></code> | Required user data |


#### CapturePaymentOptions

Options for capturing payment

| Prop            | Type                                                    | Description                                               |
| --------------- | ------------------------------------------------------- | --------------------------------------------------------- |
| **`paymentId`** | <code>string</code>                                     | Optional payment identifier                               |
| **`userId`**    | <code>string</code>                                     | Required user identifier                                  |
| **`amount`**    | <code>number</code>                                     | Required payment amount                                   |
| **`type`**      | <code><a href="#paymenttype">PaymentType</a></code>     | Optional payment type (defaults to 'DEFAULT')             |
| **`status`**    | <code><a href="#paymentstatus">PaymentStatus</a></code> | Optional payment status (defaults to 'PAYMENT_COMPLETED') |


#### RemovePaymentOptions

Options for removing payment

| Prop            | Type                | Description                 |
| --------------- | ------------------- | --------------------------- |
| **`paymentId`** | <code>string</code> | Optional payment identifier |
| **`userId`**    | <code>string</code> | Required user identifier    |


#### TrackEventOptions

Options for tracking events

| Prop            | Type                                                         | Description                                  |
| --------------- | ------------------------------------------------------------ | -------------------------------------------- |
| **`eventName`** | <code>string</code>                                          | Required event name                          |
| **`eventData`** | <code><a href="#record">Record</a>&lt;string, any&gt;</code> | Optional event data                          |
| **`eventId`**   | <code>string</code>                                          | Optional event identifier (string or number) |


#### AttributionDataResult

Result from getAttributionData

| Prop       | Type                                                        | Description      |
| ---------- | ----------------------------------------------------------- | ---------------- |
| **`data`** | <code><a href="#attributiondata">AttributionData</a></code> | Attribution data |


#### AttributionData

Attribution data returned from the SDK

| Prop               | Type                                                  | Description            |
| ------------------ | ----------------------------------------------------- | ---------------------- |
| **`deeplink`**     | <code>string</code>                                   | Optional deeplink URL  |
| **`campaignData`** | <code><a href="#campaigndata">CampaignData</a></code> | Optional campaign data |


#### CampaignData

Campaign data from attribution

| Prop                 | Type                        | Description                    |
| -------------------- | --------------------------- | ------------------------------ |
| **`id`**             | <code>string</code>         | Campaign identifier            |
| **`name`**           | <code>string</code>         | Campaign name                  |
| **`type`**           | <code>string</code>         | Campaign type                  |
| **`adNetwork`**      | <code>string \| null</code> | Optional ad network name       |
| **`installedAt`**    | <code>string</code>         | Installation timestamp         |
| **`storeClickAt`**   | <code>string \| null</code> | Optional store click timestamp |
| **`groupName`**      | <code>string</code>         | Optional campaign group name   |
| **`assetName`**      | <code>string</code>         | Optional asset name            |
| **`assetGroupName`** | <code>string</code>         | Optional asset group name      |


#### SetAdditionalDataOptions

Options for setting additional integration data

| Prop                  | Type                                                        | Description               |
| --------------------- | ----------------------------------------------------------- | ------------------------- |
| **`integrationData`** | <code><a href="#integrationdata">IntegrationData</a></code> | Required integration data |


#### IntegrationData

Integration data for third-party platforms

| Prop              | Type                | Description           |
| ----------------- | ------------------- | --------------------- |
| **`clevertapId`** | <code>string</code> | Optional CleverTap ID |


#### EnablePIIHashingOptions

Options for enabling PII hashing

| Prop          | Type                 | Description                           |
| ------------- | -------------------- | ------------------------------------- |
| **`enabled`** | <code>boolean</code> | Flag to enable or disable PII hashing |


### Type Aliases


#### Record

Construct a type with a set of properties K of type T

<code>{ [P in K]: T; }</code>


#### PaymentType

Payment type enumeration

<code>'FIRST_PAYMENT' | 'WALLET_TOPUP' | 'FUNDS_WITHDRAWAL' | 'SUBSCRIPTION_CREATED' | 'SUBSCRIPTION_RENEWED' | 'DEFAULT' | 'ONE_TIME' | 'RECURRING'</code>


#### PaymentStatus

Payment status enumeration

<code>'PAYMENT_INITIATED' | 'PAYMENT_COMPLETED' | 'PAYMENT_FAILED' | 'PAYMENT_CANCELLED'</code>

</docgen-api>
