//
//  AppDelegate_Auto.m
//  FlurryMarketingSampleApp_Obj
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 Flurry. All rights reserved.
//

#import "AppDelegate_Auto.h"
#import "Flurry.h"
#import "FlurryMessaging.h"
#import "ViewController.h"
#import "DeepLinkViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate_Auto () {
    CLLocationManager *locationManager;
}

@end

@implementation AppDelegate_Auto

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"auto delegate");
    
    // location service
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
    } else {
        NSLog(@"Location Services are disabled");
        
    }
    [FlurryMessaging setAutoIntegrationForMessaging];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"FlurryMarketingConfig" ofType:@"plist"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:file];
    
    // Flurry start
    [FlurryMessaging setMessagingDelegate:self];
    BOOL crashReport = [[NSString stringWithFormat:@"%@", [info objectForKey:@"enableCrashReport"]] isEqualToString:@"0"] ? NO : YES;
    
    FlurrySessionBuilder* builder = [[[[[[FlurrySessionBuilder new] withLogLevel:FlurryLogLevelDebug]
                                        withCrashReporting:crashReport]
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
    
    //ex: key value pair store
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
    // additional custom url scheme here to manage app deeplinking...
    return YES;
}

@end
