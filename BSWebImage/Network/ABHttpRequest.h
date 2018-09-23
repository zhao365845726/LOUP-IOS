//
//  ABHttpRequest.h
//  AiBanClient
//
//  Created by feirong on 2018/9/7.
//  Copyright © 2018年 aiban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABUrl.h"

typedef NS_ENUM(NSUInteger, RequestType) {
    RequestTypeGET,
    RequestTypePOST,
    RequestTypePUT,
    RequestTypeDELETE
};

#define KTimeOut 20

@interface ABHttpRequest : NSObject

/**
 @param seconds 请求超时时间，每个接口的超时时间可能不相同
 */
+ (void)ASyncGET:(NSString *)url andParameters:(NSMutableDictionary *)parameters andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success,int code, NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure;

+ (void)ASyncPOST:(NSString *)url andParameters:(NSMutableDictionary *)parameters andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success, int code,NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure;

+ (void)ASyncPUT:(NSString *)url andParameters:(NSMutableDictionary *)parameters  andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success, int code,NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure;

- (void)ASyncDELETE:(NSString *)url andParameters:(NSMutableDictionary *)parameters andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success, int code,NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure;


@end
