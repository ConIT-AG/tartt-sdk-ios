
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
 
@implementation NSData(MD5)
 
- (NSString*)MD5
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    CC_MD5(self.bytes, (int)self.length, md5Buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){ 
		[result appendFormat:@"%02x",md5Buffer[i]];
    }
    return result;
} 
@end
