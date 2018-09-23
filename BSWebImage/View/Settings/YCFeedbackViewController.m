//
//  YCFeedbackViewController.m
//  YC
//
//  Created by 悦动互娱 on 2017/8/23.
//  Copyright © 2017年 悦动互娱. All rights reserved.
//

#import "YCFeedbackViewController.h"
#import "YSTipLabelHUD.h"
#import "YSNavigationBarView.h"

#define kMaxLength 200

@interface YCFeedbackViewController ()<UITextViewDelegate> {
    
    
    UITextView *_txvSuggest;
    
    UILabel *_lblSuggestContentPlaceholder;
    
    UILabel *_lblCount;
    
    UIButton* _btSubmit;
}
@property (weak, nonatomic) IBOutlet YSNavigationBarView *barView1;

@property (nonatomic, strong) NSMutableArray *assetsArray;
@end

@implementation YCFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];

    [_barView1 setupWithTitle:@"意见反馈" barBackgroundColor:GreenBackgroundColor target:self action:@selector(registerViewBack)];
//    _barView.titleLabel.text = @"意见反馈";
    self.navigationController.navigationBarHidden = YES;
}

- (void)registerViewBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)initUI {
   
    if (!_txvSuggest) {
        _txvSuggest = [[UITextView alloc] initWithFrame:CGRectMake(14, 20+64, ScreenPtWidth - 14 * 2, 200)];
        [self.view addSubview:_txvSuggest];
        
        _txvSuggest.backgroundColor = [UIColor clearColor];
        _txvSuggest.textColor = [UIColor blackColor];
        _txvSuggest.font = [UIFont systemFontOfSize:14];
        _txvSuggest.delegate = self;
        _txvSuggest.scrollEnabled = NO;
    
        if (!_lblSuggestContentPlaceholder) {
            _lblSuggestContentPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, _txvSuggest.bounds.size.width - 10, 20)];
            _lblSuggestContentPlaceholder.text = @"请输入你宝贵的建议和所遇到的问题…";
            _lblSuggestContentPlaceholder.numberOfLines = 0;
            _lblSuggestContentPlaceholder.font = [UIFont systemFontOfSize:14];
            _lblSuggestContentPlaceholder.userInteractionEnabled = NO;
            _lblSuggestContentPlaceholder.backgroundColor = [UIColor clearColor];
            _lblSuggestContentPlaceholder.textColor = [UIColor lightGrayColor];
            [_lblSuggestContentPlaceholder sizeToFit];
            [_txvSuggest addSubview:_lblSuggestContentPlaceholder];
        }
        
    }

    if (!_btSubmit) {
        _btSubmit = [[UIButton alloc] initWithFrame:CGRectMake(14,CGRectGetMaxY(_txvSuggest.frame), ScreenPtWidth - 28, 44)];
        [self.view addSubview:_btSubmit];
        
        _btSubmit.backgroundColor = GreenBackgroundColor;
        _btSubmit.layer.cornerRadius = 10;
        _btSubmit.titleLabel.font = [UIFont systemFontOfSize:16];
        [_btSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btSubmit setTitle:@"提交" forState:UIControlStateNormal];
    
        [_btSubmit addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];

    }
}

- (void)commitAction
{
    if ([self checkDataVaild]) {
        [self disposeFeedback];
    }
}

- (BOOL)checkDataVaild {
    [self.view endEditing:YES];
    if (!_txvSuggest.text || _txvSuggest.text.length == 0) {

        [[YSTipLabelHUD shareTipLabelHUD]showTipWithText:@"请输入你宝贵的建议和所遇到的问题"];
        return NO;
    }
    
    return YES;
}

- (void)disposeFeedback {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
   
    [params setObject:_txvSuggest.text forKey:@"Body"];
    [params setObject:@(0) forKey:@"type"];
    [params setObject:KUserId forKey:@"UserId"];
    
    [ABHttpRequest ASyncPOST:KUserFeedback andParameters:params andTimeOut:KTimeOut loading:YES success:^(BOOL success, int code, NSString *msg, id responseObject) {
        if(success){
            [[YSTipLabelHUD shareTipLabelHUD]showTipWithText:@"反馈成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            
        }
    } failure:^(NSString *msg) {
        
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    NSInteger currentCount = textView.text.length;
    if(currentCount <= kMaxLength) {
        _lblCount.text = [NSString stringWithFormat:@"%zd/%d", currentCount, kMaxLength];
        return  YES;
    } else {
        return  NO;
    }
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        _lblSuggestContentPlaceholder.text = @"请输入你宝贵的建议和所遇到的问题…";
    }else{
        _lblSuggestContentPlaceholder.text = @"";
    }
    
    NSString *toBeString = textView.text;
    
    NSString *lang = [[[UIApplication sharedApplication] textInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        
        UITextRange *selectedRange = [textView markedTextRange];
        
        //获取高亮部分
        
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        
        if (!position) {
            
            if (toBeString.length > kMaxLength) {
                
                textView.text = [toBeString substringToIndex:kMaxLength];
                
            }
            
        }
        
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else {
            
        }
    }
    
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    
    else {
        if (toBeString.length > kMaxLength) {
            textView.text = [toBeString substringToIndex:kMaxLength];
        }
    }
    
    NSInteger currentCount = textView.text.length;
    if(currentCount <= kMaxLength) {
        _lblCount.text = [NSString stringWithFormat:@"%zd/%d", currentCount, kMaxLength];
    }
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height <= (160 - (20 + 10 + 27))) {
        size.height = 160 - (20 + 10 + 27);
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
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
