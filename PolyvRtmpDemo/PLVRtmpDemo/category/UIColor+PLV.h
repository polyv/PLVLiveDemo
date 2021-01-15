//
//  UIColor+PLV.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (PLV)

/// 获取随机色
+ (instancetype)randomColor;

/// RGB颜色
+ (instancetype)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b;

/// 16进制不透明颜色（0x00FF00）
+ (instancetype)colorWithHex:(UInt32)hex;

/// 16进制透明色（0x00FF00）
+ (instancetype)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha;

/// 16进制透明色（0x00FF00）
+ (instancetype)colorWithString:(NSString *)hexString alpha:(CGFloat)alpha;

/**
 *  生成渐变色
 *
 *  @param c1     头
 *  @param c2     尾
 *  @param height 范围
 *
 *  @return 渐变色
 */
+ (instancetype)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height;

@end
