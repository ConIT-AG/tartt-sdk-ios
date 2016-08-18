//
//  TARTTChannelDownloader.m
//  Pods
//
//
//

#import "TARTTChannelDownloader.h"
#import "Debug.h"
#import "NSData+MD5.h"
#import "AFNetworking.h"
#import "TARTTChannelManager.h"
#import "TARTTHelper.h"
#import "TARTTErrors.h"

@interface TARTTChannelDownloader()

@property (nonatomic) TARTTChannel* channel;
@property (nonatomic) id<TARTTChannelDownloaderDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) NSMutableArray *errors;
@property (nonatomic, strong) NSOperationQueue* operationQueue;

@property (atomic) long bytesMax;
@property (atomic) long bytesLoaded;
@property (atomic) BOOL canceled;
@property (atomic) BOOL downloadError;

@property (nonatomic, strong) NSProgress* downloadProgress;

@end

@implementation TARTTChannelDownloader

-(instancetype)initWithChannel:(TARTTChannel *)channel
{
    self = [super init];
    if (self) {
        self.channel = channel;
        self.downloadQueue = [NSMutableArray new];
        self.errors = [NSMutableArray new];
    }
    return self;    
}
-(void)cancel
{
    self.canceled = YES;
    if(self.operationQueue != nil){
        [self.operationQueue cancelAllOperations];
         DebugLog(@"*** Canceled operations");
    }
}

-(void)startDownloadWithDelegate:(id<TARTTChannelDownloaderDelegate>)delegate
{
    self.delegate = delegate;  
    NSDictionary *content = [self.channel.config objectForKey:@"content"];
    for (NSDictionary *item in [content objectForKey:@"files"]) {
        // look for file in old first
        if([self fileExistsAtPath:self.channel.lastPath forItem:item]){
            [self copyFromPath:self.channel.lastPath forItem:item];           
        }else{
            // look for file in temp 
            if([self fileExistsAtPath:self.channel.tempPath forItem:item]){
                [self copyFromPath:self.channel.tempPath forItem:item];                
            }else{
                // file is missing
                [self addToQueue:item];
            } 
        }
    }    
    if(!self.canceled)
        [self performSelectorInBackground:@selector(handleMissingDownloads) withObject:nil];
    else
        DebugLog(@"*** Download Canceled before handlemissing");
}

-(BOOL)fileExistsAtPath:(NSString *)path forItem:(NSDictionary *)item
{
    NSString *relativeFilePath = [TARTTHelper getRelativePathOfItem:item]; 
    NSString *originalPath = [path stringByAppendingPathComponent:relativeFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:originalPath];    
    if(!fileExists)
        return NO;      
    NSError* error = nil;  
    NSData *fileData = [NSData dataWithContentsOfFile:originalPath options:0 error: &error];
    if (fileData == nil)
    {
        DebugLog(@"Failed to read file, error %@", error);            
    } 
    else
    {
        if ([[fileData MD5] isEqualToString:[item objectForKey:@"md5"]]) 
        {
            DebugLog(@"*** Found matching File with MD5 %@ at %@",[fileData MD5], path);            
            return YES;
        }else{
            DebugLog(@"*** MD5 at Path %@ not matched remote:%@ local:%@",originalPath, [item objectForKey:@"md5"],[fileData MD5]);
            return NO;
        }
    }      
    return NO;
}
-(BOOL)copyFromPath:(NSString *)path forItem:(NSDictionary *)item
{
    NSString *currentPath = self.channel.currentPath;
    NSString *relativeFilePath = [TARTTHelper getRelativePathOfItem:item]; 
    NSString *originalPath = [path stringByAppendingPathComponent:relativeFilePath];
    NSString *destinationPath = [currentPath stringByAppendingPathComponent:relativeFilePath];    
    NSString *basePath = [currentPath stringByAppendingPathComponent:[item objectForKey:@"dirname"]];
    if(![TARTTHelper ensureDirExists:basePath])
    {
        return NO;
    }    
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtPath:originalPath toPath:destinationPath error:&error];    
    if(error) {
        DebugLog(@"Error %@",[error localizedDescription]);
        return NO;
    }
    return YES;
}

