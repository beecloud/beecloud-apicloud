 //
//  BCPay.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPay.h"

#import "BCPayUtil.h"
#import "BeeCloudAdapter.h"
#import "PaySandBoxViewController.h"


@interface BCPay ()

@property (nonatomic, weak) id<BeeCloudDelegate> deleagte;

@end

@implementation BCPay

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCPay *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCPay alloc] init];
    });
    return instance;
}

+ (void)initWithAppID:(NSString *)appId {
    BCPayCache *instance = [BCPayCache sharedInstance];
    instance.appId = appId;
    [BCPay sharedInstance];
}

+ (BOOL)initWeChatPay:(NSString *)wxAppID {
    return [BeeCloudAdapter beeCloudRegisterWeChat:wxAppID];
}

+ (void)setBeeCloudDelegate:(id<BeeCloudDelegate>)delegate {
    [BCPay sharedInstance].deleagte = delegate;
}

+ (id<BeeCloudDelegate>)getBeeCloudDelegate {
    return [BCPay sharedInstance].deleagte;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    if (BCPayUrlWeChat == [BCPayUtil getUrlType:url]) {
        return [BeeCloudAdapter beeCloud:kAdapterWXPay handleOpenUrl:url];
    } else if (BCPayUrlAlipay == [BCPayUtil getUrlType:url]) {
        return [BeeCloudAdapter beeCloud:kAdapterAliPay handleOpenUrl:url];
    } else if (BCPayUrlUnionPay == [BCPayUtil getUrlType:url]) {
        return [BeeCloudAdapter beeCloud:kAdapterUnionPay handleOpenUrl:url];
    }

    return NO;
}

+ (BOOL)isWXAppInstalled {
    return [BeeCloudAdapter beeCloudIsWXAppInstalled];
}

+ (NSString *)getBCApiVersion {
    return kApiVersion;
}

+ (void)setWillPrintLog:(BOOL)flag {
    [BCPayCache sharedInstance].willPrintLogMsg = flag;
}

+ (void)setNetworkTimeout:(NSTimeInterval)time {
    [BCPayCache sharedInstance].networkTimeout = time;
}

+ (void)sendBCReq:(BCBaseReq *)req {

    switch (req.type) {
        case BCObjsTypePayReq:
            [(BCPayReq *)req payReq];
            break;
        default:
            break;
    }
}

+ (void)doErrorResponse:(NSString *)resultMsg errDetail:(NSString *)errMsg {
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithCapacity:10];
    dic[kKeyResponseResultCode] = @(BCErrCodeCommon);
    dic[kKeyResponseResultMsg] = resultMsg;
    dic[kKeyResponseErrDetail] = errMsg;
    
    if ([BCPay getBeeCloudDelegate] && [[BCPay getBeeCloudDelegate] respondsToSelector:@selector(onBeeCloudResp:)]) {
        [[BCPay getBeeCloudDelegate] onBeeCloudResp:dic];
    }
}

//#pragma mark private class functions
//
//#pragma mark Pay Request
//
//- (void)reqPay:(BCPayReq *)req {
//    if (![self checkParameters:req]) return;
//    
//    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
//    if (parameters == nil) {
//        [BCPay doErrorResponse:kKeyCheckParamsFail errDetail:@"请检查是否全局初始化"];
//        return;
//    }
//    
//    if ([req.channel isEqualToString:PayChannelBaiduApp]) {
//        req.channel = PayChannelBaiduWap;
//    }
//    parameters[@"channel"] = req.channel;
//    parameters[@"total_fee"] = [NSNumber numberWithInteger:[req.totalfee integerValue]];
//    parameters[@"bill_no"] = req.billno;
//    parameters[@"title"] = req.title;
//
//    if (req.optional) {
//        parameters[@"optional"] = req.optional;
//    }
//    if ([req.channel isEqualToString:PayChannelBaiduWap]) {
//        parameters[@"return_url"] = @"http://payservice.beecloud.cn/apicloud/baidu/return_url.php";
//    }
//    
//    BCHTTPSessionManager *manager = [BCPayUtil getBCHTTPSessionManager];
//    
//    [manager POST:[BCPayUtil getBestHostWithFormat:kRestApiPay] parameters:parameters progress:nil
//          success:^(NSURLSessionTask *task, id response) {
//    
//              NSDictionary *resp = (NSDictionary *)response;
//              if ([[resp objectForKey:kKeyResponseResultCode] integerValue] != 0) {
//                  if (_deleagte && [_deleagte respondsToSelector:@selector(onBeeCloudResp:)]) {
//                      [_deleagte onBeeCloudResp:resp];
//                  }
//              } else {
//                  NSLog(@"channel=%@,resp=%@", req.channel, response);
//                  
//                  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:
//                                              (NSDictionary *)response];
//                  if ([BCPayCache currentMode]) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        PaySandboxViewController *view = [[PaySandboxViewController alloc] init];
//                        view.bcId = [dic stringValueForKey:@"id" defaultValue:@""];
//                        view.req = req;
//                        [req.viewController presentViewController:view animated:YES completion:^{
//                        }];
//                    });
//                  } else {
//                      if ([req.channel isEqualToString: PayChannelAliApp]) {
//                          [dic setObject:req.scheme forKey:@"scheme"];
//                      } else if ([req.channel isEqualToString: PayChannelUnApp] || [req.channel isEqualToString: PayChannelBCApp] || [req.channel isEqualToString: PayChannelApple]) {
//                          [dic setObject:req.viewController forKey:@"viewController"];
//                      }
//                      [self doPayAction:req.channel source:dic];
//                  }
//              }
//          } failure:^(NSURLSessionTask *operation, NSError *error) {
//              [BCPay doErrorResponse:kNetWorkError errDetail:kNetWorkError];
//          }];
//}

@end
