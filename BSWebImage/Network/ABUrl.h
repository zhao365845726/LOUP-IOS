//
//  ABUrl.h
//  AiBanClient
//
//  Created by feirong on 2018/9/7.
//  Copyright © 2018年 aiban. All rights reserved.
//

#ifndef ABUrl_h
#define ABUrl_h

#define KAppBaseUrl @"http://lu.api.ymstudio.xyz"


/** ------------------------------------------------用户模块接口------------------------------------------------*/
 
#define KUserLoginUrl @"/api/user/login"

#define KUserRegisterUrl @"/api/user/register"

#define KGetUserInfoUrl @"/api/user/getuserinfobyuserid"

#define KUpdatePhotoGraphUrl @"/api/user/updatephotograph"

#define KUpdateUserInfoUrl @"/api/user/perfectinfo"

#define KChangePasswordUrl @"/api/user/modifypassword"

#define KSignoutUrl @"/api/user/signout"

#define KSendSMSVerificationCode @"/api/user/sendsmsverificationcode"

#define KGetUploadToken @"/api/qiniu/getuploadtoken"

#define KUserFeedback @"/api/user/feedback"

#endif /* ABUrl_h */
