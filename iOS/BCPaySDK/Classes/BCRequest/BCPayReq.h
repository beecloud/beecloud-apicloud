//
//  BCPayReq.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "BCPayConstant.h"
#import <UIKit/UIKit.h>

#pragma mark BCPayReq
/**
 *  Pay Request请求结构体
 */
@interface BCPayReq : BCBaseReq //type=101
/**
 *  支付渠道(WX,Ali,Union)
 */
@property (nonatomic, retain) NSString *channel;
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
 *  Apple Pay必填，0 表示不区分卡类型；1 表示只支持借记卡；2 表示支持信用卡；默认为0
 */
@property (nonatomic, assign) NSUInteger cardType;
/**
 *  扩展参数,可以传入任意数量的key/value对来补充对业务逻辑的需求
 */
@property (nonatomic, retain) NSDictionary *optional;

@end
