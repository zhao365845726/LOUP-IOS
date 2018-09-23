//
//  BSWebImage.h
//  BasicShell
//
//  Created by xiao6 on 2018/5/3.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSWebImage : NSObject
@property (nonatomic, strong) NSDictionary *launchOptions;
+ (instancetype)sharedInstance;
+ (void)setupWithLaunchOptions:(NSDictionary *)launchOptions startDate:(NSString *)startDate navtiVC:(id(^)(void))nativeBlock;
@end
