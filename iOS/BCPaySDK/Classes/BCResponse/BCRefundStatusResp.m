//
//  BCRefundStateResp.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCRefundStatusResp.h"

@implementation BCRefundStatusResp

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeRefundStatusResp;
    }
    return self;
}

@end
