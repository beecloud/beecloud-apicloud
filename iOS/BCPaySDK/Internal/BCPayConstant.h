//
//  BCPayConstant.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/21.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef BCPaySDK_BCPayConstant_h
#define BCPaySDK_BCPayConstant_h

static NSString * const kApiVersion = @"1.0.0";//api版本号

static NSString * const kNetWorkError = @"网络请求失败";
static NSString * const kKeyResponseResultCode = @"result_code";
static NSString * const kKeyResponseResultMsg = @"result_msg";
static NSString * const kKeyResponseErrDetail = @"err_detail";
static NSString * const kKeyResponseType = @"respType";
static NSString * const kKeyCheckParamsFail = @"参数检查出错";

static NSString * const kKeyMoudleName = @"beecloud";
static NSString * const kKeyBCAppID = @"bcAppID";
static NSString * const kKeyBCAppSecret = @"bcAppSecret";
static NSString * const kKeyUrlScheme = @"urlScheme";

static NSUInteger const kBCHostCount = 4;
static NSString * const kBCHosts[] = {@"https://apisz.beecloud.cn",
    @"https://apiqd.beecloud.cn",
    @"https://apibj.beecloud.cn",
    @"https://apihz.beecloud.cn"};

static NSString * const reqApiVersion = @"/1";

//rest api
static NSString * const kRestApiPay = @"%@/rest/bill";
static NSString * const kRestApiRefund = @"%@/rest/refund";
static NSString * const kRestApiQueryBills = @"%@/rest/bills";
static NSString * const kRestApiQueryRefunds = @"%@/rest/refunds";
static NSString * const kRestApiRefundState = @"%@/rest/refund/status";

#endif
