//
//  BCQueryResp.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryResp.h"

#pragma mark query response
@implementation BCQueryResp
- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryResp;
    }
    return self;
}
@end
