#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  if (@available(iOS 10.0, *)) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
  }
  [GMSServices provideAPIKey:@"AIzaSyC6UWjJLfSWWOXrnTUfraCSQj5KUTKvhUU"];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
