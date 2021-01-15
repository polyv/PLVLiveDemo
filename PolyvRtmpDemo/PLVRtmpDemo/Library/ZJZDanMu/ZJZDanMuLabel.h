//
//  ZJZDanMuLabel.h
//  DanMu
//
//  Created by 郑家柱 on 16/6/17.
//  Copyright © 2016年 Jiangsu Houxue Network Information Technology Limited By Share Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KZJZDMHEIGHT 25            // 弹幕航道高度
#define KZJZDMLROLLANIMATION 10.0f // 弹幕默认滚动时间
#define KZJZDMLFADEANIMATION 4.0f  // 弹幕默认浮动时间

typedef NS_ENUM(NSUInteger, ZJZDMLStyle) {
    ZJZDMLRoll,             // 滚动弹幕
    ZJZDMLFade              // 浮动弹幕
};

typedef NS_ENUM(NSUInteger, ZJZDMLState) {
    ZJZDMLStateRunning,
    ZJZDMLStateStop,
    ZJZDMLStateFinish
};

@interface ZJZDanMuLabel : UILabel

@property (nonatomic, assign) ZJZDMLState                   zjzDMLState;
@property (nonatomic, assign) ZJZDMLStyle                   zjzDMLStyle;

/* 当前弹幕开始动画时间 */
@property (nonatomic, strong) NSDate                        *startTime;

/* 弹幕滚动速度 */
@property (nonatomic, assign, readonly) CGFloat             dmlSpeed;

/* 弹幕浮动时间 */
@property (nonatomic, assign, readonly) CGFloat             dmlFadeTime;

/* 创建 */
+ (instancetype)dmInitDML:(NSString *)content dmlOriginY:(CGFloat)dmlOriginY superFrame:(CGRect)superFrame style:(ZJZDMLStyle)style;

/* 创建自定义类型弹幕 */
+ (instancetype)dmInitDMLTitle:(NSString *)title content:(NSString *)content dmlOriginY:(CGFloat)dmlOriginY superFrame:(CGRect)superFrame style:(ZJZDMLStyle)style;

/* 创建自定义类型弹幕(属性字符串) */
+ (instancetype)dmInitDMLTitle:(NSString *)title attriContent:(NSAttributedString *)attriContent dmlOriginY:(CGFloat)dmlOriginY superFrame:(CGRect)superFrame style:(ZJZDMLStyle)style;

/* 开始弹幕动画 */
- (void)dmBeginAnimation;

@end
