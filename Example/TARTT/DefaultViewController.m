//
//  DefaultViewController.m
//  TARTT
//
//  Created by Thomas Opiolka on 09.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DefaultViewController.h"
#import "DefaultViewController+PluginLoading.h"
#import "Constants.h"
#import "WikitudeManager.h"

@interface DefaultViewController ()

@property (nonatomic) WTNavigation *architectWorldNavigation;

@property (nonatomic, strong) TARTTChannel *channel;     
@property (nonatomic, strong) TARTTChannelConfigRequest *configRequest;
@property (nonatomic, strong) TARTTChannelDownloader *downloader;
@property (nonatomic) BOOL multipleWorldsAvailable;
@property (nonatomic) BOOL qrScannerShouldRun;

@end

@implementation DefaultViewController

#pragma mark ViewEvents
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Default";       
    
    NSError *deviceNotSupportedError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_Geo | WTFeature_2DTracking error:&deviceNotSupportedError] ) 
    {
        // Check for Camera access
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) 
        {
            [self setUpWikitude];
        }
        else if(authStatus == AVAuthorizationStatusDenied)
        {
            [self cameraAccessDenied];
        } 
        else if(authStatus == AVAuthorizationStatusNotDetermined)
        {
            // Ask the user
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    [self performSelectorOnMainThread:@selector(setUpWikitude) withObject:nil waitUntilDone:NO];
                } else {
                    [self performSelectorOnMainThread:@selector(cameraAccessDenied) withObject:nil waitUntilDone:NO];
                }
            }];
        }       
    } else {
        NSLog(@"device is not supported - reason: %@", [deviceNotSupportedError localizedDescription]);
        
        [self setGuiForState:TARTTGuiStateHide];       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:deviceNotSupportedError.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];
    }    
    
    // register Notifications so wikitude can reorganize if interrupted
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) 
     {        
         if (self.architectWorldNavigation.wasInterrupted) {
             [self.architectView reloadArchitectWorld];
         }                 
         [self startWikitudeSDKRendering];
     }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        /* Standard WTArchitectView rendering suspension when the application resignes active */
        [self stopWikitudeSDKRendering];
    }];

}
-(void)viewWillDisappear:(BOOL)animated{
    // cancel request/download and stop barcode plugin
    [self.downloader cancel];
    [self.configRequest cancel];
    // IMPORTANT 
    [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    [self stopWikitudeSDKRendering];
}
-(void)viewDidAppear:(BOOL)animated{
    [self startWikitudeSDKRendering];
    if(self.qrScannerShouldRun)
        [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
}
#pragma mark Wikitude Setup

// Setup the Wikitude View with a Dummy World so we have time to start the download 
// The Cam will be shown while downloading
-(void)setUpWikitude{
    self.architectView = [WikitudeManager architectView];
    [self.architectView setFrame:self.view.bounds];
    self.architectView.delegate = self;
    self.architectView.debugDelegate = self;
    [self.architectView setLicenseKey:@"otr/l3HJpaElIt8Bv36DNdxrVvywnXxhvMsMFReyvrL2Jlr54vetxIAYOi9V3PUgT7S9RaK0NC3fq+1Pkt+Twy6SjmQme9ginF30aixB+yDZLabipN3K421a3IzxP7f68pI76j+EbTz/B+O6fc1KKHJl8/CERXUScIEKhcp9XHBTYWx0ZWRfX0nZMIeLg6TgFJ4TrRDHDsuicw/ev3ghNBuwGKzJ1q29WCcOTv0dyKVFZDR2gE9lVULtncj3sckaZBayY6rbfO8oZMn1r/5lNFZjF1NjvuJlvp5q8GOS0siRRYs8tGzoAfR7X2xwNocrkmPMACMIsxWBYwn9IAa3vYCo+yRYeFprS9JAo6rkTdGmjB+tphyzmqr3vK8O/PBuWwhEecwNlkm1UFstX5ZEqd1QLbayWfCF8d33RuH5+LU4yDqead0z+9vhQ77nPGDrLJvO/k8ciIjUXl0Fc1tGlhL089fQ7Fwdl5hX1PTame58LpNrWtaPEtnYlZPdVbJNWTwEFXYc29NVZsNoTsNQ4tmKn4U8X2c4ml7FnzCiJpq2hHAMwLry57InRuyRTZbAIsvrOzUD8akU4vLti6igFUG1AK5/ivdcgObcOGxSEoWdMF/9AALI2A0LVJWKzK0k7etjtJ28vcpKJ2JyTFuEalzJYz63zJSUSmktW1R9/1vnSLTuymzFS5GRIC0EuJL3ct7B4YJOGu+0i3GmrNQ32BQmK3Wdk3uj3U2Xi+5iDXU="];             
    
    // Path to Channel Data
    NSURL *architectWorldURL = [NSURL URLWithString:[TARTTHelper getDummyChannelPath]];
    
    // Load Channel
    [self.architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking]; 
    
    [self.view addSubview:self.architectView];
    self.architectView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(_architectView);
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[_architectView]|" options:0 metrics:nil views:views] ];
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_architectView]|" options:0 metrics:nil views:views] ];
    
    [self startWikitudeSDKRendering];
    [self startTARTT];
}
// Cam access was denied so we show a hint to the user 
-(void)cameraAccessDenied{
    [self setGuiForState:TARTTGuiStateHide];       
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please allow Camera access in the settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
    [alert show];
}


#pragma mark GuiMethods
- (IBAction)cancelClicked:(id)sender 
{
    // Cancel and reset with Dummy World
    [self.downloader cancel];
    [self.configRequest cancel];
    NSURL *architectWorldURL = [NSURL URLWithString:[TARTTHelper getDummyChannelPath]];
    [self.architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking]; 
    self.channel = nil;
    if(self.multipleWorldsAvailable)
        [self startTARTT];
    else
        [self setGuiForState:TARTTGuiStateHide];
}
/*
    Here we handle the GUI Elements for every State we can be in 
 */
-(void)setGuiForState:(TARTTGuiStateType)state{
    [self.view sendSubviewToBack:self.architectView];
    self.qrScannerShouldRun = NO;
    switch (state) {
        case TARTTGuiStateHide:            
            self.progressBar.hidden = YES;
            self.alphaView.hidden = YES;
            self.scanHint.hidden = YES;
            self.loadingIndicator.hidden = YES;
            self.cancelButton.hidden = YES;
            break;            
        case TARTTGuiStateLoading:
            self.alphaView.hidden = NO;
            self.progressBar.hidden = YES; 
            self.scanHint.hidden = YES;
            self.loadingIndicator.hidden = NO; 
            self.cancelButton.hidden = NO;
            [self.loadingIndicator startAnimating];
            break;
        case TARTTGuiStateProgress:
            self.alphaView.hidden = NO;
            self.progressBar.hidden = NO;
            self.loadingIndicator.hidden = NO; 
            self.scanHint.hidden = YES;
            self.cancelButton.hidden = NO;
            [self.loadingIndicator startAnimating];
            break;
        case TARTTGuiStateLoadingTargets:
            self.alphaView.hidden = NO;
            self.progressBar.hidden = YES; 
            self.scanHint.hidden = YES;
            self.loadingIndicator.hidden = NO; 
            self.cancelButton.hidden = NO;
            [self.loadingIndicator startAnimating];
            break;    
        case TARTTGuiStateScan:
            self.progressBar.hidden = YES;
            self.loadingIndicator.hidden = YES;
            self.alphaView.hidden = NO;
            self.scanHint.hidden =  NO;
            self.cancelButton.hidden = YES;
            self.scanHint.text = @"Bitte Seite scannen";
            self.qrScannerShouldRun = YES;
            break;
        case TARTTGuiStateScanQR:
            self.progressBar.hidden = YES;
            self.loadingIndicator.hidden = YES;
            self.alphaView.hidden = NO;
            self.scanHint.hidden =  NO;
            self.cancelButton.hidden = YES;
            self.scanHint.text = @"Bitte QR Code scannen";
            self.qrScannerShouldRun = YES;
            break;    
    }
}

#pragma mark TARTT
-(void)startTARTT
{    
    [self setGuiForState:TARTTGuiStateLoading];
 
    // start loading config settings with the options defined in the MainTableViewController 
    self.configRequest = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey 
                                                                     andClientKey:kParseClientKey 
                                                                       andOptions:self.options];
    [self.configRequest startRequestWithDelegate:self];
}


