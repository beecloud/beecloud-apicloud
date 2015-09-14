//
//  BCQRefundReq.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryRefundReq.h"

#pragma mark query refund request
@implementation BCQueryRefundReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryRefundReq;
        self.refundno = @"";
    }
    return self;
}
@end
