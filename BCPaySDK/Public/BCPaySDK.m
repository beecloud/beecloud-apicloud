//
//  BCPay.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPaySDK.h"

#import "BCPayUtil.h"
#import "WXApi.h"
#import "AlipaySDK.h"
#import "UPPayPlugin.h"


@interface BCPaySDK ()<WXApiDelegate, UPPayPluginDelegate>

@property (nonatomic, assign) BOOL registerStatus;
@property (nonatomic, weak) id<BCApiDelegate> deleagte;
@property (nonatomic, strong) UIViewController *upController;

@end

@implementation BCPaySDK

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCPaySDK *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCPaySDK alloc] init];
        instance.registerStatus = NO;

        instance.upController = [[UIViewController alloc] init];
    });
    return instance;
}

+ (void)initWithAppID:(NSString *)appId andAppSecret:(NSString *)appSecret {
    BCPayCache *instance = [BCPayCache sharedInstance];
    instance.appId = appId;
    instance.appSecret = appSecret;
    [BCPaySDK sharedInstance];
}

+ (BOOL)initWeChatPay:(NSString *)wxAppID {
    BCPaySDK *instance = [BCPaySDK sharedInstance];
    instance.registerStatus =  [WXApi registerApp:wxAppID];
    return instance.registerStatus;
}

+ (void)setBCApiDelegate:(id<BCApiDelegate>)delegate {
    [BCPaySDK sharedInstance].deleagte = delegate;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    BCPaySDK *instance = [BCPaySDK sharedInstance];
    
    if (BCPayUrlWeChat == [BCPaySDK getUrlType:url]) {
        return [WXApi handleOpenURL:url delegate:instance];
    } else if (BCPayUrlAlipay == [BCPaySDK getUrlType:url]) {
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
    if (req.type == BCObjsTypePayReq) {
        [[BCPaySDK sharedInstance] reqPay:(BCPayReq *)req];
    } else if (req.type == BCObjsTypeQueryReq ) {
        [[BCPaySDK sharedInstance] reqQueryOrder:(BCQueryReq *)req];
    } else if (req.type == BCObjsTypeQueryRefundReq) {
        [[BCPaySDK sharedInstance] reqQueryOrder:(BCQueryRefundReq *)req];
    } else if (req.type == BCObjsTypeRefundStatusReq) {
        [[BCPaySDK sharedInstance] reqRefundStatus:(BCRefundStatusReq *)req];
    }
}

#pragma mark private class functions

#pragma mark Pay Request

- (void)reqPay:(BCPayReq *)req {
    if (![self checkParameters:req]) return;
    
    NSString *cType = [self getChannelString:req.channel];
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请检查是否全局初始化"];
        return;
    }
    
    parameters[@"channel"] = cType;
    parameters[@"total_fee"] = [NSNumber numberWithInteger:[req.totalfee integerValue]];
    parameters[@"bill_no"] = req.billno;
    parameters[@"title"] = req.title;
    if (req.optional) {
        parameters[@"optional"] = req.optional;
    }
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager POST:[BCPayUtil getBestHostWithFormat:kRestApiPay] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              BCPayLog(@"wechat end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
              NSDictionary *resp = (NSDictionary *)response;
              if ([[resp objectForKey:kKeyResponseResultCode] integerValue] != 0) {
                  if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
                      [_deleagte onBCPayResp:resp];
                  }
              } else {
                  NSLog(@"channel=%@,resp=%@", cType, response);
                  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:
                                              (NSDictionary *)response];
                  if (req.channel == Ali) {
                      [dic setObject:req.scheme forKey:@"scheme"];
                  }
                  if (req.channel == Union) {
                      [dic setObject:req.viewController forKey:@"viewController"];
                  }
                  [self doPayAction:req.channel source:dic];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self doErrorResponse:kNetWorkError errDetail:kNetWorkError];
          }];
}

#pragma mark Do pay action

