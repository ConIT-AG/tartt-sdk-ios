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
@property (nonatomic, strong) NSString *table;
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
        [self changeState:TARTTStateActive];
        self.channelKey = nil;
        self.table = @"world";
    }
    return self;
}

-(void)addLanguage:(NSString *)language{
    [self.languages addObject:[language lowercaseString]];
}
-(void)addEnvironment:(TARTTEnvironment)env{
    NSDictionary *envs = @{
     @(TARTTEnvironmentTest) : @"test",
     @(TARTTEnvironmentProduction) : @"production",
    };
    [self.environment addObject:[envs objectForKey:@(env)]];
}
-(void)addTargetApi:(NSNumber *)api{
    [self.targetApi addObject:api];
}
-(void)addTargetType:(TARTTTargetType)type{
    NSDictionary *targetType = @{
      @(TARTTTargetTypeMainAndDetail) : @"mainanddetail",
      @(TARTTTargetTypeMain) : @"main",
    };
    [self.targetType addObject:[targetType objectForKey:@(type)]];
}
-(void)changeState:(TARTTStateType)state{
    self.state = [NSNumber numberWithInteger:state];
}
-(void)changeChannelKey:(NSString *)channelKey{
    self.channelKey = channelKey;
}
-(void)changeTable:(NSString *)table{
    self.table = table;
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
-(NSString *)getTable{
    return self.table;
}
-(BOOL)isValid{
    return ([self.languages count] > 0 &&
       [self.environment count] > 0 &&
       [self.targetApi count] > 0 &&
       [self.targetType count] > 0 &&
            self.state != nil);        
}

@end
