import { WebPlugin } from '@capacitor/core';

import type { SensitiveScreenPlugin } from './definitions';

export class SensitiveScreenWeb extends WebPlugin implements SensitiveScreenPlugin {
  async enable(): Promise<void> {
    // Web has no snapshot/screen-capture protection primitive — no-op.
  }

  async disable(): Promise<void> {
    // Web has no snapshot/screen-capture protection primitive — no-op.
  }
}
