//
//  BCPay.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPay.h"

#import "BCPayUtil.h"
#import "WXApi.h"
#import "AlipaySDK.h"
#import "UPPayPlugin.h"
#import "NSDictionaryUtils.h"


@interface BCPay ()<WXApiDelegate, UPPayPluginDelegate>

@property (nonatomic, weak) id<BCApiDelegate> deleagte;

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
    return [WXApi registerApp:wxAppID];
}

+ (void)setBCApiDelegate:(id<BCApiDelegate>)delegate {
    [BCPay sharedInstance].deleagte = delegate;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    BCPay *instance = [BCPay sharedInstance];
    
    if (BCPayUrlWeChat == [BCPay getUrlType:url]) {
        return [WXApi handleOpenURL:url delegate:instance];
    } else if (BCPayUrlAlipay == [BCPay getUrlType:url]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [instance processOrderForAliPay:resultDic];
        }];
        return YES;
    }
    return NO;
}

+ (BCPayUrlType)getUrlType:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"])
        return BCPayUrlAlipay;
    else if ([url.scheme hasPrefix:@"wx"] && [url.host isEqualToString:@"pay"])
        return BCPayUrlWeChat;
    else
        return BCPayUrlUnknown;
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
    BCPay *instance = [BCPay sharedInstance];
    switch (req.type) {
        case BCObjsTypePayReq:
            [instance reqPay:(BCPayReq *)req];
            break;
        case BCObjsTypeQueryReq:
            [instance reqQueryOrder:(BCQueryReq *)req];
            break;
        case BCObjsTypeQueryRefundReq:
            [instance reqQueryOrder:(BCQueryRefundReq *)req];
            break;
        case BCObjsTypeRefundStatusReq:
            [instance reqRefundStatus:(BCRefundStatusReq *)req];
            break;
        default:
            break;
    }
}

#pragma mark private class functions

#pragma mark Pay Request

- (void)reqPay:(BCPayReq *)req {
    if (![self checkParameters:req]) return;
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请检查是否全局初始化"];
        return;
    }
    
    parameters[@"channel"] = req.channel;
    parameters[@"total_fee"] = [NSNumber numberWithInteger:[req.totalfee integerValue]];
    parameters[@"bill_no"] = req.billno;
    parameters[@"title"] = req.title;

    if (req.optional) {
        parameters[@"optional"] = req.optional;
    }
    if ([req.channel isEqualToString:PayChannelBaiduWap]) {
        parameters[@"return_url"] = @"http://payservice.beecloud.cn/apicloud/baidu/return_url.php";
    }
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    [manager POST:[BCPayUtil getBestHostWithFormat:kRestApiPay] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
        
              NSDictionary *resp = (NSDictionary *)response;
              if ([[resp objectForKey:kKeyResponseResultCode] integerValue] != 0) {
                  if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
                      [_deleagte onBCPayResp:resp];
                  }
              } else {
                  NSLog(@"channel=%@,resp=%@", req.channel, response);
                  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:
                                              (NSDictionary *)response];
                  if ([req.channel isEqualToString: PayChannelAliApp]) {
                      [dic setObject:req.scheme forKey:@"scheme"];
                  } else if ([req.channel isEqualToString: PayChannelUnApp]) {
                      [dic setObject:req.viewController forKey:@"viewController"];
                  }
                  [self doPayAction:req.channel source:dic];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self doErrorResponse:kNetWorkError errDetail:kNetWorkError];
          }];
}

#pragma mark Do pay action

- (void)doPayAction:(NSString *)channel source:(NSMutableDictionary *)dic {
    if (dic) {
        if ([channel isEqualToString:PayChannelWxApp]) {
            [self doWXPay:dic];
        } else if ([channel isEqualToString:PayChannelAliApp]) {
            [self doAliPay:dic];
        } else if ([channel isEqualToString:PayChannelUnApp]) {
            [self doUnionPay:dic];
        } else if ([channel isEqualToString:PayChannelBaiduWap]) {
            if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayBaidu:)]) {
                [_deleagte onBCPayBaidu:[dic stringValueForKey:@"url" defaultValue:@""]];
            }
        } else if ([channel isEqualToString:PayChannelBaiduApp]) {
            if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayBaidu:)]) {
                [_deleagte onBCPayBaidu:[dic stringValueForKey:@"orderInfo" defaultValue:@""]];
            }
        }
    }
}

