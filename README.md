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

7. **Start Downloading Channel Files**
    
    The delegation method `finishedConfigRequestWithSuccess` delivers a `TARTTConfig` object which is needed to start the download of the actual needed files

        -(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config
        {   
            NSError *error;
            // prepares all folders and old version that might have been downloaded before
            TARTTChannel *channel = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:config error:&error];   
            TARTTChannelDownloader *downloader = [[TARTTChannelDownloader alloc] initWithChannel:self.channel];
            [downloader startDownloadWithDelegate:self];
        }



## Author

Takondi.com

## License

TARTT is available under the MIT license. See the LICENSE file for more info.



[wikitude-guide-link]: http://www.wikitude.com/external/doc/documentation/latest/ios/setupguideios.html#setup-guide-ios
[wikitude-download-link]: http://www.wikitude.com/download