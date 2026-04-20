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
   * Stateful: stays on until {@link disable} is called.
   */
  enable(): Promise<void>;

  /**
   * Turn off screen-capture / snapshot protection.
   *
   * On Android this clears `FLAG_SECURE`. On iOS this disarms the overlay
   * (any overlay currently on screen is torn down when the app next becomes
   * active).
   */
  disable(): Promise<void>;
}
