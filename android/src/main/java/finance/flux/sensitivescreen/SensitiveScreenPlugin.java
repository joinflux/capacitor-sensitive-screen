package com.joinflux.sensitivescreen;

import android.app.Activity;
import android.view.Window;
import android.view.WindowManager;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "SensitiveScreen")
public class SensitiveScreenPlugin extends Plugin {

    @PluginMethod
    public void enable(final PluginCall call) {
        final Activity activity = getActivity();
        if (activity == null) {
            call.reject("Activity unavailable");
            return;
        }
        activity.runOnUiThread(() -> {
            final Window window = activity.getWindow();
            if (window == null) {
                call.reject("Window unavailable");
                return;
            }
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE);
            call.resolve();
        });
    }

    @PluginMethod
    public void disable(final PluginCall call) {
        final Activity activity = getActivity();
        if (activity == null) {
            call.reject("Activity unavailable");
            return;
        }
        activity.runOnUiThread(() -> {
            final Window window = activity.getWindow();
            if (window == null) {
                call.reject("Window unavailable");
                return;
            }
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
            call.resolve();
        });
    }
}
