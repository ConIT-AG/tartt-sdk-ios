//
//  TarttViewController.h
//  TARTT
//
//  Created by wh33ler on 10/05/2015.
//  Copyright (c) 2015 wh33ler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TARTT/TARTT.h>

#import <WikitudeSDK/WTArchitectView.h>
#import <WikitudeSDK/WTNavigation.h>
#import <WikitudeSDK/WTArchitectViewDebugDelegate.h>

@interface SimulatorViewController : UIViewController<TARTTChannelDownloaderDelegate, TARTTChannelConfigRequestDelegate, WTArchitectViewDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *status;

- (IBAction)startChannel:(id)sender;

@end
