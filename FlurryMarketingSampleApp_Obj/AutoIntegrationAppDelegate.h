//
//  AppDelegate_Auto.h
//  FlurryMarketingSampleApp_Obj
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 Flurry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FlurryMessaging.h>

@interface AutoIntegrationAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, FlurryMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