- (void)doWXPay:(NSMutableDictionary *)dic {
    BCPayLog(@"WeChat pay prepayid = %@", [dic objectForKey:@"prepay_id"]);
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [dic objectForKey:@"partner_id"];
    request.prepayId = [dic objectForKey:@"prepay_id"];
    request.package = [dic objectForKey:@"package"];
    request.nonceStr = [dic objectForKey:@"nonce_str"];
    NSMutableString *time = [dic objectForKey:@"timestamp"];
    request.timeStamp = time.intValue;
    request.sign = [dic objectForKey:@"pay_sign"];
    [WXApi sendReq:request];
    NSLog(@"excute wxpay");
}

- (void)doAliPay:(NSMutableDictionary *)dic {
    BCPayLog(@"Ali Pay Start");
    NSString *orderString = [dic objectForKey:@"order_string"];
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:dic[@"scheme"]
                                callback:^(NSDictionary *resultDic) {
                                    [self processOrderForAliPay:resultDic];
                                }];
}

- (void)doUnionPay:(NSMutableDictionary *)dic {
    NSString *tn = [dic objectForKey:@"tn"];
    BCPayLog(@"Union Pay Start %@", dic);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UPPayPlugin startPay:tn mode:@"00" viewController:(UIViewController *)[dic objectForKey:@"viewController"] delegate:[BCPay sharedInstance]];
    });
}

#pragma mark Query Bills/Refunds

- (void)reqQueryOrder:(BCQueryReq *)req {
    if (req == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请求结构体不合法"];
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请检查是否全局初始化"];
        return;
    }
    NSString *reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryBills];
    
    if (req.billno.isValid) {
        parameters[@"bill_no"] = req.billno;
    }
    if (req.starttime.isValid) {
        parameters[@"start_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.starttime]];
    }
    if (req.endtime.isValid) {
        parameters[@"end_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.endtime]];
    }
    if (req.type == BCObjsTypeQueryRefundReq) {
        BCQueryRefundReq *refundReq = (BCQueryRefundReq *)req;
        if (refundReq.refundno.isValid) {
            parameters[@"refund_no"] = refundReq.refundno;
        }
        reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryRefunds];
    }
    parameters[@"channel"] = [[req.channel componentsSeparatedByString:@"_"] firstObject];
    parameters[@"skip"] = [NSNumber numberWithInteger:req.skip];
    parameters[@"limit"] = [NSNumber numberWithInteger:req.limit];
    
    NSMutableDictionary *preparepara = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager GET:reqUrl parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"query end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
             NSDictionary *resp = (NSDictionary *)response;
             if ([resp objectForKey:kKeyResponseResultCode] != 0) {
                 if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
                     [_deleagte onBCPayResp:resp];
                 }
             } else {
                 NSLog(@"channel=%@, resp=%@", req.channel, response);
                 [self doQueryResponse:(NSDictionary *)response];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self doErrorResponse:kNetWorkError errDetail:kNetWorkError];
         }];
}

- (void)doQueryResponse:(NSDictionary *)dic {
    NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:dic];
    resp[@"type"] = @(BCObjsTypeQueryResp);
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:resp];
    }
}

#pragma mark Refund Status

- (void)reqRefundStatus:(BCRefundStatusReq *)req {
    if (req == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请求结构体不合法"];
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请检查是否全局初始化"];
        return;
    }
    
    if (req.refundno.isValid) {
        parameters[@"refund_no"] = req.refundno;
    }
    parameters[@"channel"] = @"WX";
    
    NSMutableDictionary *preparepara = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    [manager GET:[BCPayUtil getBestHostWithFormat:kRestApiRefundState] parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             [self doQueryRefundStatus:(NSDictionary *)response];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self doErrorResponse:kNetWorkError errDetail:kNetWorkError];
         }];
}

