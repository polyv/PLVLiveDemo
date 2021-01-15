//
//  PLVLiveSettingViewController+Share.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2021/1/7.
//  Copyright © 2021 easefun. All rights reserved.
//

#import "PLVLiveSettingViewController+Share.h"
#import "PLVUtil+Share.h"

@implementation PLVLiveSettingViewController (Share)

- (void)shareWithWechat:(UIButton *)sender {
    sender.selected = YES;
    #ifdef INCLUDE_UMSDK
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession sender:sender];
    #endif
}

- (void)shareWithMoment:(UIButton *)sender {
    sender.selected = YES;
    #ifdef INCLUDE_UMSDK
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine sender:sender];
    #endif
}

- (void)shareWithWeibo:(UIButton *)sender {
    sender.selected = YES;
    #ifdef INCLUDE_UMSDK
    [self shareWebPageToPlatformType:UMSocialPlatformType_Sina sender:sender];
    #endif
}

- (void)shredWithQQ:(UIButton *)sender {
    sender.selected = YES;
    #ifdef INCLUDE_UMSDK
    [self shareWebPageToPlatformType:UMSocialPlatformType_QQ sender:sender];
    #endif
}

- (void)shareWithQzone:(UIButton *)sender {
    sender.selected = YES;
    [PLVUtil showHUDViewWithMessage:@"复制成功" superView:self.view];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.setting.urlPreview;
}

// 分享至第三方平台
#ifdef INCLUDE_UMSDK
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType sender:(UIButton *)sender {
    [PLVUtil shareToPlatform:platformType title:self.setting.liveTitle thumImage:self.setting.urlAvatar webpageUrl:self.setting.urlPreview sender:sender target:self];
}
#endif

@end
