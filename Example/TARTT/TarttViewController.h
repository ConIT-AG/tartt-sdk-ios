//
//  TarttViewController.h
//  TARTT
//
//  Created by wh33ler on 10/05/2015.
//  Copyright (c) 2015 wh33ler. All rights reserved.
//

@import UIKit;
#import <TARTT/TARTTChannel.h>
#import <TARTT/TARTTChannelManager.h>
#import <WikitudeSDK/WTArchitectView.h>
#import <WikitudeSDK/WTNavigation.h>
#import <WikitudeSDK/WTArchitectViewDebugDelegate.h>

@interface TarttViewController : UIViewController<TARTTChannelDelegate, TARTTChannelManagerDelegate, WTArchitectViewDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

- (IBAction)startChannel:(id)sender;

@end
