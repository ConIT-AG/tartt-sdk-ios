//
//  TarttViewController.m
//  TARTT
//
//  Created by wh33ler on 10/05/2015.
//  Copyright (c) 2015 wh33ler. All rights reserved.
//

#import "SimulatorViewController.h"
#import "Constants.h"

@interface SimulatorViewController ()

@property (nonatomic, strong) WTArchitectView *architectView;    
@property (nonatomic, weak) WTNavigation *architectWorldNavigation;

@property (nonatomic, strong) TARTTChannel *channel;    
@property (nonatomic, strong) TARTTChannelConfigRequest *configRequest;
@property (nonatomic, strong) TARTTChannelDownloader *downloader;
@end

@implementation SimulatorViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Simulator";
    self.progressBar.hidden = YES;  
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) 
    {        
        /* When the application starts for the first time, several UIAlert's might be shown to ask the user for camera and/or GPS access.
         Because the WTArchitectView is paused when the application resigns active (See line 86), also Architect JavaScript evaluation is interrupted.
         To resume properly from the inactive state, the Architect World has to be reloaded if and only if an active Architect World load request was active at the time the application resigned active.
         This loading state/interruption can be detected using the navigation object that was returned from the -loadArchitectWorldFromURL:withRequiredFeatures method.
         */
        if (self.architectWorldNavigation.wasInterrupted) {
            [self.architectView reloadArchitectWorld];
        }        
        /* Standard WTArchitectView rendering resuming after the application becomes active again */
        [self startWikitudeSDKRendering];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        /* Standard WTArchitectView rendering suspension when the application resignes active */
        [self stopWikitudeSDKRendering];
    }];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    /* WTArchitectView rendering is started once the view controllers view will appear */
    [self startWikitudeSDKRendering];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];    
    /* WTArchitectView rendering is stopped once the view controllers view did disappear */
    [self.configRequest cancel];
    [self.downloader cancel];    
    [self stopWikitudeSDKRendering];  
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startChannel:(id)sender 
{
    // START LOADING CHANNEL SETUP   
    
    TARTTRequestOptions *options = [TARTTRequestOptions new];
    [options addLanguage:@"de"];
    [options addEnvironment:@"test"];
    [options addTargetApi:[NSNumber numberWithInt:3]];
    [options addTargetType:@"mainanddetail"];
    [options changeState:[NSNumber numberWithInt:1]];
    
    self.configRequest = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey 
                                                                     andClientKey:kParseClientKey 
                                                                       andOptions:options];   
   
    [self.configRequest startRequestWithDelegate:self];
    self.status.text = @"Request startet";
}

#pragma mark TARTTChannelConfigRequestDelegate

