//
//  TARTTChannelDownloader.m
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import "TARTTChannelDownloader.h"
#import "Debug.h"
#import "NSData+MD5.h"
#import "AFNetworking.h"
#import "TARTTChannelManager.h"
#import "TARTTHelper.h"

@interface TARTTChannelDownloader()

@property (nonatomic) TARTTChannel* channel;
@property (nonatomic) id<TARTTChannelDownloaderDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) NSMutableArray *errors;

@property (atomic) long bytesMax;
@property (atomic) long bytesLoaded;
@property (atomic) BOOL canceled;

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

-(void)startDownloadWithDelegate:(id<TARTTChannelDownloaderDelegate>)delegate
{
    self.delegate = delegate;
    for (NSDictionary *item in self.channel.config.files) {
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
    [self performSelectorInBackground:@selector(handleMissingDownloads) withObject:nil];
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
            DebugLog(@"*** MD5 at Path %@ not matched remote:%@ local:%@",path, [item objectForKey:@"md5"],[fileData MD5]);
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
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSDictionary *item in self.downloadQueue) 
    {    

        NSString *directoryPath = [self.channel.tempPath stringByAppendingPathComponent:[item objectForKey:@"dirname"]];        
        if(![TARTTHelper ensureDirExists:directoryPath]){
            continue;
        }        
        NSString *filePath = [self.channel.tempPath stringByAppendingPathComponent:[TARTTHelper getRelativePathOfItem:item]];  
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[item objectForKey:@"url"]]];                
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];       
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            self.bytesLoaded += bytesRead;            
            if([self.delegate respondsToSelector:@selector(channelDownloadProgress:ofTotal:)]){
                [self performSelectorOnMainThread:@selector(invokeChannelProgress) withObject:nil waitUntilDone:NO];
            }
        }];        
        [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            self.canceled = YES;
            [self.errors addObject:error];
        }];
        [mutableOperations addObject:operation];
    } 
    [self startOperation:mutableOperations]; 
}

-(void)startOperation:(NSArray *)requests
{
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requests 
                                                               progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) 
   {
       //DebugLog(@"*** Operation %lu of %lu complete", numberOfFinishedOperations, totalNumberOfOperations);       
   } 
   completionBlock:^(NSArray *operations) 
   {
       DebugLog(@"*** All operations in Batch completed");
       if(self.canceled){
           NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
           [errorDetail setValue:@"Download Incomplete" forKey:NSLocalizedDescriptionKey];
           NSError *error = [NSError errorWithDomain:@"TARTT" code:kERROR_FILEDOWNLOAD userInfo:errorDetail];            
           [self performSelectorOnMainThread:@selector(invokeChannelError:) withObject:error  waitUntilDone:NO];
           [self performSelectorOnMainThread:@selector(invokeChannelErrors) withObject:nil  waitUntilDone:NO];            
       }else
       {          
           [self moveDownloadedFilesToCurrent];
       }
   }];
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1]; 
    [operationQueue addOperations:operations waitUntilFinished:YES];  
}
-(void)moveDownloadedFilesToCurrent{
    
    for (NSDictionary *item in self.downloadQueue) 
    {        
        [self copyFromPath:self.channel.tempPath forItem:item]; 
    }   
    DebugLog(@"*** Saved New Path as Current Path %@", self.channel.currentPath);           
    [TARTTHelper saveLastPath:self.channel.currentPath forChannel:self.channel.config.key];                      
    [self performSelectorOnMainThread:@selector(invokeChannelFinishedSuccess) withObject:nil waitUntilDone:NO];         
}
-(void)invokeChannelDownloadStart{
    [self.delegate channelDownloadStarted];
}
-(void)invokeChannelProgress{
    [self.delegate channelDownloadProgress:self.bytesLoaded ofTotal:self.bytesMax];
}
-(void)invokeChannelFinishedSuccess{
    [self.delegate channelDownloadFinishedWithSuccess:self.channel];
}
-(void)invokeChannelError:(NSError *)error{
    [self.delegate channelDownloadFinishedForChannel:self.channel withError:error];
}
-(void)invokeChannelErrors{
    [self.delegate channelDownloadFinishedForChannel:self.channel withErrors:self.errors];
}

@end