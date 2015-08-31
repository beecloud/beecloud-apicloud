//
//  BCPayUtil.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPayUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "BCPayCache.h"

@implementation BCPayUtil

+ (AFHTTPRequestOperationManager *)getAFHTTPRequestOperationManager {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = NO;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    return manager;
}

+ (NSMutableDictionary *)getWrappedParametersForGetRequest:(NSDictionary *) parameters {
    NSData *parameterData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *parameterString = [[NSString alloc] initWithBytes:[parameterData bytes] length:[parameterData length]
                                                       encoding:NSUTF8StringEncoding];
    NSMutableDictionary *paramWrapper = [NSMutableDictionary dictionary];
    [paramWrapper setObject:parameterString forKey:@"para"];
    return paramWrapper;
}

+ (NSMutableDictionary *)prepareParametersForPay {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSNumber *timeStamp = [NSNumber numberWithLongLong:[BCPayUtil dateToMillisecond:[NSDate date]]];
    NSString *appSign = [BCPayUtil getAppSignature:[NSString stringWithFormat:@"%@",timeStamp]];
    if(appSign) {
        [parameters setObject:[BCPayCache sharedInstance].appId forKey:@"app_id"];
        [parameters setObject:timeStamp forKey:@"timestamp"];
        [parameters setObject:appSign forKey:@"app_sign"];
        return parameters;
    }
    return nil;
}

+ (NSString *)getAppSignature:(NSString *)timeStamp {
    NSString *appid = [BCPayCache sharedInstance].appId;
    NSString *appsecret = [BCPayCache sharedInstance].appSecret;
    
    if (![BCPayUtil isValidString:appid] || ![BCPayUtil isValidString:appsecret])
        return nil;
    
    NSString *input = [appid stringByAppendingString:timeStamp];
    input = [input stringByAppendingString:appsecret];
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (NSString *)getBestHostWithFormat:(NSString *)format {
    NSString *verHost = [NSString stringWithFormat:@"%@%@",kBCHosts[arc4random()%kBCHostCount],reqApiVersion]; //2015.07.28
    return [NSString stringWithFormat:format, verHost];
}

+ (NSString *)generateRandomUUID {
    return [[NSUUID UUID] UUIDString].lowercaseString;
}

+ (NSDate *)millisecondToDate:(long long)millisecond {
    return [NSDate dateWithTimeIntervalSince1970:((double)millisecond / 1000.0)];
}

+ (NSString *)millisecondToDateString:(long long)millisecond {
    return [BCPayUtil dateToString:[BCPayUtil millisecondToDate:millisecond]];
}

+ (long long)dateToMillisecond:(NSDate *)date {
    if (date == nil) return 0;
    return (long long)([date timeIntervalSince1970] * 1000.0);
}

+ (long long)dateStringToMillisencond:(NSString *)string {
    NSDate *dat = [BCPayUtil stringToDate:string];
    if (dat) return [BCPayUtil dateToMillisecond:dat];
    return 0;
}

+ (NSDate *)stringToDate:(NSString *)string {
    if (string == nil || string.length == 0) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kBCDateFormat];
    return [dateFormatter dateFromString:string];
}

+ (NSString *)dateToString:(NSDate *)date {
    if (date == nil) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kBCDateFormat];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)stringToMD5:(NSString *)string {
    if(string == nil || [string isEqualToString:@""]) return @"";
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr),result );
    NSMutableString *hash =[NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash uppercaseString];
}

+ (BOOL)isValidEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+ (BOOL)isValidMobile:(NSString *)mobile {
    NSString *phoneRegex = @"^([0|86|17951]?(13[0-9])|(15[^4,\\D])|(17[678])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

+ (BOOL)isLetter:(unichar)ch {
    return (BOOL)((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z'));
}

+ (BOOL)isDigit:(unichar)ch {
    return (BOOL)(ch >= '0' && ch <= '9');
}

+ (BOOL)isValidIdentifier:(NSString *)str {
    if (str == nil || str.length == 0) return NO;
    // First letter not a letter.
    if (![BCPayUtil isLetter:[str characterAtIndex:0]]) return NO;
    for (NSUInteger i = 1; i < str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        // Invalid character.
        if (![BCPayUtil isLetter:ch] && ![BCPayUtil isDigit:ch] && ch != '_') return NO;
    }
    // Identifier ending with "__" is reserved.
    if ([str hasSuffix:@"__"]) return NO;
    return YES;
}

+ (BOOL)isValidUUID:(NSString *)uuid {
    if (uuid == nil || uuid.length != 36) return NO;
    for (NSUInteger i = 0; i < uuid.length; i++) {
        unichar ch = [uuid characterAtIndex:i];
        if (i == 8 || i == 13 || i == 18 || i == 23) {
            if (ch != '-')
                return NO;
        } else {
            if (!([BCPayUtil isDigit:ch] || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')))
                return NO;
        }
    }
    return YES;
}

+ (BOOL)isValidTraceNo:(NSString *)str {
    if (![BCPayUtil isValidString:str]) return NO;
    for (NSUInteger i = 0; i < str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        // Invalid character.
        if (![BCPayUtil isLetter:ch] && ![BCPayUtil isDigit:ch]) return NO;
    }
    return YES;
}

+ (BOOL)isValidString:(NSString *)str {
    if (str == nil || (NSNull *)str == [NSNull null] || str.length == 0 ) return NO;
    return YES;
}

+ (BOOL)isPureInt:(NSString *)str {
    NSScanner *scan = [NSScanner scannerWithString:str];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}


+ (BOOL)isPureFloat:(NSString *)str {
    NSScanner *scan = [NSScanner scannerWithString:str];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (NSUInteger)getBytes:(NSString *)str {
    if (![BCPayUtil isValidString:str]) {
        return 0;
    } else {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData* da = [str dataUsingEncoding:enc];
        return [da length];
    }
}

@end

void BCPayLog(NSString *format,...) {
    if ([BCPayCache sharedInstance].willPrintLogMsg) {
        va_list list;
        va_start(list,format);
        NSLogv(format, list);
        va_end(list);
    }
}
