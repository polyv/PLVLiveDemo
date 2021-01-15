//
//  UIColor+PLV.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "UIColor+PLV.h"

@implementation UIColor (PLV)

/// 获取随机色
+ (instancetype)randomColor{
    return [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
}

/// RGB颜色
+ (instancetype)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

/// 16进制不透明颜色（0x00FF00）
+ (instancetype)colorWithHex:(UInt32)hex{
    return [UIColor colorWithHex:hex alpha:1.0];
}

/// 16进制透明色（0x00FF00）
+ (instancetype)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((hex >> 16) & 0xFF)/255.0
                           green:((hex >> 8) & 0xFF)/255.0
                            blue:(hex & 0xFF)/255.0
                           alpha:alpha];
}

+ (instancetype)colorWithString:(NSString *)hexString alpha:(CGFloat)alpha {
    //NSLog(@"hexString = %@, length = %zd", hexString, hexString.length);
    hexString = hexString.lowercaseString;
    hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!hexString.length) {
        return nil;
    }
    
    NSString *colorPrefix0 = @"0x";
    NSString *colorPrefix1 = @"#";
    if ([hexString hasPrefix:colorPrefix0]) {
        
    } else if ([hexString hasPrefix:colorPrefix1]) {
        //hexString = [hexString stringByReplacingOccurrencesOfString:colorPrefix1 withString:colorPrefix0];
        hexString = [hexString stringByReplacingOccurrencesOfString:colorPrefix1 withString:@""];
    } else {
        //hexString = [colorPrefix0 stringByAppendingString:hexString];
    }
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    UInt32 hex;
    sscanf(hexChar, "%x", &hex);
    //NSLog(@"hexString = %@, length = %zd", hexString, hexString.length);
    //NSLog(@"color hex = %zd", hex);
    return [self colorWithHex:hex alpha:alpha];
}

/**
 *  生成渐变色
 *
 *  @param c1     头
 *  @param c2     尾
 *  @param height 范围
 *
 *  @return 渐变色
 */
+ (instancetype)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height{
    CGSize size = CGSizeMake(190, height); // 这个宽度无所谓，只要不是0就行
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    NSArray* colors = [NSArray arrayWithObjects:(id)c1.CGColor, (id)c2.CGColor, nil];
    // 创建渐变色
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, NULL);
    // 填充到画布
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 回收内存
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:image];
}

@end