#pragma mark TARTTChannelConfigRequestDelegate

/* Config was received so we are able to download all the needed files into cache directory */
-(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config
{   
    NSError *error;
    self.channel = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:config error:&error];   
    self.downloader = [[TARTTChannelDownloader alloc] initWithChannel:self.channel];
    [self.downloader startDownloadWithDelegate:self];
        
}
/* Multiple Channels are available. Will not be called if ignoreMultiChannels is set to YES in the options */
-(void)finishedConfigRequestWithMultipleChannels
{
    self.multipleWorldsAvailable = YES;
    [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    [self setGuiForState:TARTTGuiStateScanQR];
}
/* Error handling */
-(void)finishedConfigRequestWithError:(NSError *)error
{
    /* No Channels availalbe for options in Parse */
    if(error.code == TARTTErrorNoChannelsAvailable)
    {   
        NSLog(@"TARTTErrorNoChannelsAvailable: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];        
       
    }
    /* Selected Channel isn't available in Parse */
    else if(error.code == TARTTErrorCouldNotSelectChannel)
    {
        NSLog(@"TARTTErrorCouldNotSelectChannel: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];         
    }
    else{
        NSLog(@"finishedConfigRequestWithError: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];
    }     
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // go back to SCAN GQ Code mode so the user still has options
    [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    [self setGuiForState:TARTTGuiStateScanQR];
}

#pragma mark TARTTChannelDelegate

/* Download started. Only called if there is at least one file to download */
-(void)channelDownloadStarted
{
    [self setGuiForState:TARTTGuiStateProgress];
    self.progressBar.progress = 0;
}
-(void)channelDownloadProgress:(long)bytesLoaded ofTotal:(long)bytesTotal
{    
    self.progressBar.progress = (float)bytesLoaded/(float)bytesTotal; 
}
-(void)channelDownloadFinishedWithSuccess:(TARTTChannel *)channel
{    
    NSError *error;
    /* This deleted old version of a channel and cleansup temp folders */
   [[TARTTChannelManager defaultManager] cleanUpChannel:channel error:&error];   
    [self setGuiForState:TARTTGuiStateLoading];
    
    // Path to Channel Data
    NSURL *architectWorldURL = [NSURL URLWithString:[channel.currentPath stringByAppendingPathComponent:@"index.html"]];
    // Load Channel
    self.architectWorldNavigation =  [self.architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking];     
}
-(void)channelDownloadFinishedForChannel:(TARTTChannel *)channel withError:(NSError *)error
{   
    /* Error downloading at least on file */
    if(error.code == TARTTErrorDownloadIncomplete)
    {
        NSLog(@"TARTTErrorDownloadIncomplete: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];         
    }
    /* Error while trying to move files or create folder in cache */
    else if(error.code == TARTTErrorCache)
    {
        NSLog(@"TARTTErrorCache: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];         
    }
    else{   
        [self setGuiForState:TARTTGuiStateHide];           
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];
    }
}

/* Debug option. If more than one file has an error it can be logged in here */
-(void)channelDownloadFinishedForChannel:(TARTTChannel *)channel withErrors:(NSArray *)errors
{
    for (NSError *error  in errors) {
        NSLog(@"Error: %@",error);
    }
}


#pragma mark WTArchitectViewDelegate
-(void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL
{
    NSLog(@"InvokedURL from within the World: %@",URL);
    if ( [[URL absoluteString] hasPrefix:@"architectsdk://targetsLoaded"] )
    {
        NSLog(@"##EVENT:%@",URL);
        [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
        [self setGuiForState:TARTTGuiStateScan];  
    }
    else if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnEnterFieldOfVision"])
    {
        NSLog(@"##EVENT:%@",URL);
        [self setGuiForState:TARTTGuiStateHide];  
        [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    }
    else if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnExitFieldOfVision"])
    {
        NSLog(@"##EVENT:%@",URL);
        [self setGuiForState:TARTTGuiStateScan];  
        //[self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    }
    else if([[URL absoluteString] hasPrefix:@"architectsdk://qrCodeTrigger"])
    {        
        NSLog(@"##EVENT:%@",URL);        
        NSDictionary *parameters = [TARTTHelper URLParameterFromURL:URL];
        NSString *code = [parameters objectForKey:@"code"];
        NSString *decoded = [code stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        parameters = [TARTTHelper URLParameterFromURL:[NSURL URLWithString:decoded]];        
        NSString *channelKey = [parameters objectForKey:@"channelKey"];
        NSString *language = [parameters objectForKey:@"language"];
        NSString *targetType = [parameters objectForKey:@"targetType"];
        NSString *envType = [parameters objectForKey:@"envType"];
        NSString *state = [parameters objectForKey:@"state"];
        NSString *targetApi = [parameters objectForKey:@"targetApi"];
        if(language != nil){
            NSLog(@"Overwriting Language to %@", language);
            [self.options addLanguage:language];
        }
        if(targetType != nil){
            NSLog(@"Overwriting targetType to %@", targetType);
            [self.options forceTargetType:targetType];
        }
        if(envType != nil){
            NSLog(@"Overwriting Environment to %@", envType);
            [self.options forceEnvType:envType];
        }
        if(state != nil){
            NSLog(@"Overwriting State to %@", state);
            [self.options forceState:[NSNumber numberWithInteger:[state integerValue]]];
        }
        if(targetApi != nil){
            NSLog(@"Overwriting Target API to %@", targetApi);
            [self.options addTargetApi:[NSNumber numberWithInteger:[targetApi integerValue]]];
        }
        
        if([channelKey isEqualToString:self.channel.config.channelKey])
        {
            NSLog(@"Ignoring QR-Code because its already loaded or still loading");
            return;
        }                
        [self setGuiForState:TARTTGuiStateLoading];  
        [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin];        
        NSLog(@"Channel %@ selected", channelKey);
        [self.configRequest selectChannel:channelKey andDelegate:self];
    }
    else if( [[URL absoluteString] hasPrefix:@"architectsdk://readyForExecution"])
    {
         NSLog(@"##EVENT:%@",URL);
        NSDictionary *worldConfig = @{ @"Key1": @"Val1" };
        NSString *json = [TARTTHelper convertToJson:worldConfig];
        NSString *javascript = [NSString stringWithFormat:@"startExperience('%@');",json];
        NSLog(@"Send Javascript: %@",javascript);
        [self setGuiForState:TARTTGuiStateLoadingTargets];
        [self.architectView callJavaScript:javascript];
    }
    else if([[URL absoluteString] hasPrefix:@"architectsdk://handleException"])
    {
        //architectsdk://handleException?code=404&message=Not+found
        NSDictionary *parameters = [TARTTHelper URLParameterFromURL:URL];
        NSLog(@"Error from within the AR - World: Code:%@ Message:%@",[parameters objectForKey:@"code"], [parameters objectForKey:@"message"]);
        
    }
    
    //////////////////////
    // SAMPLE GOOGLE ANALYTICS IMPL
    /////////////////////////
    /*
    if([[URL absoluteString] hasPrefix:@"architectsdk://trackEvent"])
    {
        //architectsdk://trackEvent?ga_action=loadDetailTargets&ga_label=true
        NSDictionary *parameters = [TARTTHelper URLParameterFromURL:URL];
        NSNumber *val = [NSNumber numberWithInteger:[[parameters objectForKey:@"ga_value"] integerValue]];
        [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"category"
                                                                                          action:[parameters objectForKey:@"ga_action"]
                                                                                           label:[parameters objectForKey:@"ga_label"]
                                                                                           value:val] build]];
    }else{
        NSDictionary *parameters = [TARTTHelper URLParameterFromURL:URL];
        [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"category"
                                                                                          action:[URL host]
                                                                                           label:[parameters description]
                                                                                           value:[NSNumber numberWithInt:1]] build]];
    }*/   

}
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation {
    /* Architect World did finish loading */
    NSLog(@"Architect World did finish loading");
}

- (void)architectView:(WTArchitectView *)architectView didFailToLoadArchitectWorldNavigation:(WTNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"Architect World from URL '%@' could not be loaded. Reason: %@", @"URL", [error localizedDescription]);
}

#pragma mark - Private Methods
/* Convenience methods to manage WTArchitectView rendering. */
- (void)startWikitudeSDKRendering
{    
    /* To check if the WTArchitectView is currently rendering, the isRunning property can be used */
    if ( ![self.architectView isRunning] ) {
        
        /* To start WTArchitectView rendering and control the startup phase, the -start:completion method can be used */
        [self.architectView start:^(WTStartupConfiguration *configuration) {
            
            /* Use the configuration object to take control about the WTArchitectView startup phase */
            /* You can e.g. start with an active front camera instead of the default back camera */            
            // configuration.captureDevicePosition = AVCaptureDevicePositionFront;
            
        } completion:^(BOOL isRunning, NSError *error) {
            
            /* The completion block is called right after the internal start method returns.
             
             NOTE: In case some requirements are not given, the WTArchitectView might not be started and returns NO for isRunning.
             To determine what caused the problem, the localized error description can be used.
             */
            if ( !isRunning ) {
                NSLog(@"WTArchitectView could not be started. Reason: %@", [error localizedDescription]);
            }
        }];
    }
}

- (void)stopWikitudeSDKRendering {
    
    /* The stop method is blocking until the rendering and camera access is stopped */
    if ( [self.architectView isRunning] ) {
        [self.architectView stop];
    }
}


#pragma mark - View Rotation
- (BOOL)shouldAutorotate {    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{    
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {    
    /* When the device orientation changes, specify if the WTArchitectView object should rotate as well */
    [self.architectView setShouldRotate:YES toInterfaceOrientation:toInterfaceOrientation];
}

/* The debug delegate can be used to respond to internal issues, e.g. the user declined camera or GPS access.
 
 NOTE: The debug delegate method -architectView:didEncounterInternalWarning is currently not used.
 */
#pragma mark WTArchitectViewDebugDelegate
- (void)architectView:(WTArchitectView *)architectView didEncounterInternalWarning:(WTWarning *)warning {
    /* Intentionally Left Blank */
}
- (void)architectView:(WTArchitectView *)architectView didEncounterInternalError:(NSError *)error {
    NSLog(@"WTArchitectView encountered an internal error '%@'", [error localizedDescription]);
}
- (void)dealloc
{
    /* Remove this view controller from the default Notification Center so that it can be released properly */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
