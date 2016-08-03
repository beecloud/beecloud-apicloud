//
//  BCProtocol.h
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCPay.h"

@interface BeeCloudAdapter : NSObject

+ (BOOL)beeCloudRegisterWeChat:(NSString *)appid;
+ (BOOL)beeCloudIsWXAppInstalled;
+ (BOOL)beeCloud:(NSString *)object handleOpenUrl:(NSURL *)url;

+ (BOOL)beeCloudWXPay:(NSMutableDictionary *)dic;
+ (BOOL)beeCloudAliPay:(NSMutableDictionary *)dic;
+ (BOOL)beeCloudUnionPay:(NSMutableDictionary *)dic;
@end