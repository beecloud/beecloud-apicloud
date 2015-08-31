//
//  BCPayObject.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/14.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

typedef NS_ENUM(NSInteger, PayChannel) {
    None = 0,
    WX,
    Ali,
    Union
};

enum  BCErrCode {
    BCSuccess           = 0,    /**< 成功    */
    BCErrCodeCommon     = -1,   /**< 参数错误类型    */
    BCErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
    BCErrCodeFail   = -3,       /**< 发送失败    */
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

#pragma mark BCBaseReq
/**
 *  BCPay 所有请求的基类
 */
@interface BCBaseReq : NSObject
/**
 *  //1:Pay;2:queryBills;3:queryRefunds;
 */
@property (nonatomic, assign) BCObjsType type;//100

@end

#pragma mark BCPayReq
/**
 *  Pay Request请求结构体
 */
@interface BCPayReq : BCBaseReq //type=101
/**
 *  支付渠道(WX,Ali,Union)
 */
@property (nonatomic, assign) PayChannel channel;
/**
 *  订单描述,32个字节内,最长16个汉字
 */
@property (nonatomic, retain) NSString *title;
/**
 *  支付金额,以分为单位,必须为整数,100表示1元
 */
@property (nonatomic, retain) NSString *totalfee;
/**
 *  商户系统内部的订单号,8~32位数字和/或字母组合,确保在商户系统中唯一
 */
@property (nonatomic, retain) NSString *billno;
/**
 *  调用支付的app注册在info.plist中的scheme,支付宝支付需要
 */
@property (nonatomic, retain) NSString *scheme;
/**
 *  调起银联支付的页面，银联支付需要
 */
@property (nonatomic, retain) UIViewController *viewController;
/**
 *  扩展参数,可以传入任意数量的key/value对来补充对业务逻辑的需求
 */
@property (nonatomic, retain) NSDictionary *optional;

@end

#pragma mark BCQueryReq
/**
 *  根据条件查询请求支付订单记录
 */
@interface BCQueryReq : BCBaseReq

@property (nonatomic, assign) PayChannel channel;
@property (nonatomic, retain) NSString *billno;
@property (nonatomic, assign) NSString *starttime;//@"yyyyMMddHHmm"格式
@property (nonatomic, assign) NSString *endtime;//@"yyyyMMddHHmm"格式
@property (nonatomic, assign) NSInteger skip;
@property (nonatomic, assign) NSInteger limit;

@end

#pragma mark BCQueryRefundReq
/**
 *  根据条件查询退款记录
 */
@interface BCQueryRefundReq : BCQueryReq //type=103;

@property (nonatomic, retain) NSString *refundno;

@end

/**
 *  查询一笔退款的订单的状态，目前仅支持“WX”渠道
 */
@interface BCRefundStatusReq : BCBaseReq

@property (nonatomic, retain) NSString *refundno;

@end

#pragma mark BCBaseResp
/**
 *  BeeCloud所有响应的基类
 */
@interface BCBaseResp : NSObject

@property (nonatomic, assign) BCObjsType type;//200;
/** 响应码 */
@property (nonatomic, assign) int result_code;
/** 响应提示字符串 */
@property (nonatomic, retain) NSString *result_msg;
/** 错误详情 */
@property (nonatomic, retain) NSString *err_detail;

@end

#pragma mark BCPayResp
/**
 *  支付请求的响应
 */
@interface BCPayResp : BCBaseResp  //type=201;

@property (nonatomic, retain) NSDictionary *paySource;

@end

#pragma mark BCQueryResp
/**
 *  查询订单的响应，包括支付、退款订单
 */
@interface BCQueryResp : BCBaseResp
/**
 *  查询到得结果数量
 */
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, retain) NSMutableArray *results;

@end

#pragma mark BCRefundStatusResp
/**
 *  查询退款订单状态的响应
 */
@interface BCRefundStatusResp : BCBaseResp

@property (nonatomic, retain) NSString *refundStatus;

@end

#pragma mark BCBaseResult

/**
 *  订单查询结果的基类
 */
@interface BCBaseResult : NSObject

@property (nonatomic, assign) BCObjsType type;
@property (nonatomic, retain) NSString  *bill_no;
@property (nonatomic, assign) NSInteger  total_fee;//NSInteger
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, assign) long long  created_time;//long long
@property (nonatomic, retain) NSString  *channel;

@end

#pragma mark BCQueryBillResult
/**
 *  支付订单查询结果
 */
@interface BCQueryBillResult : BCBaseResult

@property (nonatomic, assign) BOOL spay_result;

@end

#pragma mark BCQueryRefundResult

/**
 *  退款订单查询结果
 */
@interface BCQueryRefundResult : BCBaseResult

@property (nonatomic, retain) NSString *refund_no;
@property (nonatomic, assign) NSInteger refund_fee; //NSInteger
@property (nonatomic, assign) BOOL      finish;//BOOL
@property (nonatomic, assign) BOOL      result;//BOOL

@end

