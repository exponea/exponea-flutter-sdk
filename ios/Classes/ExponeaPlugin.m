#import "ExponeaPlugin.h"
#if __has_include(<exponea/exponea-Swift.h>)
#import <exponea/exponea-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "exponea-Swift.h"
#endif

@implementation ExponeaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftExponeaPlugin registerWithRegistrar:registrar];
}
@end
