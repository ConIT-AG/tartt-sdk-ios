# TARTT

TARTT removes the need of integrating AR-worlds directly into your XCode Project when Working with Wikitude.

## Components
![alt tag](https://raw.githubusercontent.com/takondi/tartt-sdk-ios/master/SDK_overview.png)    
* **Wikitude SDK**: [AR SDK][wikitude-link]
* **TARTT SDK**: Dynamic AR World Download System
* **Parse**: Cloud Database for channel settings
* **S3**: Cloud Storage for channel files

In the App a `TARTTConfigRequest` is started to receive channel informations from `PARSE`. The `TARTTChannelDownload` needs this information to download the available files from the S3 Cloud Storage.
The downloaded files will then be stored in a local cache directory.

After that a AR Experience with Wikitude SDK can be started with these files.

The example application shows all the components working together. Most of the implementation happens in `DefaultViewController` and `MainTableViewController`. These two files are a good starting point.

## Sequence Diagrams
One available channel | Mutliple available channels | Communication
--------------------- | --------------------------- | ---------------
![alt tag](https://raw.githubusercontent.com/takondi/tartt-sdk-ios/master/sequence_one_channel.png)|![alt tag](https://raw.githubusercontent.com/takondi/tartt-sdk-ios/master/sequence_multiple_channels.png)|![alt tag](https://raw.githubusercontent.com/takondi/tartt-sdk-ios/master/sequence_communication.png)

## Example Application

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Then download the Wikitude Javascript API SDK from `http://www.wikitude.com/download` and add the framwork into to the example directory.

Have a look at the following files for a better understanding:
    `DefaultViewController` main implementation
    `MainTableViewController` different parse options
    `DefaultViewController+PluginLoading` + `BarcodePlugin.cpp` for Plugin usage

## Installation 

1. **CocoaPods**

    Add the following line to your podfile:

        pod 'TARTT' ,:git => 'https://github.com/takondi/tartt-sdk-ios.git'  

    Run pod install, and you should now have the latest parse release.

2. **Wikitude SDK**
    
    Download the Wikitude SDK - JavaScript API (not Native API!) for iOS from [Wikitude SDK][wikitude-download-link]. Please make sure to use Version 5.0 of the Wikitude SDK.

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
        [options addEnvType:TARTTEnvTypeProduction];
        [options addTargetApi:[NSNumber numberWithInt:3]];
        [options addTargetType:TARTTTargetTypeMainAndDetail];

    These are the following options in detail:
    * **language**: is the two-letter language of the AR-World. If you only have AR-Channels with AR-Worlds in one language (i.e. *de*), then you should also only use this language de for the requests - no matter what the device language is. If you have AR-Channels that have AR-Worlds in several languages, you can use the device language to decide which language version of the AR-World to request
    * **envType**: is the environment type and can be *TARTTEnvTypeTest* or *TARTTEnvTypeProduction*. This means that one time you request the AR-World that was created for testing purpose and the other time you request the production AR-World. In genereal you would review the production AR-World only in the production version of your app.
    * **targetType**: is the target image types and can be *TARTTTargetTypeMainAndDetail* or *TARTTTargetTypeMain*. This means that in the first case you would request to have main and detail target images of a page and in the second case you would get only main target images. Main and detail target images would mean better image recognition quality but also more performance needed from the device.
    * **targetApi**: is the API that was used for creating the target images. Each version of the Wikitude SDK only works with certain target API versions. In case of Wikitude SDK 5.0, please use the version 3

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
    
    While TARTT is downloading there a several delegation methods to show a loading indicator and a progress bar
    
    * `channelDownloadStarted` only fires if there is at least one file to download
    * `channelDownloadProgress:(long)bytesLoaded ofTotal:(long)bytesTotal` for progress information
    * `channelDownloadFinishedWithSuccess:(TARTTChannel *)channel` will trigger when the world download has completed

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
    
11. **Receiving communication requests from the AR-World**
    
    Wikitude informs you about pages that have been found in the camarea or if the page lost its focus. 
    You can reflect this to the GUI by showing appropriate message like 'Please scan page'. Hide this hint again as soon as a page is found. You might also get custom requests from the world if your app supports them (like 'Add a product to basket' or 'Open products detail page').

        if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnEnterFieldOfVision"])
        {
            // we entered a page. So hide any overlay 
        }
        else if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnExitFieldOfVision"])
        {
            // we lost focus of a page. So show an overlay with a hint for the user 
        }

12. **Sending a communication request to the AR-World**

    Sometimes you might want to communicate with the AR-World. This is the case with responding with 'startExperience' to the AR-World request 'readyForExperience'. But you might also want to send additional requests to the AR-World like providing product information data when the AR-World has requested them before. You can make a call to a AR-World Javascript Method lie that: 
    
        NSDictionary *worldConfig = @{ @"Example Key1": @"Example Val1" };
        NSString *json = [TARTTHelper convertToJson:worldConfig];
        NSString *javascript = [NSString stringWithFormat:@"startExperience('%@');",json];
        [self.architectView callJavaScript:javascript];

## QR-Code Scanner Integration

1. **Plugin integration**
    Follow the Wikitude Plugin Guide on [Barcode and QR Code Reader][wikitude-guide-qr] and have a look at their example application which has copyable files

2. **Start/Stop the Scanner**
    Import the category files with the plugin logic into your Viewcontroller

        #import "MyViewController+PluginLoading.h"
    Start and stop the plugin now with these lines where you need them

        [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
        [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    Keep in mind that a plugin like this will use up a lot of your system resources and should not be running while your AR-World is activly on a page. You can accomplish this like so:

        if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnEnterFieldOfVision"])
        {        
            [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
        }
        else if ( [[URL absoluteString] hasPrefix:@"architectsdk://augmentationsOnExitFieldOfVision"])
        {
            [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
        }
    
3. **QR-Code Triggers**
    If the scanner scans a QR-Code the world will trigger an event which you can react to as follows
        if([[URL absoluteString] hasPrefix:@"architectsdk://qrCodeTrigger"])
        {       
            // parse the url
            NSDictionary *parameters = [TARTTHelper URLParameterFromURL:URL];
            // parameter code holds the content url encoded
            NSString *code = [parameters objectForKey:@"code"];
            // decode for your final qr code content
            NSString *contentOfQRCode = [code stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // dont forget to stop the scanner or the event will be triggered very often
            [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin]; 
        }

## TARTT Mutliple Channels available
if your options for the `TARTTConfigRequest` result in multiple channels the use has to decide which channel he wants to select.
This can be accomplished by following the next steps

1. **Config Request delegation**
    In this case the config request will trigger the `finishedConfigRequestWithMultipleChannels` delegate instead of `finishedConfigRequestWithSuccess`

        -(void)finishedConfigRequestWithMultipleChannels
        {        
            [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
            // show the user a hint that he has to scan a QR-Code now
        }
2. **Setting up a Code**
    To work with TARTT the used QR-Code code should look like this where `%%key%%` is the channel identifier

        tartt://channelCode?channelKey=%%key%%
    You can use this code also to overwrite other options for the `Parse` call

        tartt://channelCode?channelKey=%%key%%&language=de&targetType=mainanddetail&envType=test&targetApi=3

3. **QR-Code-Channel Trigger**
    In the following code you see an example of using this code to overwrite options and trigger a channel download
    
        if([[URL absoluteString] hasPrefix:@"architectsdk://qrCodeTrigger"])
        {          
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
                [self.options addLanguage:language];
            }
            if(targetType != nil){
                [self.options forceTargetType:targetType];
            }
            if(envType != nil){
                [self.options forceEnvType:envType];
            }
            if(state != nil){   
                [self.options forceState:[NSNumber numberWithInteger:[state integerValue]]];
            }
            if(targetApi != nil){
                [self.options addTargetApi:[NSNumber numberWithInteger:[targetApi integerValue]]];
            }

            if([channelKey isEqualToString:self.channel.config.channelKey])
            {
                NSLog(@"Ignoring QR-Code because its already loaded or still loading");
                return;
            }                

            [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin];        
            [self.configRequest selectChannel:channelKey andDelegate:self];
        }



## FAQ

We will answer frequently asked questions here.

## License

TARTT SDK for iOS is available under the MIT license. See the LICENSE file for more info.


[wikitude-guide-qr]: http://www.wikitude.com/external/doc/documentation/latest/ios/pluginsapi.html#barcode
[wikitude-guide-link]: http://www.wikitude.com/external/doc/documentation/latest/ios/setupguideios.html#setup-guide-ios
[wikitude-download-link]: http://www.wikitude.com/download
[wikitude-link]: http://www.wikitude.com
