//
//  BCPayPalAccessTokenReq.h
//  BCPay
//
//  Created by Ewenlong03 on 15/8/28.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "PayPalPayment.h"

@interface BCPayPalVerifyReq : BCBaseReq

@property (nonatomic, strong) PayPalPayment *payment;

@end
