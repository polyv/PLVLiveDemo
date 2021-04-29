//
//  PLVUtil.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

//struct PLVColorComponent {
//    CGFloat red;
//    CGFloat green;
//    CGFloat blue;
//    CGFloat alpha;
//};
//typedef struct PLVColorComponent PLVColorComponent;
//
//PLVColorComponent PLVColorComponentMake(UInt32 hex, CGFloat alpha);
//PLVColorComponent PLVColorComponentWithHex(UInt32 hex);

/*
 v1.4.1+190726
 */
#define APP_VERSION @"PolyvStreamer_v1.5.0+200904"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface PLVUtil : NSObject

/// md5加密传入参数
+ (NSString*)md5HexDigest:(NSString *)input;

/// 弹出错误信息
+ (void)alertErrorWithTitle:(NSString *)title reason:(NSString *)reason target:(id)target;

/// 弹出信息
+ (void)alertInfo:(NSString *)info target:(id)target;

/// 弹出信息
+ (void)alertInfo:(NSString *)info target:(id)target completionHandler:(void (^)(void))completionHandler;

/// 弹出消息
+ (void)alertInfoWithTitle:(NSString *)title info:(NSString *)info target:(id)target completionHandler:(void (^)(void))completionHandler;

/// 显示HUD信息
+ (void)showHUDViewWithMessage:(NSString *)message superView:(UIView *)superView;

/// 请求视频访问
+ (void)requestAccessForVideoWithCompletionHandler:(void (^)(void))completionHandler;

/// 请求音频访问
+ (void)requestAccessForAudio;

/// 计算字符长度
+ (int)calculateTextLength:(NSString *)strTemp;

@end

/// 时间字符串
NSString *stringWithTime(long time);

/// 中文时间字符串
NSString *stringWithTimeZh(long time);

/// 中文时间属性字符串
NSAttributedString *attributedStringWithTimeZh(long time);

/// 网速字符串
NSString *stringWithSpeed(CGFloat speed);
