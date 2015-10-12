//
//  DefaultViewController.h
//  TARTT
//
//  Created by Thomas Opiolka on 09.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TARTT/TARTTChannel.h>
#import <TARTT/TARTTHelper.h>
#import <TARTT/TARTTChannelManager.h>
#import <TARTT/TARTTChannelConfigRequest.h>
#import <TARTT/TARTTChannelDownloader.h>

#import <WikitudeSDK/WTArchitectView.h>
#import <WikitudeSDK/WTNavigation.h>
#import <WikitudeSDK/WTArchitectViewDebugDelegate.h>


@interface DefaultViewController : UIViewController<TARTTChannelDownloaderDelegate, 
                                                        TARTTChannelConfigRequestDelegate, 
                                                        WTArchitectViewDelegate, 
                                                        WTArchitectViewDebugDelegate>


@property (weak, nonatomic) IBOutlet WTArchitectView *architectView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIView *alphaView;
@property (weak, nonatomic) IBOutlet UILabel *scanHint;


@end
