//
//  YSMainTabBarViewController.m
//  YSRun
//
//  Created by moshuqi on 15/10/15.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSMainTabBarViewController.h"
#import "YSCalendarViewController.h"
#import "YSRunViewController.h"
#import "YSUserViewController.h"
#import "YSDataManager.h"

@interface YSMainTabBarViewController () <YSRunViewControllerDelegate, YSUserViewControllerDelegate>

@property (nonatomic, strong) YSCalendarViewController *calendarViewController;
@property (nonatomic, strong) YSRunViewController *runViewController;
@property (nonatomic, strong) YSUserViewController *userViewController;

@end

@implementation YSMainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViewControllers];
    
    self.selectedIndex = 1; // 进入应用首先显示中间的视图
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initViewControllers
{
    // 初始化视图控制器
    
    [self initCalendarViewController];
    [self initRunViewController];
    [self initUserViewController];
    
    UINavigationController *runNav = [[UINavigationController alloc] initWithRootViewController:self.runViewController];
    UINavigationController *userNav = [[UINavigationController alloc] initWithRootViewController:self.userViewController];
    
    self.viewControllers = @[self.calendarViewController, runNav, userNav];
}

- (void)initCalendarViewController
{
    self.calendarViewController = [[YSCalendarViewController alloc] init];
    
//    CGSize size = CGSizeMake(56, 56);
    
    NSString *imageName = @"calendar.png";
//    self.calendarViewController.tabBarItem.image = [self getImageWithName:imageName size:size];
    self.calendarViewController.tabBarItem.image = [UIImage imageNamed:imageName];
    
    NSString *selectedImageName = @"calendar_highlight";
//    self.calendarViewController.tabBarItem.selectedImage = [self getImageWithName:selectedImageName size:size];
    self.calendarViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.calendarViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
}

- (void)initRunViewController
{
    self.runViewController = [[YSRunViewController alloc] init];
    self.runViewController.delegate = self;
    
//    CGSize size = CGSizeMake(46, 46);
    
    NSString *imageName = @"run";
//    self.runViewController.tabBarItem.image = [self getImageWithName:imageName size:size];
    self.runViewController.tabBarItem.image = [UIImage imageNamed:imageName];
    
    NSString *selectedImageName = @"run_highlight";
//    self.runViewController.tabBarItem.selectedImage = [self getImageWithName:selectedImageName size:size];
    self.runViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.runViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
}

- (void)initUserViewController
{
    self.userViewController = [[YSUserViewController alloc] init];
    self.userViewController.delegate = self;
    
//    CGSize size = CGSizeMake(56, 56);
    
    NSString *imageName = @"user";
//    self.userViewController.tabBarItem.image = [self getImageWithName:imageName size:size];
    self.userViewController.tabBarItem.image = [UIImage imageNamed:imageName];
    
    NSString *selectedImageName = @"user_highlight";
//    self.userViewController.tabBarItem.selectedImage = [self getImageWithName:selectedImageName size:size];
    self.userViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.userViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
}

- (UIImage *)getImageWithName:(NSString *)imageName size:(CGSize)size
{
    // 切图大小不匹配，自己根据尺寸需求重绘图片。临时解决方式
    UIImage *image = [UIImage imageNamed:imageName];
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* newImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // 用原图，否则系统会进行渲染
    newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return newImage;
}

#pragma mark - YSRunViewControllerDelegate

- (void)runViewUserStateChanged
{
    [self.calendarViewController resetCalendar];
}

- (void)runningFinish
{
    // 每完成一次跑步也刷新一次数据
    [self.calendarViewController resetCalendar];
}

#pragma mark - YSUserViewControllerDelegate

- (void)userViewUserStateChanged
{
    [self.calendarViewController resetCalendar];
}

@end
