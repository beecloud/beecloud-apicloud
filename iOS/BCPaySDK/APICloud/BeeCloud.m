//
//  BCPay.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/8/11.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BeeCloud.h"
#import "BCPay.h"
#import "BCPayConstant.h"
#import "BCPayUtil.h"
#import "UZAppDelegate.h"
#import "UZAppUtils.h"
#import "NSDictionaryUtils.h"

#import "JSON.h"

@interface BeeCloud ()<UIApplicationDelegate, BCApiDelegate> {
    NSInteger _cbId;
}

@end

@implementation BeeCloud

- (void)pay:(NSDictionary *)paramDic {
    NSLog(@"do pay");
    _cbId = [paramDic integerValueForKey:@"cbId" defaultValue:-1];
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = [BCPay getChannelType:[paramDic stringValueForKey:@"channel" defaultValue:@""]];
    payReq.title = [paramDic stringValueForKey:@"title" defaultValue:@""];
    payReq.totalfee = [NSString stringWithFormat:@"%ld",(long)[paramDic integerValueForKey:@"totalfee" defaultValue:0]];
    payReq.billno = [paramDic stringValueForKey:@"billno" defaultValue:@""];
    payReq.scheme = [[theApp getFeatureByName:kKeyMoudleName] stringValueForKey:kKeyUrlScheme defaultValue:nil];
    payReq.viewController = self.viewController;
    payReq.optional = [paramDic dictValueForKey:@"optional" defaultValue:nil];
    [BCPay sendBCReq:payReq];
}

- (void)getApiVersion:(NSDictionary *)paramDic {
    _cbId = [paramDic integerValueForKey:@"cbId" defaultValue:-1];
    [self sendResultEventWithCallbackId:_cbId dataDict:@{@"apiVersion":kApiVersion} errDict:nil doDelete:YES];
}

- (NSString *)genOutTradeNo {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)onBCPayResp:(id)resp {
    if (_cbId >= 0) {
        [self sendResultEventWithCallbackId:_cbId dataDict:(NSDictionary *)resp errDict:nil doDelete:YES];
    }
}

- (id)initWithUZWebView:(UZWebView *)webView_ {
    if (self = [super initWithUZWebView:webView_]) {
        [theApp addAppHandle:self];
        [BCPay setBCApiDelegate:self];
    }
    return self;
}

- (void)dispose {
    [theApp removeAppHandle:self];
}

+ (void)launch {
    NSLog(@"launch");

    NSDictionary *feature = [theApp getFeatureByName:kKeyMoudleName];
    NSString *bcAppid = [feature stringValueForKey:kKeyBCAppID defaultValue:nil];
    NSString *wxAppid = [feature stringValueForKey:kKeyUrlScheme defaultValue:nil];
    
    if (bcAppid.isValid) {
        [BCPay initWithAppID:bcAppid andAppSecret:@""];
    }
    if (wxAppid.isValid) {
        [BCPay initWeChatPay:wxAppid];
    }
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
     return [BCPay handleOpenUrl:url];
}

@end