-(void)addToQueue:(NSDictionary *)item
{
    [self.downloadQueue addObject:item];
    self.bytesMax += [[item objectForKey:@"filesize"] longValue];
}
-(void)handleMissingDownloads
{
    DebugLog(@"*** Start Downloading missing %lu files ", [self.downloadQueue count]);   
    if([self.downloadQueue count] > 0)
        [self performSelectorOnMainThread:@selector(invokeChannelDownloadStart) withObject:nil waitUntilDone:NO];
    
    self.errors = [NSMutableArray array];   
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];    
    
    dispatch_group_t downloadGroup = dispatch_group_create();
    self.downloadProgress = [NSProgress progressWithTotalUnitCount:[self.downloadQueue count]];
    for (NSDictionary *item in self.downloadQueue) 
    {    

        NSString *directoryPath = [self.channel.tempPath stringByAppendingPathComponent:[item objectForKey:@"dirname"]];        
        if(![TARTTHelper ensureDirExists:directoryPath]){
            continue;
        }        
        NSString *filePath = [self.channel.tempPath stringByAppendingPathComponent:[TARTTHelper getRelativePathOfItem:item]];  
        NSString *url = [item objectForKey:@"url"];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        configuration.URLCache = nil;
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];        
         
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];        
        
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull childProgress) {            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update the progress view
              
                //self.bytesLoaded += downloadProgress.completedUnitCount;            
                if([self.delegate respondsToSelector:@selector(channelDownloadProgress:ofTotal:)]){
                    [self performSelectorOnMainThread:@selector(invokeChannelProgress) withObject:nil waitUntilDone:NO];
                }
                //[_myProgressView setProgress:downloadProgress.fractionCompleted];                
            });
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {  
            return [NSURL fileURLWithPath:filePath];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {      
            if(error != nil){
                NSLog(@"Error: %@", error);
                self.downloadError = YES;
                [self.errors addObject:error];
            }
            dispatch_group_leave(downloadGroup);            
        }];
        NSProgress *childProgress = [manager downloadProgressForTask:downloadTask];
        [self.downloadProgress addChild:childProgress withPendingUnitCount:1];
        
        
        dispatch_group_enter(downloadGroup);
        [downloadTask resume];        
    } 
    
    dispatch_group_wait(downloadGroup, DISPATCH_TIME_FOREVER);
    if(self.canceled){
        DebugLog(@"*** Download Canceled after batch complete");
        return;
    }
    DebugLog(@"*** All operations in Batch completed");
    if(self.downloadError)
    {   
        [self performSelectorOnMainThread:@selector(invokeChannelError:) 
                               withObject:[NSError errorWithDomain:TARTTErrorDomain
                                                              code:TARTTErrorDownloadIncomplete
                                                          userInfo:@{NSLocalizedDescriptionKey: @"Download Incomplete"}] 
                            waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(invokeChannelErrors) withObject:nil  waitUntilDone:NO];            
    }else
    {          
        [self moveDownloadedFilesToCurrent];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
-(void)moveDownloadedFilesToCurrent{
    
    for (NSDictionary *item in self.downloadQueue) 
    {        
        [self copyFromPath:self.channel.tempPath forItem:item]; 
    }   
    DebugLog(@"*** Saved New Path as Current Path %@", self.channel.currentPath);           
    [[TARTTChannelManager defaultManager] saveLastPath:self.channel.currentPath forChannel:[self.channel.config objectForKey:@"channelKey"]];                      
    [self performSelectorOnMainThread:@selector(invokeChannelFinishedSuccess) withObject:nil waitUntilDone:NO];         
}
-(void)invokeChannelDownloadStart{
    [self.delegate channelDownloadStarted];
}
-(void)invokeChannelProgress{
    [self.delegate channelDownloadProgress:self.downloadProgress.completedUnitCount ofTotal:[self.downloadQueue count]];
}
-(void)invokeChannelFinishedSuccess{
    [self.delegate channelDownloadFinishedWithSuccess:self.channel];
}
-(void)invokeChannelError:(NSError *)error{
    [self.delegate channelDownloadFinishedForChannel:self.channel withError:error];
}
-(void)invokeChannelErrors{
    if([self.delegate respondsToSelector:@selector(channelDownloadFinishedForChannel:withErrors:)])
        [self.delegate channelDownloadFinishedForChannel:self.channel withErrors:self.errors];
}

@end