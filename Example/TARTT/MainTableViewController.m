//
//  MainTableViewController.m
//  TARTT
//
//  Created by Thomas Opiolka on 09.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import "MainTableViewController.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell" forIndexPath:indexPath];
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"Simulator Test";
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"Default Setup Device";    
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text = @"QR-Reader Example";    
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if(indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"simulator" sender:self];
    }else if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"default" sender:self];
    }
    else if(indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"multiple" sender:self];
    }

}
@end