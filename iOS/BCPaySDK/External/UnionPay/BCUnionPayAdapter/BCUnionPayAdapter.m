//
//  BCUnionPayAdapter.m
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCUnionPayAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import "UPPayPlugin.h"

@interface BCUnionPayAdapter ()<BeeCloudAdapterDelegate, UPPayPluginDelegate>

@end


@implementation BCUnionPayAdapter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCUnionPayAdapter *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCUnionPayAdapter alloc] init];
    });
    return instance;
}

- (BOOL)unionPay:(NSMutableDictionary *)dic {
    NSString *tn = [dic stringValueForKey:@"tn" defaultValue:@""];
    if (tn.isValid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UPPayPlugin startPay:tn mode:@"00" viewController:dic[@"viewController"] delegate:[BCUnionPayAdapter sharedInstance]];
        });
        return YES;
    }
    return NO;
}

#pragma mark - Implementation UnionPayDelegate

- (void)UPPayPluginResult:(NSString *)result {
    int errcode = BCErrCodeFail;
    NSString *strMsg = @"支付失败";
    if ([result isEqualToString:@"success"]) {
        errcode = BCSuccess;
        strMsg = @"支付成功";
    } else if ([result isEqualToString:@"cancel"]) {
        errcode = BCErrCodeUserCancel;
        strMsg = @"支付取消";
    }
    
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithCapacity:10];
    dic[kKeyResponseResultCode] = @(errcode);
    dic[kKeyResponseResultMsg] = strMsg;
    dic[kKeyResponseErrDetail] = strMsg;
    
    if ([BCPay getBeeCloudDelegate] && [[BCPay getBeeCloudDelegate] respondsToSelector:@selector(onBeeCloudResp:)]) {
        [[BCPay getBeeCloudDelegate] onBeeCloudResp:dic];
    }
}

@end
