import { registerPlugin } from '@capacitor/core';

import type { LinkrunnerPlugin, UserData, AttributionData, DeeplinkData, IntegrationData, PaymentType, PaymentStatus } from './definitions';

const LinkrunnerPluginInstance = registerPlugin<LinkrunnerPlugin>('Linkrunner', {
  web: () => import('./web').then((m) => new m.LinkrunnerWeb()),
});

/**
 * Linkrunner SDK wrapper class
 */
class Linkrunner {
  private token: string | null = null;
  private plugin: LinkrunnerPlugin;
  private packageVersion: string = '2.0.0';

  constructor() {
    this.plugin = LinkrunnerPluginInstance;
  }

  /**
   * Get the SDK package version
   * @returns The current SDK version
   */
  getPackageVersion(): string {
    return this.packageVersion;
  }

  /**
   * Set the SDK package version
   * @param version The version string to set
   */
  setPackageVersion(version: string): void {
    this.packageVersion = version;
  }

  /**
   * Initialize the Linkrunner SDK
   * @param token Required authentication token
   * @param secretKey Optional secret key for request signing
   * @param keyId Optional key ID for request signing
   * @param disableIdfa Optional flag to disable IDFA collection on iOS
   * @param debug Optional flag to enable debug logging
   */
  async init(
    token: string,
    secretKey?: string,
    keyId?: string,
    disableIdfa?: boolean,
    debug?: boolean
  ): Promise<void> {
    // Validate token is not empty/null/whitespace
    if (!token || token.trim().length === 0) {
      const error = 'Linkrunner: Init failed, token is required';
      console.error(error);
      throw new Error(error);
    }

    // Store token in instance state
    this.token = token;

    // Get package version
    const packageVersion = this.getPackageVersion();

    try {
      // Pass all parameters to native plugin including packageVersion
      await this.plugin.init({
        token,
        secretKey,
        keyId,
        disableIdfa,
        debug,
        packageVersion,
      });

      // Add debug logging for successful initialization
      if (debug) {
        console.log('Linkrunner initialized successfully');
        console.log('init response > success');
      }
    } catch (error) {
      console.error('Error initializing Linkrunner via native module', error);
      throw error;
    }
  }

  /**
   * Register a new user signup
   * @param options Signup options including user data and optional additional data
   */
  async signup(options: {
    data?: Record<string, any>;
    user_data: UserData;
  }): Promise<void> {
    // Check initialization state (token not null)
    if (!this.token) {
      const error = 'Linkrunner: Signup failed, SDK not initialized';
      console.error(error);
      throw new Error(error);
    }

    // Validate user_data contains required id field
    if (!options.user_data || !options.user_data.id || options.user_data.id.trim().length === 0) {
      const error = 'Linkrunner: Signup failed, user_data.id is required';
      console.error(error);
      throw new Error(error);
    }

    try {
      // Pass user_data and optional data to native plugin
      await this.plugin.signup({
        userData: options.user_data,
        data: options.data,
      });

      // Add debug logging for successful signup
      console.log('Linkrunner signup successful');
    } catch (error) {
      console.error('Error during Linkrunner signup', error);
      throw error;
    }
  }

  /**
   * Update user data
   * @param user_data User data to update
   */
  async setUserData(user_data: UserData): Promise<void> {
    // Check initialization state
    if (!this.token) {
      const error = 'Linkrunner: SetUserData failed, SDK not initialized';
      console.error(error);
      throw new Error(error);
    }

    // Validate user_data contains required id field
    if (!user_data || !user_data.id || user_data.id.trim().length === 0) {
      const error = 'Linkrunner: SetUserData failed, user_data.id is required';
      console.error(error);
      throw new Error(error);
    }

    try {
      // Pass user_data to native plugin
      await this.plugin.setUserData({
        userData: user_data,
      });

      // Add debug logging
      console.log('Linkrunner setUserData successful');
    } catch (error) {
      console.error('Error during Linkrunner setUserData', error);
      throw error;
    }
  }

