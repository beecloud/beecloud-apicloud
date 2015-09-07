//
//  BCPayResp.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPayResp.h"

#pragma mark pay response
@implementation BCPayResp
- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypePayResp;
    }
    return self;
}
@end
