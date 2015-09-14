//
//  BCRefundStateReq.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCRefundStatusReq.h"

@implementation BCRefundStatusReq
- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeRefundStatusReq;
        self.refundno = @"";
    }
    return self;
}

@end
