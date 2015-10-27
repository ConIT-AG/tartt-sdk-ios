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

3. **Loading Dummy Architect World**
    
    Wikitude needs a world to start rendering properly. To show the camera even before the world is downloaded we can send a simple dummy world to wikitude like this
    
    ```
    NSURL *architectWorldURL = [NSURL URLWithString:[TARTTHelper getDummyChannelPath]];
    [self.architectView loadArchitectWorldFromURL:architectWorldURL withRequiredFeatures:WTFeature_2DTracking]; 
    ```



## Author

Takondi.com

## License

TARTT is available under the MIT license. See the LICENSE file for more info.



[wikitude-guide-link]: http://www.wikitude.com/external/doc/documentation/latest/ios/setupguideios.html#setup-guide-ios
[wikitude-download-link]: http://www.wikitude.com/download