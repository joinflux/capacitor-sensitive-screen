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

```typescript
enable() => Promise<void>
```

Turn on screen-capture / snapshot protection for the current app session.

On Android this adds `FLAG_SECURE` to the activity window, which blocks
screenshots, screen recording, and the Recents thumbnail.

On iOS this arms an overlay that is shown when the app resigns active,
covering the system snapshot used in the App Switcher. The overlay is
not inserted until `willResignActive` fires.

Stateful: stays on until {@link disable} is called.

--------------------

### disable()

```typescript
disable() => Promise<void>
```

Turn off screen-capture / snapshot protection.

On Android this clears `FLAG_SECURE`. On iOS this disarms the overlay
(any overlay currently on screen is torn down when the app next becomes
active).

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
```

## Releasing

Releases are cut from `main` and published to npm by a GitHub Actions workflow
(`.github/workflows/publish.yml`) that triggers on any pushed tag matching
`v*`. The tag and the version bump are produced by the same `npm version`
command, so it's not possible to tag a release without also bumping
`package.json`.

**Prerequisites (one-time):**

*   Repo secret `NPM_TOKEN` set to an npm automation token with publish access
    to the `@joinflux` scope.
*   Local `main` clean and up to date with `origin/main`.

**To release:**

```bash
# pick the bump that fits the change
npm version patch   # 0.1.0 → 0.1.1 — bug fixes, docs
npm version minor   # 0.1.0 → 0.2.0 — new API, additive
npm version major   # 0.1.0 → 1.0.0 — breaking change

git push --follow-tags
```

`npm version` bumps `package.json` and `package-lock.json`, commits the change
with the version as the message, and creates a matching `vX.Y.Z` tag.
`git push --follow-tags` pushes the commit and the tag in one step.

**What the workflow does** on seeing the tag:

1.  Verifies the tag (e.g. `v0.2.0`) matches `package.json.version`. If not,
    it fails fast — this catches tags created by hand without a version bump.
2.  Runs `npm ci` and `npm run build`.
3.  Runs `npm publish --access public --provenance` using `NPM_TOKEN`. The
    `--provenance` flag attaches a signed attestation linking the published
    tarball back to this repo and this commit.
4.  Creates a GitHub Release for the tag with auto-generated release notes
    from the commits since the previous tag.

**If something goes wrong:**

*   *Tag pushed but workflow failed before publish* — fix the problem, delete
    the tag (`git tag -d vX.Y.Z && git push --delete origin vX.Y.Z`), and
    re-run `npm version` with the same version using `--allow-same-version`
    after resetting, or cut the next patch version. Don't try to reuse a
    version once it's been published to npm — npm rejects republishing the
    same version even after `npm unpublish`.
*   *Published to npm but Release step failed* — run `gh release create vX.Y.Z
    --generate-notes` locally to create the release after the fact.
*   *Wrong version published* — bump again (`npm version patch`) and release
    the fix forward; never rewrite history on `main`.
