//
//  PLVCountdownView.h
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/10.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
// 代理协议声明
@class PLVCountdownView;

@protocol PLVCountdownViewDelegate <NSObject>
@optional
- (void)countdownViewDidEnd:(PLVCountdownView *)countdownView;

@end
@interface PLVCountdownView : UIView

@property (nonatomic, assign) BOOL logEnable;

/// 代理属性
@property (nonatomic, weak) id<PLVCountdownViewDelegate> delegate;

/// 开始倒计时
- (void)beginCountdown;

@end