  /**
   * Capture a payment event
   * @param options Payment details including user ID, amount, type, and status
   */
  async capturePayment(options: {
    paymentId: string;
    userId: string;
    amount: number;
    type?: PaymentType;
    status?: PaymentStatus;
  }): Promise<void> {
    // Check initialization state
    if (!this.token) {
      const error = 'Linkrunner: CapturePayment failed, SDK not initialized';
      console.error(error);
      throw new Error(error);
    }

    if (!options.paymentId) {
      const error = 'Linkrunner: CapturePayment failed, paymentId is required';
      console.error(error);
      throw new Error(error);
    }

    if (options.amount === undefined || options.amount === null) {
      const error = 'Linkrunner: CapturePayment failed, amount is required';
      console.error(error);
      throw new Error(error);
    }

    // Apply defaults: type='DEFAULT', status='PAYMENT_COMPLETED'
    const type = options.type || 'DEFAULT';
    const status = options.status || 'PAYMENT_COMPLETED';

    // Validate enum values for type
    const validTypes: PaymentType[] = [
      'FIRST_PAYMENT',
      'WALLET_TOPUP',
      'FUNDS_WITHDRAWAL',
      'SUBSCRIPTION_CREATED',
      'SUBSCRIPTION_RENEWED',
      'DEFAULT',
      'ONE_TIME',
      'RECURRING',
    ];
    if (!validTypes.includes(type)) {
      const error = `Linkrunner: CapturePayment failed, invalid payment type: ${type}`;
      console.error(error);
      throw new Error(error);
    }

    // Validate enum values for status
    const validStatuses: PaymentStatus[] = [
      'PAYMENT_INITIATED',
      'PAYMENT_COMPLETED',
      'PAYMENT_FAILED',
      'PAYMENT_CANCELLED',
    ];
    if (!validStatuses.includes(status)) {
      const error = `Linkrunner: CapturePayment failed, invalid payment status: ${status}`;
      console.error(error);
      throw new Error(error);
    }

    try {
      // Pass payment data to native plugin
      await this.plugin.capturePayment({
        paymentId: options.paymentId,
        userId: options.userId,
        amount: options.amount,
        type,
        status,
      });

      // Add debug logging
      console.log('Linkrunner capturePayment successful');
    } catch (error) {
      console.error('Error during Linkrunner capturePayment', error);
      throw error;
    }
  }

  /**
   * Remove or refund a payment
   * @param options Payment removal details including user ID and optional payment ID
   */
  async removePayment(options: {
    paymentId?: string;
    userId: string;
  }): Promise<void> {
    // Check initialization state
    if (!this.token) {
      const error = 'Linkrunner: RemovePayment failed, SDK not initialized';
      console.error(error);
      throw new Error(error);
    }

    // Validate required userId field
    if (!options.userId || options.userId.trim().length === 0) {
      const error = 'Linkrunner: RemovePayment failed, userId is required';
      console.error(error);
      throw new Error(error);
    }

    try {
      // Pass payment removal data to native plugin
      await this.plugin.removePayment({
        paymentId: options.paymentId,
        userId: options.userId,
      });

      // Add debug logging
      console.log('Linkrunner removePayment successful');
    } catch (error) {
      console.error('Error during Linkrunner removePayment', error);
      throw error;
    }
  }

  /**
   * Track a custom event
   * @param eventName Required event name
   * @param eventData Optional event data
   * @param eventId Optional event identifier (string or number)
   */
  async trackEvent(
    eventName: string,
    eventData?: Record<string, any>,
    eventId?: string | number
  ): Promise<void> {
    // Check initialization state
    if (!this.token) {
      const error = 'Linkrunner: TrackEvent failed, SDK not initialized';
      console.error(error);
      throw new Error(error);
    }

    // Validate eventName is not empty/null/whitespace
    if (!eventName || eventName.trim().length === 0) {
      const error = 'Linkrunner: TrackEvent failed, eventName is required';
      console.error(error);
      throw new Error(error);
    }

    // Process eventId
    let processedEventId: string | undefined;
    if (eventId !== undefined && eventId !== null) {
      // Convert eventId to string if it's a number
      if (typeof eventId === 'number') {
        processedEventId = eventId.toString();
      } else if (typeof eventId === 'string') {
        processedEventId = eventId;
      } else {
        // Log warning and ignore eventId if invalid type
        console.warn(`Linkrunner: TrackEvent warning, eventId has invalid type (${typeof eventId}), ignoring eventId`);
        processedEventId = undefined;
      }
    }

    try {
      // Pass event data to native plugin
      await this.plugin.trackEvent({
        eventName,
        eventData,
        eventId: processedEventId,
      });

      // Add debug logging
      console.log('Linkrunner trackEvent successful');
    } catch (error) {
      console.error('Error during Linkrunner trackEvent', error);
      throw error;
    }
  }

