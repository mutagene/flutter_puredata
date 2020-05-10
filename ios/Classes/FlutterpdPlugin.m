#import "FlutterpdPlugin.h"
#if __has_include(<flutterpd/flutterpd-Swift.h>)
#import <flutterpd/flutterpd-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutterpd-Swift.h"
#endif

@implementation FlutterpdPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterpdPlugin registerWithRegistrar:registrar];
}
@end
