import { WebPlugin } from '@capacitor/core';

import type {
  LinkrunnerPlugin,
  InitOptions,
  SignupOptions,
  SetUserDataOptions,
  CapturePaymentOptions,
  RemovePaymentOptions,
  TrackEventOptions,
  SetAdditionalDataOptions,
  EnablePIIHashingOptions,
  SetPushTokenOptions,
  SetCustomerUserIdOptions,
  HandleDeeplinkOptions,
  HandleDeeplinkResult,
  AttributionDataResult,
} from './definitions';

export class LinkrunnerWeb extends WebPlugin implements LinkrunnerPlugin {
  async init(options: InitOptions): Promise<void> {
    console.warn('Linkrunner: init is not available on web platform', options);
  }

  async signup(options: SignupOptions): Promise<void> {
    console.warn('Linkrunner: signup is not available on web platform', options);
  }

  async setUserData(options: SetUserDataOptions): Promise<void> {
    console.warn('Linkrunner: setUserData is not available on web platform', options);
  }

  async capturePayment(options: CapturePaymentOptions): Promise<void> {
    console.warn('Linkrunner: capturePayment is not available on web platform', options);
  }

  async removePayment(options: RemovePaymentOptions): Promise<void> {
    console.warn('Linkrunner: removePayment is not available on web platform', options);
  }

  async trackEvent(options: TrackEventOptions): Promise<void> {
    console.warn('Linkrunner: trackEvent is not available on web platform', options);
  }

  async getAttributionData(): Promise<AttributionDataResult> {
    console.warn('Linkrunner: getAttributionData is not available on web platform');
    return { data: {} };
  }

  async setAdditionalData(options: SetAdditionalDataOptions): Promise<void> {
    console.warn('Linkrunner: setAdditionalData is not available on web platform', options);
  }

  async enablePIIHashing(options: EnablePIIHashingOptions): Promise<void> {
    console.warn('Linkrunner: enablePIIHashing is not available on web platform', options);
  }

  async setPushToken(options: SetPushTokenOptions): Promise<void> {
    console.warn('Linkrunner: setPushToken is not available on web platform', options);
  }

  async setCustomerUserId(options: SetCustomerUserIdOptions): Promise<void> {
    console.warn('Linkrunner: setCustomerUserId is not available on web platform', options);
  }

  async handleDeeplink(options: HandleDeeplinkOptions): Promise<HandleDeeplinkResult> {
    console.warn('Linkrunner: handleDeeplink is not available on web platform', options);
    return {};
  }

  async getPackageVersion(): Promise<{ version: string }> {
    console.warn('Linkrunner: getPackageVersion is not available on web platform');
    return { version: '0.0.0' };
  }
}
