//
//  TARTTRequestOptions.m
//  Pods
//
//  Created by Thomas Opiolka on 14.10.15.
//
//

#import "TARTTRequestOptions.h"
#import "TARTTErrors.h"

@interface TARTTRequestOptions()
@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableArray *environment;
@property (nonatomic, strong) NSMutableArray *targetApi;
@property (nonatomic, strong) NSMutableArray *targetType;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, strong) NSString *channelKey;
@end

@implementation TARTTRequestOptions
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.languages = [NSMutableArray new];
        self.environment = [NSMutableArray new];
        self.targetApi = [NSMutableArray new];
        self.targetType = [NSMutableArray new];
        self.state = [NSNumber numberWithInt:1];
        self.channelKey = nil;
    }
    return self;
}

-(void)addLanguage:(NSString *)language{
    [self.languages addObject:language];
}
-(void)addEnvironment:(NSString *)env{
    [self.environment addObject:env];
}
-(void)addTargetApi:(NSNumber *)api{
    [self.targetApi addObject:api];
}
-(void)addTargetType:(NSString *)type{
    [self.targetType addObject:type];
}
-(void)changeState:(NSNumber *)state{
    self.state = state;
}
-(void)changeChannelKey:(NSString *)channelKey{
    self.channelKey = channelKey;
}
-(NSArray *)getLanguage{
    return self.languages;
}
-(NSArray *)getEnvironment{
    return self.environment;
}
-(NSArray *)getTargetApi{
    return self.targetApi;
}
-(NSArray *)getTargetType{
    return self.targetType;
}
-(NSNumber *)getState{
    return self.state;
}
-(NSString *)getChannelKey{
    return self.channelKey;
}
-(BOOL)isValid{
    return ([self.languages count] > 0 &&
       [self.environment count] > 0 &&
       [self.targetApi count] > 0 &&
       [self.targetType count] > 0 &&
            self.state != nil);        
}

@end