- (void)doQueryRefundStatus:(NSDictionary *)dic {
    BCRefundStatusResp *resp = [[BCRefundStatusResp alloc] init];
    resp.result_code = [dic[kKeyResponseResultCode] intValue];
    resp.result_msg = dic[kKeyResponseResultMsg];
    resp.err_detail = dic[kKeyResponseErrDetail];
    resp.refundStatus = [dic objectForKey:@"refund_status"];
    
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:resp];
    }
}

#pragma mark Util Function

- (BOOL)isValidChannel:(NSString *)channel {
    if (!channel.isValid) {
        return NO;
    }
    NSArray *channelList = @[PayChannelWxApp,PayChannelAliApp,PayChannelUnApp,PayChannelBaiduWap, PayChannelBaiduApp];
    return [channelList containsObject:channel];
}

- (void)doErrorResponse:(NSString *)resultMsg errDetail:(NSString *)errMsg {
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithCapacity:10];
    dic[kKeyResponseResultCode] = @(BCErrCodeCommon);
    dic[kKeyResponseResultMsg] = resultMsg;
    dic[kKeyResponseErrDetail] = errMsg;
    
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:dic];
    }
}

- (BOOL)checkParameters:(BCBaseReq *)request {
    if (request.type == BCObjsTypePayReq) {
        BCPayReq *req = (BCPayReq *)request;
        if (![self isValidChannel:req.channel]) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"channel 渠道不支持"];
            return NO;
        } else if (!req.title.isValid || [BCPayUtil getBytes:req.title] > 32) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串"];
            return NO;
        } else if (!req.totalfee.isValid || !req.totalfee.isPureInt) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"totalfee 以分为单位，必须是整数"];
            return NO;
        } else if (!req.billno.isPureInt || (!req.billno.isValidTraceNo) || (req.billno.length < 8) || (req.billno.length > 32)) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"billno 必须是长度8~32位字母和/或数字组合成的字符串"];
            return NO;
        } else if ((req.channel == PayChannelAliApp) && !req.scheme.isValid) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"scheme 不是合法的字符串，将导致无法从支付宝钱包返回应用"];
            return NO;
        } else if (req.channel == PayChannelWxApp && ![WXApi isWXAppInstalled]) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"未找到微信客户端，请先下载安装"];
            return NO;
        }
    }
    return YES ;
}

#pragma mark - Implementation WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *tempResp = (PayResp *)resp;
        NSString *strMsg = @"";
        int errcode = 0;
        switch (tempResp.errCode) {
            case WXSuccess:
                strMsg = @"支付成功";
                errcode = BCSuccess;
                break;
            case WXErrCodeUserCancel:
                strMsg = @"支付取消";
                errcode = BCErrCodeUserCancel;
                break;
            default:
                strMsg = @"支付失败";
                errcode = BCErrCodeFail;
                break;
        }
        NSString *result = tempResp.errStr.isValid?[NSString stringWithFormat:@"%@,%@",strMsg,tempResp.errStr]:strMsg;
        
        NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithCapacity:10];
        dic[kKeyResponseResultCode] = @(errcode);
        dic[kKeyResponseResultMsg] = result;
        dic[kKeyResponseErrDetail] = result;
        
        if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
            [_deleagte onBCPayResp:dic];
        }
    }
}

#pragma mark - Implementation AliPayDelegate

- (void)processOrderForAliPay:(NSDictionary *)resultDic {
    int status = [resultDic[@"resultStatus"] intValue];
    NSString *strMsg = @"";
    int errcode = 0;
    switch (status) {
        case 9000:
            strMsg = @"支付成功";
            errcode = BCSuccess;
            break;
        case 8000:
            strMsg = @"正在处理中";
            errcode = BCErrCodeCommon;
            break;
        case 4000:
        case 6002:
            strMsg = @"支付失败";
            errcode = BCErrCodeFail;
            break;
        case 6001:
            strMsg = @"支付取消";
            errcode = BCErrCodeUserCancel;
            break;
        default:
            strMsg = @"未知错误";
            errcode = BCErrCodeUnsupport;
            break;
    }
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithCapacity:10];
    dic[kKeyResponseResultCode] = @(errcode);
    dic[kKeyResponseResultMsg] = strMsg;
    dic[kKeyResponseErrDetail] = strMsg;
    
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:dic];
    }
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
    
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:dic];
    }
}

@end
