//
//  BCPayPalReq.h
//  BCPay
//
//  Created by Ewenlong03 on 15/8/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "PayPalMobile.h"

@interface BCPayPalReq : BCBaseReq

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *shipping;
@property (nonatomic, strong) NSString *tax;
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, strong) PayPalConfiguration *payConfig;
@property (nonatomic, strong) id<PayPalPaymentDelegate> viewController;

@end
