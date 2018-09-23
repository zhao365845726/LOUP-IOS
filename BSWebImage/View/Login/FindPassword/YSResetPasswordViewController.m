//
//  YSResetPasswordViewController.m
//  YSRun
//
//  Created by moshuqi on 15/10/30.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSResetPasswordViewController.h"
#import "YSNavigationBarView.h"
#import "YSAppMacro.h"
#import "YSNetworkManager.h"
#import "YSTipLabelHUD.h"
#import "YSLoginViewController.h"
#import "YSUtilsMacro.h"
#import "YSLoadingHUD.h"
#import "YSDevice.h"
#import "YSTextFieldComponentCreator.h"

#import "YSTextFieldDelegateObj.h"
#import "YSContentCheckIconChange.h"

@interface YSResetPasswordViewController () <YSNetworkManagerDelegate, YSContentCheckIconChangeDelegate, YSTextFieldDelegateObjCallBack>

@property (nonatomic, weak) IBOutlet YSNavigationBarView *navigationBarView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *sumbitButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *textFieldHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *textFieldTopToBarViewBottomConstraint;

@property (nonatomic, strong) YSTextFieldDelegateObj *textFieldDelegateObj;

@end

@implementation YSResetPasswordViewController

- (id)initWithPhoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self)
    {
        self.phoneNumber = phoneNumber;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationBarView setupWithTitle:@"重置密码" barBackgroundColor:[UIColor clearColor] target:self action:@selector(resetPasswordViewBack)];
    
    // 在此处改变constant并不会导致对应控件的高度立即变化，所以setup方法中需要控件高度的地方直接取constant的值
    self.textFieldTopToBarViewBottomConstraint.constant = [self constraintConstant];
    if ([YSDevice isPhone6Plus])
    {
        self.textFieldHeightConstraint.constant = 52;
    }
    
    [self setupButton];
    [self setupTextField];
    [self setupBackgroundImage];
    [self addBackgroundTapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setupButton
{
    [self.sumbitButton setTitle:@"提  交" forState:UIControlStateNormal];
    [self.sumbitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
//    CGFloat btnHeight = self.textFieldHeightConstraint.constant;
    self.sumbitButton.layer.cornerRadius = ButtonCornerRadius;
    
    self.sumbitButton.backgroundColor = GreenBackgroundColor;
    self.sumbitButton.clipsToBounds = YES;
}

- (void)setupBackgroundImage
{
    // 设置背景图片
    UIImage *image = [UIImage imageNamed:@"login_background"];
    self.view.layer.contents = (id)image.CGImage;
}

- (void)addBackgroundTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapBackground:(id)tapGesture
{
    // 点击背景处时收起键盘。
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)setupTextField
{
    CGFloat textFieldHeight = CGRectGetHeight(self.textField.frame);
    [YSTextFieldComponentCreator setupTextField:self.textField height:textFieldHeight];
    
    UIImage *image = [YSTextFieldComponentCreator getPasswordIconWithContentEmptyState:YES];
    self.textField.leftView = [YSTextFieldComponentCreator getViewWithImage:image textFieldHeight:textFieldHeight];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    [YSTextFieldComponentCreator setupTextField:self.textField withPlaceholder:@"请设置新密码"];
    
    self.textField.secureTextEntry = YES;
    
    UIButton *secureTextButton = [self getSecureTextButton];
    self.textField.rightView = [YSTextFieldComponentCreator getViewWithPasswordSecureButton:secureTextButton buttonWidth:56 textFieldHeight:textFieldHeight];
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.enablesReturnKeyAutomatically = YES;
    
    [self setupTextFieldDelegate];
}

- (void)setupTextFieldDelegate
{
    // 给文本框设置代理，有输入字符时文本框左边图标改变
    
    YSContentCheckIconChange *contentCheck = [[YSContentCheckIconChange alloc] initWithDelegate:self];
    NSArray *contentCheckArray = @[contentCheck];
    
    self.textFieldDelegateObj = [[YSTextFieldDelegateObj alloc] initWithEditingCheckArray:nil contentCheckArray:contentCheckArray];
    self.textField.delegate = self.textFieldDelegateObj;
    
    self.textFieldDelegateObj.delegate = self;
}

- (UIButton *)getSecureTextButton
{
    UIButton *secureTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [secureTextButton addTarget:self action:@selector(secureTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [UIImage imageNamed:@"password_eye_close"];
    [secureTextButton setImage:image forState:UIControlStateNormal];
    
    return secureTextButton;
}

- (void)secureTextButtonClicked:(UIButton *)button
{
    self.textField.secureTextEntry = !self.textField.secureTextEntry;
    
    UIImage *image = self.textField.secureTextEntry ? [UIImage imageNamed:@"password_eye_close"] : [UIImage imageNamed:@"password_eye_open"];
    [button setImage:image forState:UIControlStateNormal];
}

- (CGFloat)constraintConstant
{
    // 根据实际情况计算的constant值，既第一个文本框与导航栏的距离
    
    CGFloat distance = 5;   // 控件间的间距
    CGFloat height = self.textFieldHeightConstraint.constant;   // 控件的高度，文本框和按钮的高度相同
    CGFloat barViewHeight = CGRectGetHeight(self.navigationBarView.frame);
    
    CGFloat screenHeight = [UIApplication sharedApplication].keyWindow.frame.size.height;
    // 按钮距底边的间距为第一个文本框距导航栏的间距的2倍
    CGFloat constant = (screenHeight - barViewHeight - height * 2 - distance) / 3;
    
    return constant;
}

- (IBAction)submitButtonClicked:(id)sender
{
    [self resetPassword];
}

- (void)resetPassword
{
    NSString *newPassword = self.textField.text;
    
    if ([newPassword length] < 1)
    {
        NSString *tip = @"密码不能为空";
        [self showTipLabelWithText:tip];
        return;
    }
    
    [[YSLoadingHUD shareLoadingHUD] show];
    
    WS(weakSelf);
    NSMutableDictionary* Mdic = [NSMutableDictionary dictionary];
    [Mdic setValue:self.phoneNumber forKey:@"Mobile"];
    [Mdic setValue:self.verificationCode forKey:@"VerificationCode"];
    [Mdic setValue:newPassword forKey:@"NewPassword"];
    
    [ABHttpRequest ASyncPOST:KChangePasswordUrl andParameters:Mdic andTimeOut:KTimeOut loading:YES success:^(BOOL success, int code, NSString *msg, id responseObject) {
        if(success){
            [[YSTipLabelHUD shareTipLabelHUD]showTipWithText:@"重置成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }else{
            
        }
    } failure:^(NSString *msg) {
        
    }];
}

- (void)showTipLabelWithText:(NSString *)text
{
    [[YSTipLabelHUD shareTipLabelHUD] showTipWithText:text];
}

- (void)resetPasswordViewBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YSNetworkManagerDelegate

- (void)resetPasswordSuccess
{
    // 重置密码成功后跳转到登录界面
    
    [[YSLoadingHUD shareLoadingHUD] dismiss];
    
    [[YSTipLabelHUD shareTipLabelHUD] showTipWithText:@"密码重置成功"];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *popToViewController = nil;
    
    for (UIViewController *viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[YSLoginViewController class]])
        {
            popToViewController = viewController;
            break;
        }
    }
    
    [self.navigationController popToViewController:popToViewController animated:YES];
}

- (void)resetPasswordFailureWithMessage:(NSString *)message
{
    [[YSLoadingHUD shareLoadingHUD] dismiss];
    
    [[YSTipLabelHUD shareTipLabelHUD] showTipWithText:message];
}

- (void)needChangeTextField:(UITextField *)textField textEmpty:(BOOL)isEmpty
{
    CGFloat textFieldHeight = CGRectGetHeight(textField.frame);
    textField.leftView = [YSTextFieldComponentCreator getViewWithImage:[YSTextFieldComponentCreator getPasswordIconWithContentEmptyState:isEmpty] textFieldHeight:textFieldHeight];
}

#pragma mark - YSTextFieldDelegateObjCallBack

- (void)textFieldDidReturn:(UITextField *)textField
{
    if (textField == self.textField)
    {
        [self resetPassword];
    }
}

@end
