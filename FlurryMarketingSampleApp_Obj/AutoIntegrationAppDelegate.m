//
//  AppDelegate_Auto.m
//  FlurryMarketingSampleApp_Obj
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 Flurry. All rights reserved.
//

#import "AutoIntegrationAppDelegate.h"
#import "Flurry.h"
#import "FlurryMessaging.h"
#import "ViewController.h"
#import "DeepLinkViewController.h"
// CoreLocation is not required here.
#import <CoreLocation/CoreLocation.h>

@interface AutoIntegrationAppDelegate () {
    CLLocationManager *locationManager;
}

@end

@implementation AutoIntegrationAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // ask for location permission from users if devs want to send notification based on location
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
    } else {
        NSLog(@"Location Services are disabled");
        
    }
    // set auto integration
    [FlurryMessaging setAutoIntegrationForMessaging];
    
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
    
    //ex: key value pair store
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
