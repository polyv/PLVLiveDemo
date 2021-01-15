//
//  PLVLiveSettingViewController+Share.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2021/1/7.
//  Copyright © 2021 easefun. All rights reserved.
//

#import "PLVLiveSettingViewController.h"
#import <UMSocialCore/UMSocialPlatformConfig.h>


@interface PLVLiveSettingViewController (Share)

- (void)shareWithWechat:(UIButton *)sender;

- (void)shareWithMoment:(UIButton *)sender;

- (void)shareWithWeibo:(UIButton *)sender;

- (void)shredWithQQ:(UIButton *)sender;

- (void)shareWithQzone:(UIButton *)sender;

@end

