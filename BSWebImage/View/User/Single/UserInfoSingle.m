//
//  UserInfoSingle.m
//  BSWebImage
//
//  Created by 王飞荣 on 2018/9/18.
//  Copyright © 2018年 BS. All rights reserved.
//

#import "UserInfoSingle.h"

static UserInfoSingle* _single = nil;

@implementation UserInfoSingle

+ (instancetype)shareUserInfo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _single = [[UserInfoSingle alloc]init];
    });
    return _single;
}

@end
