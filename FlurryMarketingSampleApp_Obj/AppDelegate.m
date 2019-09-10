//
//  AppDelegate.m
//  FlurryMarketingSampleApp_Obj
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 Flurry. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import <NotificationCenter/NotificationCenter.h>
#import <UserNotifications/UserNotifications.h>
#import "FlurryMessaging.h"
#import "ViewController.h"
#import "DeepLinkViewController.h"
// CoreLocation is not required here.
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate () {
    CLLocationManager *locationManager;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // location service (not required), developers can send notifications to users based on location. If so, developers should ask for permission first.
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
    } else {
        NSLog(@"Location Services are disabled");
        
    }
    
    // register remote notification for ios version >= 10 or < 10
    if (@available(iOS 10.0, *)) {
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error){
                if (!error && granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                      [application registerForRemoteNotifications];
                    });
                    
                    NSLog(@"Push registetration success!");
                } else {
                    NSLog(@"Push registration Failed. ERROR : %@ - %@", error.localizedFailureReason, error.localizedDescription);
                }
            }];
        }
    } else {
        // iOS version less than 10
        UIApplication *application = [UIApplication sharedApplication];
        if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
            [application registerForRemoteNotifications];
        }
            
    }
    
    // get flurry infomation in the file "FlurryMarketingConfig.plist"
    NSString *file = [[NSBundle mainBundle] pathForResource:@"FlurryMarketingConfig" ofType:@"plist"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:file];
    
    // Flurry start
    [FlurryMessaging setMessagingDelegate:self];
    NSNumber * crashReport = [info valueForKey:@"enableCrashReport"];
    BOOL enableCrashReport = [crashReport boolValue];
    FlurrySessionBuilder* builder = [[[[[[FlurrySessionBuilder new] withLogLevel:FlurryLogLevelDebug]
                                        withCrashReporting:enableCrashReport]
                                       withSessionContinueSeconds:[[info objectForKey:@"sessionSeconds"] integerValue]]
                                      withAppVersion:[info objectForKey:@"appVersion"]]
                                     withIncludeBackgroundSessionsInMetrics:YES] ;
    [Flurry startSession:[info objectForKey:@"apiKey"] withSessionBuilder:builder];
    return YES;
}

# pragma mark - flurry messaging delegate methods

// delegate method, invoked when a notification is received
-(void)didReceiveMessage:(FlurryMessage *)message {
    NSLog(@"didReceiveMessage = %@", [message description]);
    // additional logic here
    
    /*
     Ex: Key value pair store.
     (FlurryMessage)message contians key-value pairs that set in the flurry portal when starting a compaign.
     You can get values by using message.appData["key name"].
     In this sample app,  all the key value information will be displayed in the KeyValueTableView.
     */
    
    NSUserDefaults *sharedPref = [NSUserDefaults standardUserDefaults];
    [sharedPref setObject:message.appData forKey:@"data"];
    [sharedPref synchronize];
    
}

// delegate method, invoked when an action is performed
-(void)didReceiveActionWithIdentifier:(NSString *)identifier message:(FlurryMessage *)message {
    NSLog(@"didReceiveAction %@, Message = %@", identifier, [message description]);
    // additional logic here
    
    NSUserDefaults *sharedPref = [NSUserDefaults standardUserDefaults];
    [sharedPref setObject:message.appData forKey:@"data"];
    [sharedPref synchronize];
    
    // ex: deep links (open url)
    if (message.appData[@"deeplink"] != nil) {
        NSString *urlStr = message.appData[@"deeplink"];
        NSURL *url = [NSURL URLWithString:urlStr];
        UIApplication *application = [UIApplication sharedApplication];
        if (@available(iOS 10.0, *)) {
            [application openURL:url options:@{} completionHandler:^(BOOL success) {
                NSLog(@"success, ios10+");
            }];
        } else {
            if([application canOpenURL:url]){
                [application openURL:url];
                NSLog(@"success, ios 10-");
            }
        };
    }
}

# pragma mark - url scheme

/*
    Optional method for deeplink usage, this method opens a resource specified by a URL (deeplink ex: flurry://
    marketing/deeplink). It handles and manages the opening of registered urls and match those with specific
    destiniations within your app
 */

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if ([[url scheme] isEqualToString:@"flurry"] && [[url host] isEqualToString:@"marketing"] && [[url path] isEqualToString:@"/deeplink"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UINavigationController *nav = [storyboard instantiateInitialViewController];
        DeepLinkViewController *deeplinkVC = [storyboard instantiateViewControllerWithIdentifier:@"deeplink"];
        [nav pushViewController:deeplinkVC animated:YES];
        [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
    }
    // else {...} additional custom url scheme here to manage app deeplinking...
    return YES;
}

# pragma mark - Notification Delegate Methods


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Enable passing the device token to flurry
    [FlurryMessaging setDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    // check if the notification is from Flurry
    if ([FlurryMessaging isFlurryMsg:userInfo]) {
        [FlurryMessaging receivedRemoteNotification:userInfo withCompletionHandler:^{
            completionHandler(UIBackgroundFetchResultNewData);
        }];
    }
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    if ([FlurryMessaging isFlurryMsg:response.notification.request.content.userInfo]) {
        [FlurryMessaging receivedNotificationResponse:response withCompletionHandler:^{
            completionHandler();
            // ... add your handling here
            NSDictionary *userInfo = response.notification.request.content.userInfo;
            NSDictionary *appData = userInfo[@"appData"];
            if ([appData objectForKey:@"name"]) {
                NSString *name = appData[@"name"];
                NSLog(@"%@", name);
            } else {
                NSLog(@"no such key");
            }
        }];
    }
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    if ([FlurryMessaging isFlurryMsg:notification.request.content.userInfo]) {
        [FlurryMessaging presentNotification:notification withCompletionHandler:^{
            // present user an alert if app is in foreground when a notification is coming
            completionHandler(UNNotificationPresentationOptionAlert);
        }];
    }
}


# pragma mark - location service
// If users change location authorization status, flurry will start/stop tracking user's location accordingly.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        BOOL permission = [Flurry trackPreciseLocation:YES];
        NSLog(@"%s: can track precise location: %d", __PRETTY_FUNCTION__, permission);
    } else if (status == kCLAuthorizationStatusDenied) {
        BOOL permission = [Flurry trackPreciseLocation:NO];
        NSLog(@"%s: can track precise location: %d", __PRETTY_FUNCTION__, permission);
    }
}

@end

