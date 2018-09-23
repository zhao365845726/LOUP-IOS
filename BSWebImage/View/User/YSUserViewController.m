//
//  YSUserViewController.m
//  YSRun
//
//  Created by moshuqi on 15/10/15.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSUserViewController.h"
#import "YSUserLevelView.h"
#import "YSUserSettingView.h"
#import "YSUserNoLoginView.h"
#import "YSLoginViewController.h"
#import "YSDataManager.h"
#import "YSUserInfoModel.h"
#import "YSUserInfoResponseModel.h"
#import "YSDatabaseManager.h"
#import "YSNetworkManager.h"
#import "YSRunDatabaseModel.h"
#import "YSUtilsMacro.h"
#import "YSModifyPasswordViewController.h"
#import "YSPhotoPicker.h"
#import "YSUserDatabaseModel.h"
#import "YSModelReformer.h"
#import "YSSetUserRequestModel.h"
#import "YSRunDataHandler.h"
#import "YSSettingsViewController.h"
#import "YSShareFunc.h"
#import "YSUserDataHandler.h"
#import "HttpTool.h"

@interface YSUserViewController () <YSUserNoLoginViewDelegate, YSLoginViewControllerDelegate, YSNetworkManagerDelegate, YSUserSettingViewDelegate, YSUserLevelViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YSPhotoPickerDelegate, YSRunDataHandlerDelegate, YSSettingsViewControllerDelegate, YSUserDataHandlerDelegate>
{
    NSInteger upgradeArrayCount;
    NSInteger topGrade;
    NSArray * upgrade;
}
@property (nonatomic, weak) IBOutlet YSUserLevelView *userLevelView;//头视图
@property (nonatomic, weak) IBOutlet UIView *settingContentView;    //下面的内容视图

@property (nonatomic, strong) YSUserSettingView *userSettingView;   //用户设置视图
@property (nonatomic, strong) YSUserNoLoginView *userNoLoginView;   //没有登录的视图

@property (nonatomic, strong) YSPhotoPicker *photoPicker;
@property (nonatomic, strong) YSRunDataHandler *runDataHandler; //跑步数据处理
@property (nonatomic, strong) YSUserDataHandler *userDataHandler;   //用户数据处理

@end

//// 数组依次对应升级需要的总次数，暂时的升级数据需求，满级为6级
// NSInteger upgrade[] = {0, 3, 6, 9, 15, 20}; // 初始1级，升到2级总次数要3次，升到3级要6次...
// NSInteger upgradeArrayCount = 6;
// NSInteger topGrade = 6;

@implementation YSUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    upgradeArrayCount = 6;
    topGrade = 6;
    upgrade = @[@0, @3, @6, @9, @15, @20];
    
    self.navigationController.navigationBarHidden = YES;
    [self setupContentView];
    
    self.userLevelView.delegate = self;
    
    self.runDataHandler = [YSRunDataHandler new];
    self.runDataHandler.delegate = self;
    
    self.userDataHandler = [YSUserDataHandler new];
    self.userDataHandler.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(KUserId && ![KUserId isEqualToString:@" "]){
        [self loadUserInfo];
    }else{
        
    }
    [self changeViewWithLoginState:(KUserId && ![KUserId isEqualToString:@" "]) ? YES : NO];
    // 显示用户界面时设置用户数据
    [self setupUserLevel];
    
    [self.userSettingView reloadTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self resizeContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)setupUserGrage:(NSDictionary *)userInfo
{
    // 计算等级相关数据
    NSInteger totalRunTimes = [userInfo[@"TotalUseTime"] integerValue];

    NSInteger grade = [self evaluateGradeByRunTimes:totalRunTimes];
    NSInteger upgradeRequireTimes = [self evaluateUpgradeRequireTimesByRunTimes:totalRunTimes];
    CGFloat progress = [self evaluateUpgradeProgressByRunTimes:totalRunTimes];
    NSString *achieveTitle = [self achieveTitleWithGrade:grade];

    [self.userLevelView setUserName:[[NSUserDefaults standardUserDefaults]objectForKey:@"RealName"] headPhoto:[UIImage imageNamed:@"user_default_photo"] grade:grade achieveTitle:achieveTitle progress:progress upgradeRequireTimes:upgradeRequireTimes];
}

