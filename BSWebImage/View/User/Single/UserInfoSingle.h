//
//  UserInfoSingle.h
//  BSWebImage
//
//  Created by 王飞荣 on 2018/9/18.
//  Copyright © 2018年 BS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoSingle : NSObject

+ (instancetype)shareUserInfo;

@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* gender;
@property (nonatomic, copy) NSString* birthday;
@property (nonatomic, copy) NSString* signature;

@end
