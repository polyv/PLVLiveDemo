//
//  PLVLiveSetting.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2021/1/4.
//  Copyright © 2021 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PLVDefinition) {
    /// 标清
    PLVDefinitionStandard,
    /// 高清
    PLVDefinitionHigh,
    /// 超清
    PLVDefinitionUltra,
};

@interface PLVLiveSetting : NSObject
/// 屏幕方向
@property (nonatomic, assign) BOOL landscapeEnable;
/// 清晰度
@property (nonatomic, assign) PLVDefinition definition;
/// 头像
@property (nonatomic, strong) NSString *urlAvatar;
/// 引导图
@property (nonatomic, copy) NSString *urlCover;
/// 预览
@property (nonatomic, copy) NSString *urlPreview;
/// 频道标题
@property (nonatomic, copy) NSString *liveTitle;
/// 最大码率(kbps)
@property (nonatomic, assign) NSUInteger maxRate;
/// 美颜开关
@property (nonatomic, assign) BOOL beautyEnable;
/// 聊天室房间号(分房间场景下，将返回第一个分房间号；其他场景返回 channelId；若分房间号为nil，则返回 channelId)
@property (nonatomic, copy) NSString *chatRoomId;

- (instancetype)initWithLoginResponse:(NSDictionary *)responseDict;

/// 推流尺寸
- (CGSize)videoSize;

//@property (nonatomic, copy, readonly) NSURL *rtmpURL;

/// RTMP URL
- (void)requestUrlRtmpWithCompletionHandler:(void (^)(NSString *urlRTMP))completionHandler;

@end
