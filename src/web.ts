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
  HandleDeeplinkOptions,
  HandleDeeplinkResult,
  AttributionDataResult,
} from './definitions';

export class LinkrunnerWeb extends WebPlugin implements LinkrunnerPlugin {
  async init(_options: InitOptions): Promise<void> {
    console.warn('Linkrunner: init is not available on web platform');
  }

  async signup(_options: SignupOptions): Promise<void> {
    console.warn('Linkrunner: signup is not available on web platform');
  }

  async setUserData(_options: SetUserDataOptions): Promise<void> {
    console.warn('Linkrunner: setUserData is not available on web platform');
  }

  async capturePayment(_options: CapturePaymentOptions): Promise<void> {
    console.warn('Linkrunner: capturePayment is not available on web platform');
  }

  async removePayment(_options: RemovePaymentOptions): Promise<void> {
    console.warn('Linkrunner: removePayment is not available on web platform');
  }

  async trackEvent(_options: TrackEventOptions): Promise<void> {
    console.warn('Linkrunner: trackEvent is not available on web platform');
  }

  async getAttributionData(): Promise<AttributionDataResult> {
    console.warn('Linkrunner: getAttributionData is not available on web platform');
    return { data: {} };
  }

  async setAdditionalData(_options: SetAdditionalDataOptions): Promise<void> {
    console.warn('Linkrunner: setAdditionalData is not available on web platform');
  }

  async enablePIIHashing(_options: EnablePIIHashingOptions): Promise<void> {
    console.warn('Linkrunner: enablePIIHashing is not available on web platform');
  }

  async handleDeeplink(_options: HandleDeeplinkOptions): Promise<HandleDeeplinkResult> {
    console.warn('Linkrunner: handleDeeplink is not available on web platform');
    return {
      msg: 'Not available on web platform',
      status: 200,
      data: {
        is_linkrunner: false,
        deeplink: _options.deeplinkUrl,
      },
    };
  }

  async getPackageVersion(): Promise<{ version: string }> {
    console.warn('Linkrunner: getPackageVersion is not available on web platform');
    return { version: '0.0.0' };
  }
}
