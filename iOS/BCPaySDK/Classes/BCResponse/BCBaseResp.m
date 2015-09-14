//
//  BCBaseResp.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResp.h"

#pragma mark base response
@implementation BCBaseResp
- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeBaseResp;
    }
    return self;
}
@end
