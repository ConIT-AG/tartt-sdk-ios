//
//  MutlipleChannelsViewController.m
//  TARTT
//
//  Created by Thomas Opiolka on 12.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import "MutlipleChannelsViewController.h"

#import <TARTT/TARTTHelper.h>

@interface MutlipleChannelsViewController ()

@end

@implementation MutlipleChannelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Multiple Channels";    
    
       
    NSError *deviceNotSupportedError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_Geo | WTFeature_2DTracking error:&deviceNotSupportedError] ) 
    {
        // Setup View after Download
        //self.architectView = [[WTArchitectView alloc] initWithFrame:self.view.bounds motionManager:nil];
        self.architectView.delegate = self;
        [self.architectView setLicenseKey:@"otr/l3HJpaElIt8Bv36DNdxrVvywnXxhvMsMFReyvrL2Jlr54vetxIAYOi9V3PUgT7S9RaK0NC3fq+1Pkt+Twy6SjmQme9ginF30aixB+yDZLabipN3K421a3IzxP7f68pI76j+EbTz/B+O6fc1KKHJl8/CERXUScIEKhcp9XHBTYWx0ZWRfX0nZMIeLg6TgFJ4TrRDHDsuicw/ev3ghNBuwGKzJ1q29WCcOTv0dyKVFZDR2gE9lVULtncj3sckaZBayY6rbfO8oZMn1r/5lNFZjF1NjvuJlvp5q8GOS0siRRYs8tGzoAfR7X2xwNocrkmPMACMIsxWBYwn9IAa3vYCo+yRYeFprS9JAo6rkTdGmjB+tphyzmqr3vK8O/PBuWwhEecwNlkm1UFstX5ZEqd1QLbayWfCF8d33RuH5+LU4yDqead0z+9vhQ77nPGDrLJvO/k8ciIjUXl0Fc1tGlhL089fQ7Fwdl5hX1PTame58LpNrWtaPEtnYlZPdVbJNWTwEFXYc29NVZsNoTsNQ4tmKn4U8X2c4ml7FnzCiJpq2hHAMwLry57InRuyRTZbAIsvrOzUD8akU4vLti6igFUG1AK5/ivdcgObcOGxSEoWdMF/9AALI2A0LVJWKzK0k7etjtJ28vcpKJ2JyTFuEalzJYz63zJSUSmktW1R9/1vnSLTuymzFS5GRIC0EuJL3ct7B4YJOGu+0i3GmrNQ32BQmK3Wdk3uj3U2Xi+5iDXU="];             
        
        // Path to Channel Data
        NSURL *architectWorldURL = [NSURL URLWithString:[TARTTHelper getDummyChannelPath]];
        
        // Load Channel
        [self.architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking]; 
        
        //  [self.view addSubview:self.architectView];
        self.architectView.translatesAutoresizingMaskIntoConstraints = NO;        
        [self startWikitudeSDKRendering];
        
    } else {
        NSLog(@"device is not supported - reason: %@", [deviceNotSupportedError localizedDescription]);    
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:deviceNotSupportedError.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
        [alert show];
        
    }   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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