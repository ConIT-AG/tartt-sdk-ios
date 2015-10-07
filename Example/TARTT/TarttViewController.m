//
//  TarttViewController.m
//  TARTT
//
//  Created by wh33ler on 10/05/2015.
//  Copyright (c) 2015 wh33ler. All rights reserved.
//

#import "TarttViewController.h"



@interface TarttViewController ()
@property (nonatomic, strong) WTArchitectView *architectView;    
@property (nonatomic, weak) WTNavigation *architectWorldNavigation;
@property (nonatomic, strong) TARTTChannel *channel;    
@end

@implementation TarttViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.progressBar.hidden = YES;    
    
    NSError *deviceNotSupportedError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_Geo | WTFeature_2DTracking error:&deviceNotSupportedError] ) { // 1
        self.architectView = [[WTArchitectView alloc] initWithFrame:self.view.bounds motionManager:nil];
        self.architectView.delegate = self;
        [self.architectView setLicenseKey:@"otr/l3HJpaElIt8Bv36DNdxrVvywnXxhvMsMFReyvrL2Jlr54vetxIAYOi9V3PUgT7S9RaK0NC3fq+1Pkt+Twy6SjmQme9ginF30aixB+yDZLabipN3K421a3IzxP7f68pI76j+EbTz/B+O6fc1KKHJl8/CERXUScIEKhcp9XHBTYWx0ZWRfX0nZMIeLg6TgFJ4TrRDHDsuicw/ev3ghNBuwGKzJ1q29WCcOTv0dyKVFZDR2gE9lVULtncj3sckaZBayY6rbfO8oZMn1r/5lNFZjF1NjvuJlvp5q8GOS0siRRYs8tGzoAfR7X2xwNocrkmPMACMIsxWBYwn9IAa3vYCo+yRYeFprS9JAo6rkTdGmjB+tphyzmqr3vK8O/PBuWwhEecwNlkm1UFstX5ZEqd1QLbayWfCF8d33RuH5+LU4yDqead0z+9vhQ77nPGDrLJvO/k8ciIjUXl0Fc1tGlhL089fQ7Fwdl5hX1PTame58LpNrWtaPEtnYlZPdVbJNWTwEFXYc29NVZsNoTsNQ4tmKn4U8X2c4ml7FnzCiJpq2hHAMwLry57InRuyRTZbAIsvrOzUD8akU4vLti6igFUG1AK5/ivdcgObcOGxSEoWdMF/9AALI2A0LVJWKzK0k7etjtJ28vcpKJ2JyTFuEalzJYz63zJSUSmktW1R9/1vnSLTuymzFS5GRIC0EuJL3ct7B4YJOGu+0i3GmrNQ32BQmK3Wdk3uj3U2Xi+5iDXU="];       
        
        [self.view addSubview:self.architectView];
        self.architectView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_architectView);
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[_architectView]|" options:0 metrics:nil views:views] ];
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_architectView]|" options:0 metrics:nil views:views] ];
        
    } else {
        NSLog(@"device is not supported - reason: %@", [deviceNotSupportedError localizedDescription]);
    }}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startChannel:(id)sender {
    
    self.channel = [[TARTTChannel alloc] initWithKey:@"SampleKey" andDelegate:self];
    [self.channel startDownloadIfNeeded];
}

#pragma mark TARTT
-(void)channelStartedDownload
{
    self.progressBar.hidden = NO;
    self.progressBar.progress = 0;
}
-(void)channelProgressLoadedBytes:(long)bytesLoaded ofTotal:(long)bytesTotal
{    
    self.progressBar.progress = (float)bytesLoaded/(float)bytesTotal;   
}
-(void)channelFinishedWithSuccess
{
    self.progressBar.hidden = YES;
}
-(void)channelFinishedWithError:(NSError *)error
{
    self.progressBar.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];    
    [alert show];
}
-(void)channelFinishedWithErrors:(NSArray *)errors{
    for (NSError *error  in errors) {
        NSLog(@"Error: %@",error);
    }
}


#pragma mark WTArchitectViewDelegate
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation {
    /* Architect World did finish loading */
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
@end
