//
//  TARTTChannel.m
//  Pods
//
//  Created by Thomas Opiolka on 06.10.15.
//
//

#import "TARTTChannel.h"
#import "AFNetworking.h"
#import "NSData+MD5.h"
#import "Debug.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>


#define kCHANNELPATH @"TTARTChannelWorkingPath"

@interface TARTTChannel()

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) NSMutableArray *errors;

@property (atomic) long bytesMax;
@property (atomic) long bytesLoaded;
@property (atomic) BOOL canceled;

@property (nonatomic) id<TARTTChannelDelegate> delegate;

@end

@implementation TARTTChannel

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        self.key = key;
    }
    return self;
}

-(void)initChannelWithDelegate:(id<TARTTChannelDelegate>)delegate;
{   
    self.delegate = delegate;
    [self downloadChangedOrMissingFiles];    
}

-(void)saveLastPath:(NSString *)lastPath{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelKey = [NSString stringWithFormat:@"%@-%@",self.key,kCHANNELPATH];
    [defaults setObject:lastPath forKey:channelKey];
    [defaults synchronize];
}
-(void)deleteLastPath:(NSString *)lastPath{
    NSError *error;
   [[NSFileManager defaultManager] removeItemAtPath:lastPath error:&error];
    if(error != nil)
        DebugLog(@"*** Could not delete old files... They might not be existent anymore - %@", error);
}
-(NSString *)getLastPath
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelKey = [NSString stringWithFormat:@"%@-%@",self.key,kCHANNELPATH];
    NSString * filePath = [defaults objectForKey:channelKey];
    if (filePath == nil) {
        filePath = @"/";       
        DebugLog(@"*** No recent Download of Channel could be found", nil);
    }else{
        DebugLog(@"*** Found Channel Path of an older download %@", filePath);
    }
    return filePath;
}    
-(void)downloadChangedOrMissingFiles
{
    for (NSDictionary *item in self.config.files) {
            
        if([self fileHasChangedOrIsMissing:item])
            [self addToQueue:item];
        else if(![self moveToNewLocation:item])
            [self addToQueue:item];
    }
    [self performSelectorInBackground:@selector(handleMissingDownloads) withObject:nil];
}
-(BOOL)fileHasChangedOrIsMissing:(NSDictionary *)item
{
    NSString *lastFilePath = [self.lastPath  stringByAppendingPathComponent:[self getPath:item]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:lastFilePath];    
    if(fileExists){
        NSError* error = nil;  
        NSData *fileD = [NSData dataWithContentsOfFile:lastFilePath options:0 error: &error];
        if (fileD == nil)
        {
            DebugLog(@"Failed to read file, error %@", error);            
        } else
        {
            if ([[fileD MD5] isEqualToString:[item objectForKey:@"md5"]]) {
                DebugLog(@"*** Found matching File with MD5 %@",[fileD MD5]);
                return NO;
            }else{
                DebugLog(@"*** MD5 not matched remote:%@ local:%@", [item objectForKey:@"md5"],[fileD MD5]);
                return NO;
            }
        }
    }   
    return YES;
}
-(void)addToQueue:(NSDictionary *)item
{
    if(self.downloadQueue == nil)
        self.downloadQueue = [NSMutableArray array];
    [self.downloadQueue addObject:item];
    self.bytesMax += [[item objectForKey:@"filesize"] longValue];
}

-(BOOL)moveToNewLocation:(NSDictionary *)item
{
    NSString * relativeFilePath = [self getPath:item];    
    NSString * originalPath = [self.lastPath stringByAppendingPathComponent:relativeFilePath];    
    NSString * movedPath =[self.currentPath stringByAppendingPathComponent:relativeFilePath];      
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    [fileManager createDirectoryAtPath:[self.currentPath stringByAppendingPathComponent:[item objectForKey:@"dirname"]]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
    if (error != nil) {
        DebugLog(@"error creating directory: %@", error);
        return NO;
    }   
    [fileManager moveItemAtPath:originalPath toPath:movedPath error:&error];    
    if(error) {
        DebugLog(@"Error %@",[error localizedDescription]);
        return NO;
    }
    return YES;
}
-(void)handleMissingDownloads
{
    DebugLog(@"*** Start Downloading missing %lu files ", [self.downloadQueue count]);
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:2];  
    
    if([self.downloadQueue count] > 0)
        [self performSelectorOnMainThread:@selector(invokeChannelDownloadStart) withObject:nil waitUntilDone:NO];
    
    self.errors = [NSMutableArray array];
    
    
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSDictionary *item in self.downloadQueue) 
    {     
        NSError * error = nil;
        NSString *directoryPath = [self.currentPath stringByAppendingPathComponent:[item objectForKey:@"dirname"]];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error != nil) {
            DebugLog(@"error creating directory: %@", error);
            continue;
        }        
        
        NSString *filePath = [self.currentPath stringByAppendingPathComponent:[self getPath:item]];   
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[item objectForKey:@"url"]]];                
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];       
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            self.bytesLoaded += bytesRead;            
            if([self.delegate respondsToSelector:@selector(channelProgressLoadedBytes:ofTotal:)]){
                [self performSelectorOnMainThread:@selector(invokeChannelProgress) withObject:nil waitUntilDone:NO];
            }
        }];        
        [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            self.canceled = YES;
            [self.errors addObject:error];
        }];
        [mutableOperations addObject:operation];
    }    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations 
                                                               progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) 
    {
        DebugLog(@"*** Operation %lu of %lu complete", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) 
    {
        DebugLog(@"*** All operations in Batch completed");
        if(self.canceled){
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Download Incomplete" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"TARTT" code:kERROR_FILEDOWNLOAD userInfo:errorDetail];            
            [self performSelectorOnMainThread:@selector(invokeChannelError:) withObject:error  waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(invokeChannelErrors) withObject:nil  waitUntilDone:NO];            
        }else{            
            [self deleteLastPath:self.lastPath];
            [self saveLastPath:self.currentPath];
            [self performSelectorOnMainThread:@selector(invokeChannelFinishedSuccess) withObject:nil waitUntilDone:NO];
            DebugLog(@"*** Saved Current Path");
        }
    }];
    [operationQueue addOperations:operations waitUntilFinished:YES];         
    
}
-(NSString *)getPath:(NSDictionary *)item
{
    return [[item objectForKey:@"dirname"] stringByAppendingPathComponent:[[item objectForKey:@"url"] lastPathComponent]];    
}
-(void)invokeChannelDownloadStart{
    [self.delegate channelStartedDownload];
}
-(void)invokeChannelProgress{
    [self.delegate channelProgressLoadedBytes:self.bytesLoaded ofTotal:self.bytesMax];
}
-(void)invokeChannelFinishedSuccess{
    [self.delegate channelFinishedWithSuccess];
}
-(void)invokeChannelError:(NSError *)error{
    [self.delegate channelFinishedWithError:error];
}
-(void)invokeChannelErrors{
    [self.delegate channelFinishedWithErrors:self.errors];
}

@end
