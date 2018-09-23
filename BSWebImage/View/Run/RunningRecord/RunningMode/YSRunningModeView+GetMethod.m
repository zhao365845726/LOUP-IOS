//
//  YSRunningModeView+GetMethod.m
//  YSRun
//
//  Created by moshuqi on 15/10/19.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSRunningModeView+GetMethod.h"
#import "YSDevice.h"

static const CGFloat kDistanceFromButtonToSideEdge = 20;    // 按钮与屏幕左右边缘的间距
static const CGFloat kButtonDisappearDistance = 30;         // 按钮消失离开屏幕可视范围时，上边缘距离底边的距离
static const CGFloat kDistanceFromModeStatusViewToTimeLabel = 42;   // 时间标签与模式切换按钮的间距

@implementation YSRunningModeView (GetMethod)

- (CGRect)getModeStatusViewFrame
{
    // 子类重载
    return CGRectZero;
}

- (CGRect)getTimeLabelFrame
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = 56;
    if ([YSDevice isPhone6Plus])
    {
        height = 72;
    }
    
    CGRect frame = CGRectMake(self.modeStatusView.frame.origin.x,
                              self.modeStatusView.frame.origin.y + CGRectGetHeight(self.modeStatusView.frame) + kDistanceFromModeStatusViewToTimeLabel,
                              width, height);
    return frame;
}

- (CGRect)getDistanceLabelFrame
{
    // 子类重载
    return CGRectZero;
}

- (CGRect)getDataViewFrame
{
    CGFloat width = CGRectGetWidth(self.frame) / 3 * 2; //  dataView视图宽度为其父视图三分之二
    CGFloat height = 116;
    if ([YSDevice isPhone6Plus])
    {
        height = 146;
    }
    
    CGFloat distance = 32;  // 与时间标签的间距
    CGRect frame = CGRectMake(self.timeLabel.frame.origin.x,
                              self.timeLabel.frame.origin.y + CGRectGetHeight(self.timeLabel.frame) + distance,
                              width, height);
    return frame;
}

- (CGRect)getPaceLabelFrame
{
    // 子类重载
    return CGRectZero;
}

- (CGRect)getHeartRateLabelFrame
{
    // 子类重载
    return CGRectZero;
}

- (CGRect)getFinishButtonAppearFrame
{
    CGSize buttonSize = [self getButtonSize];
    
    CGFloat originY = CGRectGetHeight(self.frame) - [self getDistanceFormButtonToBottomEdge] - buttonSize.height;
    CGRect frame = CGRectMake(kDistanceFromButtonToSideEdge, originY, buttonSize.width, buttonSize.height);
    return frame;
}

- (CGRect)getFinishButtonDisappearFrame
{
    CGRect appearFrame = [self getFinishButtonAppearFrame];
    CGFloat originY = CGRectGetHeight(self.frame) + kButtonDisappearDistance + [self getButtonSize].height;
    
    CGRect frame = CGRectMake(appearFrame.origin.x, originY, appearFrame.size.width, appearFrame.size.height);
    return frame;
}

- (CGRect)getContinueButtonAppearFrame
{
    CGSize buttonSize = [self getButtonSize];
    
    CGFloat originX = CGRectGetWidth(self.frame) - buttonSize.width - kDistanceFromButtonToSideEdge;
    CGFloat originY = CGRectGetHeight(self.frame) - [self getDistanceFormButtonToBottomEdge] - buttonSize.height;
    
    CGRect frame = CGRectMake(originX, originY, buttonSize.width, buttonSize.height);
    return frame;
}

- (CGFloat)getDistanceFormButtonToBottomEdge
{
    // 按钮下边缘距底边的距离
    CGFloat d = [YSDevice isPhone6Plus] ? 152 : 86;
    return d;
}

- (CGRect)getContinueButtonDisappearFrame
{
    CGRect appearFrame = [self getContinueButtonAppearFrame];
    CGFloat originY = CGRectGetHeight(self.frame) + kButtonDisappearDistance + [self getButtonSize].height;
    
    CGRect frame = CGRectMake(appearFrame.origin.x, originY, appearFrame.size.width, appearFrame.size.height);
    return frame;
}

- (CGSize)getButtonSize
{
    // 按钮的宽度
    CGSize size = self.continueButton.frame.size;
    return size;
}

- (CGRect)getPulldownViewFrame
{
    CGFloat width = CGRectGetWidth(self.pulldownView.frame);
    CGFloat height = CGRectGetHeight(self.pulldownView.frame);
    
    CGFloat originY = [self getContinueButtonAppearFrame].origin.y;
    CGFloat originX = (CGRectGetWidth(self.frame) - width) / 2;
    
    CGRect frame = CGRectMake(originX, originY, width, height);
    return frame;
}

- (CGRect)getPulldownViewDisappearFrame
{
    CGRect appearFrame = [self getPulldownViewFrame];
    CGFloat originY = CGRectGetHeight(self.frame) + kButtonDisappearDistance + [self getPulldownViewFrame].size.height;
    
    CGRect frame = CGRectMake(appearFrame.origin.x, originY, appearFrame.size.width, appearFrame.size.height);
    return frame;
}

- (CGPoint)pulldownViewOriginPoint
{
    CGRect frame = [self getPulldownViewFrame];
    CGPoint point = CGPointMake(frame.origin.x + frame.size.width / 2,
                                frame.origin.y + frame.size.height / 2);
    
    return point;
}

- (CGFloat)getPulldownViewOriginDistanceFromEdge
{
    // pulldownView初始位置中心距离父视图（屏幕）下边缘的距离
    CGFloat height = CGRectGetHeight(self.bounds);
    CGPoint originPoint = [self pulldownViewOriginPoint];
    
    CGFloat distance = height - originPoint.y;
    return distance;
}

- (CGFloat)getContinueButtonChangeDistance
{
    // 继续按钮显示位置和隐藏位置之间的距离
    CGRect appearFrame = [self getContinueButtonAppearFrame];
    CGRect disappearFrame = [self getContinueButtonDisappearFrame];
    
    CGFloat distance = disappearFrame.origin.y - appearFrame.origin.y;
    return distance;
}

- (CGFloat)getFinishButtonChangeDistance
{
    // 完成按钮显示位置和隐藏位置之间的距离
    CGRect appearFrame = [self getFinishButtonAppearFrame];
    CGRect disappearFrame = [self getFinishButtonDisappearFrame];
    
    CGFloat distance = disappearFrame.origin.y - appearFrame.origin.y;
    return distance;
}

@end
