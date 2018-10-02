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
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"FlurryNotificationConfig" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        BOOL manualStyle =  ![[[[jsonDict objectForKey:@"FlurryNotificationSettings"] objectForKey:@"APNS"] objectForKey:@"isAutoIntegration"] boolValue];
        
        // If manual style is yes, use AppDelegate class for Manual Use. If no, use AppDelegate_Auto class instead.
        NSString *delegateClass = manualStyle
        ? NSStringFromClass([AppDelegate class])
        : NSStringFromClass([AppDelegate_Auto class]);
        return UIApplicationMain(argc, argv, nil, delegateClass);
    }
}
