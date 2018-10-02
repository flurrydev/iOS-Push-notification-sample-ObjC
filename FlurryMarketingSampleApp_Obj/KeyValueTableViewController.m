//
//  KeyValueTableViewController.m
//  FlurryMarketingSampleApp_Obj
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 Flurry. All rights reserved.
//

#import "KeyValueTableViewController.h"

@interface KeyValueTableViewController () {
    NSDictionary *appData;
    NSArray *keys;
    NSArray *values;
}

@end

@implementation KeyValueTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    appData = [[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
    keys = [appData allKeys];
    values = [appData allValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [keys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [keys objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [values objectAtIndex:indexPath.row];
    return cell;
}


@end
