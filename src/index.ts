import { registerPlugin } from '@capacitor/core';

import type { SensitiveScreenPlugin } from './definitions';

const SensitiveScreen = registerPlugin<SensitiveScreenPlugin>('SensitiveScreen', {
  web: () => import('./web').then((m) => new m.SensitiveScreenWeb()),
});

export * from './definitions';
export { SensitiveScreen };
