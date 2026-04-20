#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(SensitiveScreenPlugin, "SensitiveScreen",
    CAP_PLUGIN_METHOD(enable, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(disable, CAPPluginReturnPromise);
)