- (NSInteger)evaluateGradeByRunTimes:(NSInteger)runTimes
{
    // 通过跑步的总次数来计算当前等级

    NSInteger grade = 1;
    if (runTimes >= [upgrade[upgradeArrayCount - 1] integerValue])
    {
        grade = topGrade;
    }
    else
    {
        for (NSInteger i = 0; i < upgradeArrayCount; i ++)
        {
            if (runTimes < [upgrade[i] integerValue])
            {
                grade = i;
                break;
            }
        }
    }

    return grade;
}

- (NSInteger)evaluateUpgradeRequireTimesByRunTimes:(NSInteger)runTimes
{
    // 计算距离下次升级还需要跑步的次数

    NSInteger grade = [self evaluateGradeByRunTimes:runTimes];
    if ([self isTopGrade:grade])
    {
        // 按现在的规则是满级了
        YSLog(@"满级了。。。");
        return 0;
    }

    NSInteger upgradeRequireTimes = 0;
    for (NSInteger i = 0; i < upgradeArrayCount; i++)
    {
        if (runTimes < [upgrade[i] intValue])
        {
            upgradeRequireTimes = [upgrade[i] intValue] - runTimes;
            break;
        }
    }

    return upgradeRequireTimes;
}

- (BOOL)isTopGrade:(NSInteger)grade
{
    // 是否满级
    BOOL isTopGrade = (grade >= topGrade) ? YES : NO;
    return isTopGrade;
}

- (CGFloat)evaluateUpgradeProgressByRunTimes:(NSInteger)runTimes
{
    // 计算升下一级的进度

    NSInteger grade = [self evaluateGradeByRunTimes:runTimes];
    if ([self isTopGrade:grade])
    {
        // 达到满级，进度条满
        return 1.0;
    }
    NSInteger currentGradeRequireTimes = 0;
    if (grade > 1) {
        NSInteger currentGradeRequireTimes = [upgrade[grade - 1] integerValue];    // 当前等级所需要的次数
    }
    
    NSInteger nextGradeRequireTimes = [upgrade[grade] integerValue];    // 下一等级所需要的次数
    
    NSInteger step = nextGradeRequireTimes - currentGradeRequireTimes;
    CGFloat progress = (CGFloat)(runTimes - currentGradeRequireTimes) / step;
    
    return progress;
}

- (NSString *)achieveTitleWithGrade:(NSInteger)grade
{
    // 等级头像计算方式
    NSString *achieveTitle = nil;
    if (grade < 4)
    {
        achieveTitle = @"初级跑步者";
    }
    else
    {
        achieveTitle = @"中级跑步者";
    }

    return achieveTitle;
}

- (void)loadUserInfo
{
    if (KUserId && ![KUserId isEqualToString:@" "]) {
        NSDictionary* dict = @{@"UserId":KUserId};
        [ABHttpRequest ASyncPOST:KGetUserInfoUrl andParameters:dict andTimeOut:KTimeOut loading:NO success:^(BOOL success, int code, NSString *msg, id responseObject) {
            if(success){
                [self setupUserGrage:responseObject];
            }
        } failure:^(NSString *msg) {
            
        }];
    }else{
        [self.userLevelView setUserName:[[NSUserDefaults standardUserDefaults]objectForKey:@"RealName"] headPhoto:[UIImage imageNamed:@"user_default_photo"] grade:0 achieveTitle:@"初级跑步者" progress:0 upgradeRequireTimes:0];
    }
}

- (void)setupContentView
{
    // 用户登录显示的界面
    NSArray *nibViews1 = [[NSBundle mainBundle] loadNibNamed:@"YSUserSettingView" owner:self options:nil];
    self.userSettingView = [nibViews1 objectAtIndex:0];
    self.userSettingView.delegate = self;
    
    [self.settingContentView addSubview:self.userSettingView];
    
    // 用户未登录时显示的界面
    NSArray *nibViews2 = [[NSBundle mainBundle] loadNibNamed:@"YSUserNoLoginView" owner:self options:nil];
    self.userNoLoginView = [nibViews2 objectAtIndex:0];
    self.userNoLoginView.delegate = self;
    
    [self.settingContentView addSubview:self.userNoLoginView];
}

