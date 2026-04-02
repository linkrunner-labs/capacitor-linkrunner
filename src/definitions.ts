/**
 * User data interface for Linkrunner SDK
 */
export interface UserData {
  /** Required user identifier */
  id: string;
  /** Optional user name */
  name?: string;
  /** Optional user phone number */
  phone?: string;
  /** Optional user email address */
  email?: string;
  /** Optional user creation timestamp */
  user_created_at?: string;
  /** Optional flag indicating if this is a first-time user */
  is_first_time_user?: boolean;
  /** Optional Mixpanel distinct ID */
  mixpanel_distinct_id?: string;
  /** Optional Amplitude device ID */
  amplitude_device_id?: string;
  /** Optional PostHog distinct ID */
  posthog_distinct_id?: string;
  /** Optional Braze device ID */
  braze_device_id?: string;
  /** Optional Google Analytics app instance ID */
  ga_app_instance_id?: string;
  /** Optional Google Analytics session ID */
  ga_session_id?: string;
  /** Optional Netcore device GUID */
  netcore_device_guid?: string;
}

/**
 * Campaign data from attribution
 */
export interface CampaignData {
  /** Campaign identifier */
  id: string;
  /** Campaign name */
  name: string;
  /** Campaign type */
  type: string;
  /** Optional ad network name */
  adNetwork?: string | null;
  /** Installation timestamp */
  installedAt: string;
  /** Optional store click timestamp */
  storeClickAt?: string | null;
  /** Optional campaign group name */
  groupName?: string;
  /** Optional asset name */
  assetName?: string;
  /** Optional asset group name */
  assetGroupName?: string;
}

/**
 * Attribution data returned from the SDK
 */
export interface AttributionData {
  /** Optional deeplink URL */
  deeplink?: string;
  /** Optional campaign data */
  campaignData?: CampaignData;
}

/**
 * Integration data for third-party platforms
 */
export interface IntegrationData {
  /** Optional CleverTap ID */
  clevertapId?: string;
}

/**
 * Payment type enumeration
 */
export type PaymentType =
  | 'FIRST_PAYMENT'
  | 'WALLET_TOPUP'
  | 'FUNDS_WITHDRAWAL'
  | 'SUBSCRIPTION_CREATED'
  | 'SUBSCRIPTION_RENEWED'
  | 'DEFAULT'
  | 'ONE_TIME'
  | 'RECURRING';

/**
 * Payment status enumeration
 */
export type PaymentStatus =
  | 'PAYMENT_INITIATED'
  | 'PAYMENT_COMPLETED'
  | 'PAYMENT_FAILED'
  | 'PAYMENT_CANCELLED';

/**
 * Options for SDK initialization
 */
export interface InitOptions {
  /** Required authentication token */
  token: string;
  /** Optional secret key for request signing */
  secretKey?: string;
  /** Optional key ID for request signing */
  keyId?: string;
  /** Optional flag to disable IDFA collection on iOS */
  disableIdfa?: boolean;
  /** Optional flag to enable debug logging */
  debug?: boolean;
  /** SDK package version */
  packageVersion: string;
}

/**
 * Options for user signup
 */
export interface SignupOptions {
  /** Required user data */
  userData: UserData;
  /** Optional additional data */
  data?: Record<string, any>;
}

/**
 * Options for setting user data
 */
export interface SetUserDataOptions {
  /** Required user data */
  userData: UserData;
}

/**
 * Options for capturing payment
 */
export interface CapturePaymentOptions {
  /** Optional payment identifier */
  paymentId?: string;
  /** Required user identifier */
  userId: string;
  /** Required payment amount */
  amount: number;
  /** Optional payment type (defaults to 'DEFAULT') */
  type?: PaymentType;
  /** Optional payment status (defaults to 'PAYMENT_COMPLETED') */
  status?: PaymentStatus;
}

/**
 * Options for removing payment
 */
export interface RemovePaymentOptions {
  /** Optional payment identifier */
  paymentId?: string;
  /** Required user identifier */
  userId: string;
}

/**
 * Options for tracking events
 */
export interface TrackEventOptions {
  /** Required event name */
  eventName: string;
  /** Optional event data */
  eventData?: Record<string, any>;
  /** Optional event identifier (string or number) */
  eventId?: string;
}

/**
 * Options for setting additional integration data
 */
export interface SetAdditionalDataOptions {
  /** Required integration data */
  integrationData: IntegrationData;
}

/**
 * Options for enabling PII hashing
 */
export interface EnablePIIHashingOptions {
  /** Flag to enable or disable PII hashing */
  enabled: boolean;
}

/**
 * Result from getAttributionData
 */
export interface AttributionDataResult {
  /** Attribution data */
  data: AttributionData;
}

/**
 * Main Linkrunner plugin interface
 */
export interface LinkrunnerPlugin {
  /**
   * Initialize the Linkrunner SDK
   * @param options Initialization options including token and optional parameters
   */
  init(options: InitOptions): Promise<void>;

  /**
   * Register a new user signup
   * @param options Signup options including user data and optional additional data
   */
  signup(options: SignupOptions): Promise<void>;

  /**
   * Update user data
   * @param options User data to update
   */
  setUserData(options: SetUserDataOptions): Promise<void>;

  /**
   * Capture a payment event
   * @param options Payment details including user ID, amount, type, and status
   */
  capturePayment(options: CapturePaymentOptions): Promise<void>;

  /**
   * Remove or refund a payment
   * @param options Payment removal details including user ID and optional payment ID
   */
  removePayment(options: RemovePaymentOptions): Promise<void>;

  /**
   * Track a custom event
   * @param options Event details including name, data, and optional ID
   */
  trackEvent(options: TrackEventOptions): Promise<void>;

  /**
   * Retrieve attribution data
   * @returns Attribution data including campaign information and deeplink
   */
  getAttributionData(): Promise<AttributionDataResult>;

  /**
   * Set additional integration data for third-party platforms
   * @param options Integration data including platform identifiers
   */
  setAdditionalData(options: SetAdditionalDataOptions): Promise<void>;

  /**
   * Enable or disable PII hashing
   * @param options Options to enable or disable PII hashing
   */
  enablePIIHashing(options: EnablePIIHashingOptions): Promise<void>;

  /**
   * Get the SDK package version
   * @returns Object containing the version string
   */
  getPackageVersion(): Promise<{ version: string }>;
}
