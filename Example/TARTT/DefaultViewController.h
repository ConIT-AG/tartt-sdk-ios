//
//  DefaultViewController.h
//  TARTT
//
//  Created by Thomas Opiolka on 09.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TARTT/TARTT.h>

#import <WikitudeSDK/WTArchitectView.h>
#import <WikitudeSDK/WTNavigation.h>
#import <WikitudeSDK/WTArchitectViewDebugDelegate.h>

typedef NS_ENUM(NSInteger, TARTTGuiStateType) {
    /* Loading starts */
    TARTTGuiStateLoading,
    /* Loading with progress bar visible */
    TARTTGuiStateProgress,
    /* Loading targets in world after download already finished */
    TARTTGuiStateLoadingTargets,
    /* World loaded. Advise the user to scan a page */
    TARTTGuiStateScan,
    /* Multiple Worlds available. Advise the user to scan a QR-Code */
    TARTTGuiStateScanQR,
    /* Hide the Overlay */
    TARTTGuiStateHide    
};


@interface DefaultViewController : UIViewController<TARTTChannelDownloaderDelegate, 
                                                        TARTTChannelConfigRequestDelegate, 
                                                        WTArchitectViewDelegate, 
                                                        WTArchitectViewDebugDelegate,
                                                        UIAlertViewDelegate>

@property (nonatomic) WTArchitectView *architectView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIView *alphaView;
@property (weak, nonatomic) IBOutlet UILabel *scanHint;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic) TARTTRequestOptions *options;
- (IBAction)cancelClicked:(id)sender;

@end