  /**
   * Retrieve attribution data
   * @returns Attribution data including campaign information and deeplink
   */
  async getAttributionData(): Promise<AttributionData | void> {
    // Check initialization state
    if (!this.token) {
      const error = 'Linkrunner: GetAttributionData failed, SDK not initialized';
      console.error(error);
      throw new Error(error);
    }

    try {
      // Call native plugin to retrieve attribution data
      const result = await this.plugin.getAttributionData();
      
      // Add debug logging
      console.log('Linkrunner getAttributionData successful');
      
      // Return typed AttributionData result
      return result.data;
    } catch (error) {
      console.error('Error during Linkrunner getAttributionData', error);
      throw error;
    }
  }

  /**
   * Set additional integration data for third-party platforms
   * @param integrationData Integration data including platform identifiers
   */
  async setAdditionalData(
    integrationData: IntegrationData
  ): Promise<void> {
    // Check initialization state
    if (!this.token) {
      const error = 'Linkrunner: SetAdditionalData failed, SDK not initialized';
      console.error(error);
      throw new Error(error);
    }

    // Validate integrationData is not empty (has keys)
    if (!integrationData || Object.keys(integrationData).length === 0) {
      const error = 'Linkrunner: SetAdditionalData failed, integrationData cannot be empty';
      console.error(error);
      throw new Error(error);
    }

    try {
      // Pass integration data to native plugin
      await this.plugin.setAdditionalData({
        integrationData,
      });

      // Add debug logging
      console.log('Linkrunner setAdditionalData successful');
    } catch (error) {
      console.error('Error during Linkrunner setAdditionalData', error);
      throw error;
    }
  }

  /**
   * Enable or disable PII hashing
   * @param enabled Flag to enable or disable PII hashing (defaults to true)
   */
  async enablePIIHashing(enabled?: boolean): Promise<void> {
    // Default enabled parameter to true if not provided
    const enabledValue = enabled !== undefined ? enabled : true;

    try {
      // Pass enabled flag to native plugin
      await this.plugin.enablePIIHashing({
        enabled: enabledValue,
      });

      // Add debug logging
      console.log(`Linkrunner enablePIIHashing successful (enabled: ${enabledValue})`);
    } catch (error) {
      console.error('Error during Linkrunner enablePIIHashing', error);
      throw error;
    }
  }

  /**
   * Set the push notification token for the device
   * @param pushToken Required push token (FCM on Android, APNs on iOS)
   */
  async setPushToken(pushToken: string): Promise<void> {
    if (!this.token) {
      console.error('Linkrunner: Setting push token failed, SDK not initialized');
      return;
    }

    if (!pushToken || pushToken.trim().length === 0) {
      throw new Error('Push token cannot be empty');
    }

    try {
      await this.plugin.setPushToken({ pushToken });
      console.log('Linkrunner setPushToken successful');
    } catch (error) {
      console.error('Error during Linkrunner setPushToken', error);
      throw error;
    }
  }

  async setCustomerUserId(userId: string): Promise<void> {
    if (!this.token) {
      console.error('Linkrunner: Setting customer user ID failed, SDK not initialized');
      return;
    }

    if (!userId || userId.trim().length === 0) {
      throw new Error('Customer user ID cannot be empty');
    }

    try {
      await this.plugin.setCustomerUserId({ userId });
      console.log('Linkrunner setCustomerUserId successful');
    } catch (error) {
      console.error('Error during Linkrunner setCustomerUserId', error);
      throw error;
    }
  }

  /**
   * Handle a deeplink for re-engagement attribution.
   * Call this when the app is opened via a deeplink.
   * @param deeplinkUrl The full deeplink URL that opened the app
   * @returns Resolved DeeplinkData, or null for invalid/empty input
   */
  async handleDeeplink(deeplinkUrl: string | null): Promise<DeeplinkData | null> {
    if (!deeplinkUrl || deeplinkUrl.trim().length === 0) {
      console.log('Linkrunner: handleDeeplink called with null or empty URL, ignoring');
      return null;
    }

    if (!this.token) {
      console.error('Linkrunner: handleDeeplink failed, SDK not initialized');
      return null;
    }

    try {
      const result = await this.plugin.handleDeeplink({ deeplinkUrl });
      console.log('Linkrunner handleDeeplink successful for URL:', deeplinkUrl);
      return result.data ?? null;
    } catch (error) {
      console.error('Error during Linkrunner handleDeeplink', error);
      throw error;
    }
  }
}

// Export singleton instance
const linkrunner = new Linkrunner();

export default linkrunner;
export * from './definitions';
export { Linkrunner };
