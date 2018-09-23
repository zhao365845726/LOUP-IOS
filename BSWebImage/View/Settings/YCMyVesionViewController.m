//
//  YCMyVesionViewController.m
//  BSWebImage
//
//  Created by feirong on 2018/9/21.
//  Copyright © 2018年 BS. All rights reserved.
//

#import "YCMyVesionViewController.h"
#import "YSNavigationBarView.h"

@interface YCMyVesionViewController ()
@property (weak, nonatomic) IBOutlet YSNavigationBarView *barView;
@property (weak, nonatomic) IBOutlet UILabel *vesionLb;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation YCMyVesionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_barView setupWithTitle:@"我的版本" barBackgroundColor:GreenBackgroundColor target:self action:@selector(registerViewBack)];
    self.navigationController.navigationBarHidden = YES;

     NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    _vesionLb.text = [NSString stringWithFormat:@"奔跑呀V%@", appVersion];

    _imageView.layer.cornerRadius = 40;
    _imageView.layer.masksToBounds = YES;
}

//- (void)initUI {
//    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 86, 86)];
//    logoImageView.layer.cornerRadius = 15;
//    [self.view addSubview:logoImageView];
//
//    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
//    //获取app中所有icon名字数组
//    NSArray *iconsArr = infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
//    //取最后一个icon的名字
//    NSString *iconLastName = [iconsArr lastObject];
//    logoImageView.image = [UIImage imageNamed:@""];
//    logoImageView.center = self.view.center;
//
//    UILabel *appVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoImageView.frame) + 20, 0, 0)];
//    [self.view addSubview:appVersionLabel];
//    appVersionLabel.font = [UIFont systemFontOfSize:12];
//    appVersionLabel.textColor = [UIColor lightGrayColor];
//
//    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
//    appVersionLabel.text = [NSString stringWithFormat:@"悦彩V%@", appVersion];
//    [appVersionLabel sizeToFit];
//
//    appVersionLabel.center.x = self.view.center.x;
//
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, appVersionLabel.frameMaxY + 69, 0, 0)];
//    [self.view addSubview:label];
//    label.font = [UIFont systemFontOfSize:14];
//    label.textColor = kDefaultTextColor;
//
//    label.text = @"我们只做最诚信 最放心 最专业的购彩平台";
//    [label sizeToFit];
//    [label centerAlignHorizontalForSuperView];
//
//    UILabel *englishLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, label.frameMaxY + 5, 262, 0)];
//    [self.view addSubview:englishLabel];
//    englishLabel.font = [UIFont systemFontOfSize:12];
//    englishLabel.textColor = [UIColor lightGrayColor];
//    englishLabel.textAlignment = NSTextAlignmentCenter;
//
//    NSMutableParagraphStyle *englishContentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [englishContentParagraphStyle setLineSpacing:5];
//
//    NSString *englishContent = @"We only do the most honest and most assured the most professional platform";
//    NSMutableAttributedString *englishContentAttributedString = [[NSMutableAttributedString alloc] initWithString:englishContent];
//    [englishContentAttributedString addAttribute:NSParagraphStyleAttributeName value:englishContentParagraphStyle range:NSMakeRange(0, [englishContent length])];
//
//    englishLabel.attributedText = englishContentAttributedString;
//    englishLabel.textAlignment = NSTextAlignmentCenter;
//    englishLabel.numberOfLines = 0;
//    [englishLabel sizeToFit];
//    [englishLabel centerAlignHorizontalForSuperView];
//
//
//    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 215, 0)];
//    [self.view addSubview:bottomLabel];
//
//    bottomLabel.font = [UIFont systemFontOfSize:12];
//    bottomLabel.textColor = [UIColor lightGrayColor];
//
//    NSMutableParagraphStyle *coppyringhtParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [coppyringhtParagraphStyle setLineSpacing:5];
//
//    NSDate *date = [NSDate date];
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    formatter.dateFormat = @"yyyy";
//
//    NSString *coppyringht = [NSString stringWithFormat:@"Copyringht@2017-%@ yuecai58.com\n悦动互娱（深圳）信息技术有限公司", [formatter stringFromDate:date]];
//    NSMutableAttributedString *coppyringhtAttributedString = [[NSMutableAttributedString alloc] initWithString:coppyringht];
//    [coppyringhtAttributedString addAttribute:NSParagraphStyleAttributeName value:coppyringhtParagraphStyle range:NSMakeRange(0, [coppyringht length])];
//
//    bottomLabel.attributedText = coppyringhtAttributedString;
//    bottomLabel.textAlignment = NSTextAlignmentCenter;
//    bottomLabel.numberOfLines = 2;
//    [bottomLabel sizeToFit];
//    [bottomLabel centerAlignHorizontalForSuperView];
//
//    bottomLabel.frameMaxY = ScreenPtWidth - 64 - 20;
//
//
//
//}
- (void)registerViewBack
{
    [self.navigationController popViewControllerAnimated:YES];
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

@end
