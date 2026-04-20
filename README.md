# capacitor-sensitive-screen

Capacitor 6 plugin for per-route screen-capture and snapshot protection on
Android and iOS.

Expose two calls from your app — `enable()` when you navigate into a sensitive
route and `disable()` when you leave — and the plugin will:

*   **Android**: set `WindowManager.LayoutParams.FLAG_SECURE` on the activity
    window, which blocks screenshots, screen recording, and the Recents
    thumbnail.
*   **iOS**: when the app resigns active, cover the key window with an opaque
    overlay so the snapshot the OS stores for the App Switcher doesn't leak the
    sensitive view.
*   **Web**: no-op. (Browsers don't expose anything analogous to FLAG_SECURE,
    and there's no OS snapshot to protect.)

## Install

```bash
yarn add @joinflux/capacitor-sensitive-screen
npx cap sync
```

Requirements:

*   Capacitor `^6.0.0`
*   iOS `13.0+`
*   Android `minSdk 22`

## Usage

```ts
import { SensitiveScreen } from 'capacitor-sensitive-screen';
import { useEffect } from 'react';

export function AccountStatementRoute() {
  useEffect(() => {
    SensitiveScreen.enable();
    return () => {
      SensitiveScreen.disable();
    };
  }, []);

  // ...render sensitive content
}
```

The plugin is stateful: a call to `enable()` keeps protection on until
`disable()` runs. If your app crashes or is force-killed while enabled,
Android's `FLAG_SECURE` is scoped to the window and is gone on relaunch; the
iOS overlay is only inserted on `willResignActive`, so there's nothing to clean
up on restart.

## API

<docgen-index>

*   [`enable()`](#enable)
*   [`disable()`](#disable)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### enable()

```ts
enable() => Promise<void>
```

Turn on screen-capture / snapshot protection for the current app session.

--------------------

### disable()

```ts
disable() => Promise<void>
```

Turn off screen-capture / snapshot protection.

--------------------

</docgen-api>

## iOS: why `willResignActive`, not `didEnterBackground`

iOS takes the screenshot it uses in the App Switcher **between**
`willResignActive` and `didEnterBackground` — by the time `didEnterBackground`
fires, the snapshot has already been captured with your real UI visible. If we
only inserted the overlay on `didEnterBackground`, the App Switcher preview
would still leak the sensitive view.

So the plugin inserts the overlay in `willResignActive` (covers the snapshot
window) and removes it in `didBecomeActive` (so the user never sees it during
normal foreground use). A transient resign-active event (a pulled-down Control
Center, an incoming call banner) will flash the overlay briefly — that's
intentional; the alternative leaks the view.

`enable()` and `disable()` only flip an internal flag. They deliberately do
**not** manipulate the view hierarchy on their own — only the notification
handlers do — so there is one code path that owns the overlay lifecycle.

## Development

```bash
npm install
npm run build
npm run verify
```
