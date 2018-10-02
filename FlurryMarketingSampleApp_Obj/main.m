//
//  main.m
//  FlurryMarketingSampleApp_Obj
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 Flurry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AppDelegate_Auto.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        // default
        // return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"FlurryNotificationConfig" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        BOOL manualStyle =  ![[[[jsonDict objectForKey:@"FlurryNotificationSettings"] objectForKey:@"APNS"] objectForKey:@"isAutoIntegration"] boolValue];
        
        NSString *delegateClass = manualStyle
        ? NSStringFromClass([AppDelegate class])
        : NSStringFromClass([AppDelegate_Auto class]);
        return UIApplicationMain(argc, argv, nil, delegateClass);
        
    }
}