- (void)resizeContentView
{
    CGRect frame = self.settingContentView.bounds;
    
    self.userSettingView.frame = frame;
    self.userNoLoginView.frame = frame;
}

- (void)resetUserLevel
{
    [[YSDataManager shareDataManager] resetData];
    [self setupUserLevel];
}

- (void)setupUserLevel
{
    // 放子线程执行了，否则开启APP时有可能会在这卡死。 2016.01.29
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        YSUserInfoModel *userInfo = [[YSDataManager shareDataManager] getUserInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.userLevelView setUserName:userInfo.nickname
                                  headPhoto:userInfo.headImage
                                      grade:userInfo.grade
                               achieveTitle:userInfo.achieveTitle
                                   progress:userInfo.progress
                        upgradeRequireTimes:userInfo.upgradeRequireTimes];
        });
    });
}

- (BOOL)hasLogin
{
    return [[YSDataManager shareDataManager] isLogin];
}

- (void)enterLoginView
{
    YSLoginViewController *loginViewController = [YSLoginViewController new];
    loginViewController.delegate = self;
//    [self.navigationController pushViewController:loginViewController animated:YES];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.navigationController.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)changeViewWithLoginState:(BOOL)isLogin
{
    if (isLogin)
    {
        [self.settingContentView bringSubviewToFront:self.userSettingView];
    }
    else
    {
        [self.settingContentView bringSubviewToFront:self.userNoLoginView];
    }
}

- (void)showPhotoSourceChoice
{
    self.photoPicker = [[YSPhotoPicker alloc] initWithViewController:self];
    self.photoPicker.delegate = self;
    
    [self.photoPicker showPickerChoice];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 接受点击事件，当在编辑用户昵称时，点击其他地方退出编辑转台收起键盘
    [super touchesBegan:touches withEvent:event];
    
    if ([self hasLogin])
    {
        // 登录情况下才能编辑用户昵称
        [self.view endEditing:YES];
    }
}

- (void)logout
{
    
    
    // 用户退出
    
    NSDictionary *parm = @{@"UserId" : KUserId};
    NSString *url = @"http://lu.api.ymstudio.xyz/api/user/signout";
    
    [HttpTool post:@"POST" url:url bodyParams:parm params:nil success:^(id responseObj) {
        if ([responseObj[@"status_code"] integerValue] == 200) {
            //需要修改
            [[NSUserDefaults standardUserDefaults] setObject:@" " forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setObject:@" " forKey:@"RealName"];
    
            // 用户注销时，删除数据库用户数据，和用户所对应的跑步数据。
            YSDataManager *manager = [YSDataManager shareDataManager];
            
            YSDatabaseManager *databaseManager = [YSDatabaseManager new];
            [databaseManager deleteUserAndRelatedRunDataWithUid:[manager getUid]];
            
            // 数据库更新后重置数据。
            [self resetUserLevel];
            [self changeViewWithLoginState:NO];
            
            // 退出登录后取消第三方的授权
            [YSShareFunc cancelAuthorized];
            
            // 用户退出时日历界面的跑步数据需要刷新一次
            [self.delegate userViewUserStateChanged];
            
        }
    } failure:^(NSError *error) {
        
    }];
    
   
}

- (void)modifyPassword
{
    // 修改密码
    NSString *phoneNumber = [[YSDataManager shareDataManager] getUserPhone];
    
    YSModifyPasswordViewController *modifyPasswordViewController = [[YSModifyPasswordViewController alloc] initWithPhoneNumber:phoneNumber];
    
    [self presentViewController:modifyPasswordViewController animated:YES completion:nil];
}

- (void)showSettingsView
{
    // 跳转到设置界面
    YSSettingsViewController *settingViewController = [YSSettingsViewController new];
    settingViewController.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - YSUserNoLoginViewDelegate

- (void)login
{
    if ([KUserId isEqualToString:@" "] || KUserId == nil) {
        [self enterLoginView];
    }
}

- (void)userNoLoginViewDidSelectedType:(YSSettingsType)type
{
    switch (type) {
        case YSSettingsTypeSet:
            [self showSettingsView];
            break;
            
        default:
            break;
    }
}

#pragma mark - YSLoginViewControllerDelegate

- (void)loginViewController:(YSLoginViewController *)loginViewController loginFinishWithUserInfoResponseDic:(NSDictionary *)Mdic{
    NSLog(@"Mdic=%@",Mdic);
    if(KUserId && ![KUserId isEqualToString:@" "]){
        [self loadUserInfo];
    }
    [self changeViewWithLoginState: (KUserId && ![KUserId isEqualToString:@" "]) ? YES : NO];
    // 显示用户界面时设置用户数据
    [self setupUserLevel];
}

- (void)loginViewController:(YSLoginViewController *)loginViewController loginFinishWithUserInfoResponseModel:(YSUserInfoResponseModel *)userInfoResponseModel
{
    // 用户登录成功
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.runDataHandler loginSuccessWithUserInfoResponseModel:userInfoResponseModel];
    });
    
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginViewController:(YSLoginViewController *)loginViewController registerFinishWithResponseUserInfo:(YSUserDatabaseModel *)userInfo
{
    // 用户注册成功，请求并返回用户信息，将用户保存到本地数据库，并上传未登录时的跑步数据。
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.runDataHandler registerSuccessWithResponseUserInfo:userInfo];
    });
    
    [loginViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - YSNetworkManagerDelegate

// 设置信息
- (void)setInfoSuccess
{
    
}

- (void)setInfoFailureWithMessage:(NSString *)message
{
    YSLog(@"%@", message);
}

#pragma mark - YSRunDataHandlerDelegate

- (void)runDataHandleFinish
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self setupUserLevel];
        [self changeViewWithLoginState:[self hasLogin]];
        
        // 登录成功后刷新一下，否则昵称会因为时机上的问题仍然显示“未登录”
        if ([self hasLogin])
        {
            [self.userSettingView reloadTableView];
        }
        
        // 用户登录注册成功之后，跑步数据处理完成之后的回调，此时刷新一下日历界面的跑步数据，保证日历正确显示数据
        [self.delegate userViewUserStateChanged];
    });
}

