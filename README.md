# TARTT


## Exmaple Application

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Then download the Wikitude Javascript API SDK from `http://www.wikitude.com/download` and add the framwork into to the example directory.


## Installation 

1. **CocoaPods**

    Add the following line to your podfile:

        pod 'TARTT' ,:git => 'https://github.com/takondi/tartt-sdk-ios.git'  

    Run pod install, and you should now have the latest parse release.

2. **Wikitude SDK**
    
    Download the Wikitude Javascript API SDK for iOS from [Wikitude SDK][wikitude-download-link]

    Follow the Wikitude Installation Guide on [Wikitude Installation Guide][wikitude-guide-link] except for the paragraph 'LOADING AN ARCHITECT WORLD'

3. **Import TARTT**
    
    Add the following line to your viewcontroller
    
        #import <TARTT/TARTT.h>

4. **Loading Dummy Architect World**
    
    Wikitude needs a world to start rendering properly. To show the camera even before the world is downloaded we use a simple dummy world like this
    

        NSURL *architectWorldURL = [NSURL URLWithString:[TARTTHelper getDummyChannelPath]];
        [architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking]; 


5. **Prepare Request Options**
    To get the right channel information TARTT will connect to parse.com and retrieve the needed information. 
        
        TARTTRequestOptions *options = [TARTTRequestOptions new];
        [options addLanguage:@"de"];
        [options addEnvironment:TARTTEnvironmentProduction];
        [options addTargetApi:[NSNumber numberWithInt:3]];
        [options addTargetType:TARTTTargetTypeMainAndDetail];

6. **Start Config Request**
    
    To get the available Channel information we use the following lines. Make sure your viewcontroller implementes the `TARTTChannelConfigRequestDelegate` protocol.

        TARTTChannelConfigRequest *configRequest = [[TARTTChannelConfigRequest alloc] initWithApplicationID:@"*** PARSE APPLICATION KEY ***" andClientKey:@"***PARSE CLIENT KEY ***" andOptions:options];
        [configRequest startRequestWithDelegate:self];

7. **Request Finished**
    
    The delegation method `finishedConfigRequestWithSuccess` delivers a `TARTTConfig` object which is needed to start the download of the actual needed files

        -(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config
        {   
            NSError *error;
            // prepares all folders and old version that might have been downloaded before
            TARTTChannel *channel = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:config error:&error];   
            TARTTChannelDownloader *downloader = [[TARTTChannelDownloader alloc] initWithChannel:self.channel];
            [downloader startDownloadWithDelegate:self];
        }

8. **Download Events**
    
    While TARTT is downloading there a several delegation methods to show loading and a progress
    
    * `channelDownloadStarted` only fires if there is really something to download
    * `channelDownloadProgress:(long)bytesLoaded ofTotal:(long)bytesTotal` for progress information
    * `channelDownloadFinishedWithSuccess:(TARTTChannel *)channel` as soon as the world is downloaded completly

9. **Download Finished**
    
    When the download is finished you are ready to let wikitude know about it and start the AR-World

        -(void)channelDownloadFinishedWithSuccess:(TARTTChannel *)channel
        {    
            NSError *error;
            [[TARTTChannelManager defaultManager] cleanUpChannel:channel error:&error];   
            // Path to Channel Data
            NSURL *architectWorldURL = [NSURL URLWithString:[channel.currentPath stringByAppendingPathComponent:@"index.html"]];
            // Load Channel
            self.architectWorldNavigation =  [self.architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking];     
        }

10. **Initialising the World**
    
    Wikitude lets you know about events from within the world over the `-(void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL` method.
    In here you have to listen to 'readyForExecution' and then start the experience manually by sending a javascript snippet back to wikitude like so:

        if( [[URL absoluteString] hasPrefix:@"architectsdk://readyForExecution"])
        {            
            NSDictionary *worldConfig = @{ @"Example Key1": @"Example Val1" };
            NSString *json = [TARTTHelper convertToJson:worldConfig];
            NSString *javascript = [NSString stringWithFormat:@"startExperience('%@');",json];
            [self.architectView callJavaScript:javascript];
        }
    
    After the targets in the world are loaded you get the `targetsLoaded` event in the same method as above.
    Now you are all set and should hide any loading indicators and progress bars.

        if ( [[URL absoluteString] hasPrefix:@"architectsdk://targetsLoaded"] )
        {
            // Now Loading is completed and that should be refelcted in your GUI
        }
    
11. **Communicating with the World**
    
    Wikitude informs you about pages that have been found in the camarea or if the page lost its focus. 
    You can reflect this to the GUI by showing appropriate message like 'Please scan page'. Hide this hint again as soon as a page is found.

        if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnEnterFieldOfVision"])
        {
            // we entered a page. So hide any overlay 
        }
        else if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnExitFieldOfVision"])
        {
            // we lost focus of a page. So show an overlay with a hint for the user 
        }

## License

TARTT is available under the MIT license. See the LICENSE file for more info.



[wikitude-guide-link]: http://www.wikitude.com/external/doc/documentation/latest/ios/setupguideios.html#setup-guide-ios
[wikitude-download-link]: http://www.wikitude.com/download