-(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config
{
    self.status.text = @"Request finished";   
        // Just one Channel is available so start the init process of this channel
    NSError *error;
    self.channel = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:config error:&error];
    self.downloader = [[TARTTChannelDownloader alloc] initWithChannel:self.channel];
    [self.downloader startDownloadWithDelegate:self];

}
-(void)finishedConfigRequestWithMultipleChannels{
    self.status.text = @"Multiple Channels";
}
-(void)finishedConfigRequestWithError:(NSError *)error
{
    NSLog(@"finishedConfigRequestWithError: %@", [error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
    [alert show];
}

#pragma mark TARTTChannelDelegate

-(void)channelDownloadStarted
{
    // Download Started
    self.progressBar.hidden = NO;
    self.progressBar.progress = 0;
    self.status.text = @"Download started";
}
-(void)channelDownloadProgress:(long)bytesLoaded ofTotal:(long)bytesTotal
{    
    self.progressBar.progress = (float)bytesLoaded/(float)bytesTotal;   
}
-(void)channelDownloadFinishedWithSuccess:(TARTTChannel *)channel
{
    self.status.text = @"Download finished";
    self.progressBar.hidden = YES;  
    NSError *error;
    [[TARTTChannelManager defaultManager] cleanUpChannel:channel error:&error];
    [self loadWikitudeWithChannel:channel];    
}
-(void)channelDownloadFinishedForChannel:(TARTTChannel *)channel withError:(NSError *)error
{
    self.status.text = @"Error in Download";
    self.progressBar.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
    [alert show];
}
-(void)channelDownloadFinishedForChannel:(TARTTChannel *)channel withErrors:(NSArray *)errors
{
    for (NSError *error  in errors) {
        NSLog(@"Error: %@",error);
    }
}

-(void)loadWikitudeWithChannel:(TARTTChannel *)channel{
    NSError *deviceNotSupportedError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_Geo | WTFeature_2DTracking error:&deviceNotSupportedError] ) 
    {
        // Setup View after Download
        self.architectView = [[WTArchitectView alloc] initWithFrame:self.view.bounds motionManager:nil];
        self.architectView.delegate = self;
        [self.architectView setLicenseKey:@"otr/l3HJpaElIt8Bv36DNdxrVvywnXxhvMsMFReyvrL2Jlr54vetxIAYOi9V3PUgT7S9RaK0NC3fq+1Pkt+Twy6SjmQme9ginF30aixB+yDZLabipN3K421a3IzxP7f68pI76j+EbTz/B+O6fc1KKHJl8/CERXUScIEKhcp9XHBTYWx0ZWRfX0nZMIeLg6TgFJ4TrRDHDsuicw/ev3ghNBuwGKzJ1q29WCcOTv0dyKVFZDR2gE9lVULtncj3sckaZBayY6rbfO8oZMn1r/5lNFZjF1NjvuJlvp5q8GOS0siRRYs8tGzoAfR7X2xwNocrkmPMACMIsxWBYwn9IAa3vYCo+yRYeFprS9JAo6rkTdGmjB+tphyzmqr3vK8O/PBuWwhEecwNlkm1UFstX5ZEqd1QLbayWfCF8d33RuH5+LU4yDqead0z+9vhQ77nPGDrLJvO/k8ciIjUXl0Fc1tGlhL089fQ7Fwdl5hX1PTame58LpNrWtaPEtnYlZPdVbJNWTwEFXYc29NVZsNoTsNQ4tmKn4U8X2c4ml7FnzCiJpq2hHAMwLry57InRuyRTZbAIsvrOzUD8akU4vLti6igFUG1AK5/ivdcgObcOGxSEoWdMF/9AALI2A0LVJWKzK0k7etjtJ28vcpKJ2JyTFuEalzJYz63zJSUSmktW1R9/1vnSLTuymzFS5GRIC0EuJL3ct7B4YJOGu+0i3GmrNQ32BQmK3Wdk3uj3U2Xi+5iDXU="];      
        
        // Path to Channel Data
        NSURL *architectWorldURL = [NSURL URLWithString:[channel.currentPath stringByAppendingPathComponent:@"index.html"]];
        
        // Load Channel
        self.architectWorldNavigation =  [self.architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking]; 
        
        [self.view addSubview:self.architectView];
        self.architectView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Constraints
        NSDictionary *views = NSDictionaryOfVariableBindings(_architectView);
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[_architectView]|" options:0 metrics:nil views:views] ];
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_architectView]|" options:0 metrics:nil views:views] ];    
             
        [self startWikitudeSDKRendering];
        
    } else {
        NSLog(@"device is not supported - reason: %@", [deviceNotSupportedError localizedDescription]);
        self.status.text = @"Device not supported";
    }
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


#pragma mark WTArchitectViewDelegate
-(void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL{
    NSLog(@"InvokedURL from within the World: %@",URL);
}
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation {
    /* Architect World did finish loading */
     NSLog(@"Architect World did finish loading");
}

- (void)architectView:(WTArchitectView *)architectView didFailToLoadArchitectWorldNavigation:(WTNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"Architect World from URL '%@' could not be loaded. Reason: %@", @"URL", [error localizedDescription]);
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
