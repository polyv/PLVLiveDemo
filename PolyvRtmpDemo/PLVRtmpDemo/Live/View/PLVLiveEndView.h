//
//  PLVLiveEndView.h
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/11.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVLiveEndView : UIVisualEffectView
/// 结束按钮
@property (weak, nonatomic) IBOutlet UIButton *endButton;

/// 设置直播时间
- (void)setLiveTime:(long)time;

/// 设置直播人数
- (void)setLivePopulation:(long)population;

@property (nonatomic, assign) BOOL logEnable;
@end
