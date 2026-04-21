export type SensitiveScreenOverlayStyle = 'solid' | 'blur';

export type SensitiveScreenBlurStyle =
  | 'light'
  | 'dark'
  | 'regular'
  | 'prominent'
  | 'extraLight';

export interface SensitiveScreenEnableOptions {
  /**
   * iOS only. Visual style of the snapshot-protection overlay.
   *
   * - `'solid'`: fills the window with {@link backgroundColor}.
   * - `'blur'`: uses a `UIVisualEffectView` with a `UIBlurEffect` of
   *   {@link blurStyle}.
   *
   * Default: `'solid'`.
   */
  style?: SensitiveScreenOverlayStyle;

  /**
   * iOS only. Hex color string (`'#RRGGBB'` or `'#RRGGBBAA'`) used as the
   * overlay background when {@link style} is `'solid'`. Default: `'#000000'`.
   */
  backgroundColor?: string;

  /**
   * iOS only. `UIBlurEffect` style used when {@link style} is `'blur'`.
   * Default: `'regular'`.
   */
  blurStyle?: SensitiveScreenBlurStyle;

  /**
   * iOS only. Name of an image in the app's main bundle / asset catalog to
   * render centered on top of the overlay (e.g. a logo). The consuming app is
   * responsible for shipping the asset natively.
   */
  imageName?: string;
}

export interface SensitiveScreenPlugin {
  /**
   * Turn on screen-capture / snapshot protection for the current app session.
   *
   * On Android this adds `FLAG_SECURE` to the activity window, which blocks
   * screenshots, screen recording, and the Recents thumbnail.
   *
   * On iOS this arms an overlay that is shown when the app resigns active,
   * covering the system snapshot used in the App Switcher. The overlay is
   * not inserted until `willResignActive` fires.
   *
   * The `options` argument configures the iOS overlay's appearance. It is
   * ignored on Android (protection is drawn by the OS via `FLAG_SECURE`) and
   * Web (no-op). Each call replaces the previous options wholesale — pass
   * every field you want set.
   *
   * Stateful: stays on until {@link disable} is called.
   */
  enable(options?: SensitiveScreenEnableOptions): Promise<void>;

  /**
   * Turn off screen-capture / snapshot protection.
   *
   * On Android this clears `FLAG_SECURE`. On iOS this disarms the overlay
   * (any overlay currently on screen is torn down when the app next becomes
   * active).
   */
  disable(): Promise<void>;
}