- (void)doPayAction:(PayChannel)channel source:(NSMutableDictionary *)dic {
    if (dic) {
        switch (channel) {
            case WX:
                [self doWXPay:dic];
                break;
            case Ali:
                [self doAliPay:dic];
                break;
            case Union:
                [self doUnionPay:dic];
                break;
            default:
                break;
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
        [UPPayPlugin startPay:tn mode:@"00" viewController:(UIViewController *)[dic objectForKey:@"viewController"] delegate:[BCPaySDK sharedInstance]];
    });
}

#pragma mark Query Bills/Refunds

- (void)reqQueryOrder:(BCQueryReq *)req {
    if (req == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请求结构体不合法"];
        return;
    }
    
    NSString *cType = [[BCPaySDK sharedInstance] getChannelString:req.channel];
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:kKeyCheckParamsFail errDetail:@"请检查是否全局初始化"];
        return;
    }
    NSString *reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryBills];
    
    if ([BCPayUtil isValidString:req.billno]) {
        parameters[@"bill_no"] = req.billno;
    }
    if ([BCPayUtil isValidString:req.starttime]) {
        parameters[@"start_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.starttime]];
    }
    if ([BCPayUtil isValidString:req.endtime]) {
        parameters[@"end_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.endtime]];
    }
    if (req.type == BCObjsTypeQueryRefundReq) {
        BCQueryRefundReq *refundReq = (BCQueryRefundReq *)req;
        if ([BCPayUtil isValidString:refundReq.refundno]) {
            parameters[@"refund_no"] = refundReq.refundno;
        }
        reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryRefunds];
    }
    parameters[@"channel"] = [[cType componentsSeparatedByString:@"_"] firstObject];
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
                 NSLog(@"channel=%@, resp=%@", cType, response);
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
    
    if ([BCPayUtil isValidString:req.refundno]) {
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

+ (PayChannel)getChannelType:(NSString *)channel {
    PayChannel pType = None;
    if ([channel isEqualToString:@"WX_APP"]) {
        pType = WX;
    } else if ([channel isEqualToString:@"ALI_APP"]) {
        pType = Ali;
    } else if ([channel isEqualToString:@"UN_APP"]) {
        pType = Union;
    }

    return pType;
}

- (NSString *)getChannelString:(PayChannel)channel {
    NSString *cType = @"";
    switch (channel) {
        case WX:
            cType = @"WX_APP";
            break;
        case Ali:
            cType = @"ALI_APP";
            break;
        case Union:
            cType = @"UN_APP";
            break;
        default:
            break;
    }
    return cType;
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
        NSString *cType = [[BCPaySDK sharedInstance] getChannelString:req.channel];
        if (![BCPayUtil isValidString:cType]) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"channel 渠道不支持"];
            return NO;
        } else if (![BCPayUtil isValidString:req.title] || [BCPayUtil getBytes:req.title] > 32) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串"];
            return NO;
        } else if (![BCPayUtil isValidString:req.totalfee] || ![BCPayUtil isPureInt:req.totalfee]) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"totalfee 以分为单位，必须是整数"];
            return NO;
        } else if (![BCPayUtil isValidString:req.billno] || (![BCPayUtil isValidTraceNo:req.billno]) || (req.billno.length < 8) || (req.billno.length > 32)) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"billno 必须是长度8~32位字母和/或数字组合成的字符串"];
            return NO;
        } else if ((req.channel == Ali) && ![BCPayUtil isValidString:req.scheme]) {
            [self doErrorResponse:kKeyCheckParamsFail errDetail:@"scheme 不是合法的字符串，将导致无法从支付宝钱包返回应用"];
            return NO;
        } else if (req.channel == WX && ![WXApi isWXAppInstalled]) {
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
        NSString *result = [BCPayUtil isValidString:tempResp.errStr]?[NSString stringWithFormat:@"%@,%@",strMsg,tempResp.errStr]:strMsg;
        
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
