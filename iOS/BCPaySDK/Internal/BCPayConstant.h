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

static NSString * const kApiVersion = @"1.2.0";//api版本号

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
static NSString * const kKeyPayPalClientID = @"payPalClientId";
static NSString * const kKeyPayPalSecret = @"payPalSecret";
static NSString * const kKeyPayPalSandBox = @"payPalSandBox";

static NSUInteger const kBCHostCount = 4;
static NSString * const kBCHosts[] = {@"https://apisz.beecloud.cn",
    @"https://apiqd.beecloud.cn",
    @"https://apibj.beecloud.cn",
    @"https://apihz.beecloud.cn"};

static NSString * const reqApiVersion = @"/1";

//rest api
static NSString * const kRestApiPay = @"%@/rest/app/bill";
static NSString * const kRestApiQueryBills = @"%@/rest/bills";
static NSString * const kRestApiQueryRefunds = @"%@/rest/refunds";
static NSString * const kRestApiRefundState = @"%@/rest/refund/status";

//paypal accesstoken
static NSString * const kPayPalAccessTokenProduction = @"https://api.paypal.com/v1/oauth2/token";
static NSString * const kPayPalAccessTokenSandBox = @"https://api.sandbox.paypal.com/v1/oauth2/token";

/**
 *  BCPay URL type for handling URLs.
 */
typedef NS_ENUM(NSInteger, BCPayUrlType) {
    /**
     *  Unknown type.
     */
    BCPayUrlUnknown,
    /**
     *  WeChat pay.
     */
    BCPayUrlWeChat,
    /**
     *  Alipay.
     */
    BCPayUrlAlipay
};

static NSString * const PayChannelWxApp = @"WX_APP";//微信APP
static NSString * const PayChannelAliApp = @"ALI_APP";//支付宝APP
static NSString * const PayChannelUnApp = @"UN_APP";//银联APP
static NSString * const PayChannelBaiduWap = @"BD_WAP";
static NSString * const PayChannelBaiduApp = @"BD_APP";

enum  BCErrCode {
    BCSuccess           = 0,    /**< 成功    */
    BCErrCodeCommon     = -1,   /**< 参数错误类型    */
    BCErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
    BCErrCodeFail       = -3,   /**< 发送失败    */
    BCErrCodeUnsupport  = -4,   /**< BeeCloud不支持 */
};

typedef NS_ENUM(NSInteger, BCObjsType) {
    BCObjsTypeBaseReq = 100,
    BCObjsTypePayReq,
    BCObjsTypeQueryReq,
    BCObjsTypeQueryRefundReq,
    BCObjsTypeRefundStatusReq,
    
    BCObjsTypeBaseResp = 200,
    BCObjsTypePayResp,
    BCObjsTypeQueryResp,
    BCObjsTypeRefundStatusResp,
    
    BCObjsTypeBaseResults = 300,
    BCObjsTypeBillResults,
    BCObjsTypeRefundResults
};

static NSString * const kBCDateFormat = @"yyyy-MM-dd HH:mm";

#endif
