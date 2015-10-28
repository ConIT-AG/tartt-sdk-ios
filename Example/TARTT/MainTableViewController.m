//
//  MainTableViewController.m
//  TARTT
//
//  Created by Thomas Opiolka on 09.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import "MainTableViewController.h"
#import "DefaultViewController.h"

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
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell" forIndexPath:indexPath];
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"Simulator Test";
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"One Channel Available";
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text = @"Two Channels Available";
    }
    else if(indexPath.row == 3)
    {
        cell.textLabel.text = @"Ignore Multiple Channels";
    }
    else if(indexPath.row == 4)
    {
        cell.textLabel.text = @"No Channels Available";
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if(indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"simulator" sender:@"sim"];
    }else if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"default" sender:@"default"];
    }
    else if(indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"default" sender:@"mutli"];
    }
    else if(indexPath.row == 3)
    {
        [self performSegueWithIdentifier:@"default" sender:@"ignore"];
    }
    else if(indexPath.row == 4)
    {
        [self performSegueWithIdentifier:@"default" sender:@"no"];
    }

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *key = (NSString *)sender;
    if([key isEqualToString:@"default"])
    {
        DefaultViewController *controller = (DefaultViewController *)segue.destinationViewController;
        TARTTRequestOptions *options = [TARTTRequestOptions new];
        [options addLanguage:@"de"];
        [options addEnvType:TARTTEnvTypeTest];
        [options addTargetApi:[NSNumber numberWithInt:3]];
        [options addTargetType:TARTTTargetTypeMainAndDetail];
        controller.options = options;
    }
    else if([key isEqualToString:@"mutli"])
    {
        DefaultViewController *controller = (DefaultViewController *)segue.destinationViewController;
        TARTTRequestOptions *options = [TARTTRequestOptions new];
        [options addLanguage:@"de"];
        [options addEnvType:TARTTEnvTypeProduction];
        [options addTargetApi:[NSNumber numberWithInt:3]];
        [options addTargetType:TARTTTargetTypeMainAndDetail];
        controller.options = options;
    }
    else if([key isEqualToString:@"ignore"])
    {
        DefaultViewController *controller = (DefaultViewController *)segue.destinationViewController;
        TARTTRequestOptions *options = [TARTTRequestOptions new];
        [options addLanguage:@"de"];
        [options addEnvType:TARTTEnvTypeProduction];
        [options addTargetApi:[NSNumber numberWithInt:3]];
        [options addTargetType:TARTTTargetTypeMainAndDetail];
        [options changeIgnoreMultiChannels:YES];
        controller.options = options;
    }
    else if([key isEqualToString:@"no"])
    {
        DefaultViewController *controller = (DefaultViewController *)segue.destinationViewController;
        TARTTRequestOptions *options = [TARTTRequestOptions new];
        [options addLanguage:@"fr"];
        [options addEnvType:TARTTEnvTypeProduction];
        [options addTargetApi:[NSNumber numberWithInt:3]];
        [options addTargetType:TARTTTargetTypeMainAndDetail];
        controller.options = options;
    }

}
@end