#pragma mark - YSUserDataHandlerDelegate

- (void)uploadHeadImageFinish
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        YSUserInfoModel *userInfo = [[YSDataManager shareDataManager] getUserInfo];
        [self.userLevelView setHeadPhoto:userInfo.headImage];
    });
}

#pragma mark - YSUserSettingViewDelegate

- (void)userSettingViewDidSelectedType:(YSSettingsType)type
{
    switch (type) {
        case YSSettingsTypeSet:
            [self showSettingsView];
            break;
            
        default:
            break;
    }
}

- (void)modifyNickame:(NSString *)nickname
{
    NSMutableDictionary* Mdic = [NSMutableDictionary dictionary];
    [Mdic setValue:KUserId forKey:@"UserId"];
    [Mdic setValue:nickname forKey:@"NickName"];
    
    WS(weakSelf);
    [ABHttpRequest ASyncPOST:KUpdateUserInfoUrl andParameters:Mdic andTimeOut:KTimeOut loading:YES success:^(BOOL success, int code, NSString *msg, id responseObject) {
        if(success){
            weakSelf.userLevelView.userNameString = nickname;
        }else{
            
        }
    } failure:^(NSString *msg) {
        
    }];
//    [self resetUserLevel];
}

#pragma mark - YSUserLevelViewDelegate

- (void)headPhotoChange
{
    [self showPhotoSourceChoice];
}

- (void)toLogin
{
    [self login];
}

- (BOOL)loginState
{
    return [self hasLogin];
}

#pragma mark - YSPhotoPickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didSelectImage:(UIImage *)image
{
//    YSNetworkManager *networkManager = [YSNetworkManager new];
//    networkManager.delegate = self;
//    
//    NSString *uid = [[YSDataManager shareDataManager] getUid];
//    [networkManager uploadHeadImage:image uid:uid];
    
    if (image)
    {
        [self.userDataHandler uploadHeadImage:image];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - YSSettingsViewControllerDelegate

- (void)settingsViewDidSelectedLogout
{
    [self logout];
}

@end
