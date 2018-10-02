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
        // get infomation in the file "FlurryNotificationConfig.json" to find out integraiton mode
        NSString *file = [[NSBundle mainBundle] pathForResource:@"FlurryMarketingConfig" ofType:@"plist"];
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:file];
        NSNumber * manualStyle = [data valueForKey:@"isAuto"];
        BOOL isAuto = [manualStyle boolValue];
        // If manual style is yes, use AppDelegate class for Manual Use. If no, use AppDelegate_Auto class instead
        NSString *delegateClass = isAuto
        ? NSStringFromClass([AppDelegate_Auto class])
        : NSStringFromClass([AppDelegate class]);
        return UIApplicationMain(argc, argv, nil, delegateClass);
    }
}
