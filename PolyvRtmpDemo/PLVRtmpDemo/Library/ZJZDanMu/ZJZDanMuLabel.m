//
//  ZJZDanMuLabel.m
//  DanMu
//
//  Created by 郑家柱 on 16/6/17.
//  Copyright © 2016年 Jiangsu Houxue Network Information Technology Limited By Share Ltd. All rights reserved.
//

#import "ZJZDanMuLabel.h"

@interface ZJZDanMuLabel ()

@property (nonatomic, assign) CGRect            superFrame;     // 弹幕层Frame

@property (nonatomic, assign) CGFloat rollDuration;

@end

@implementation ZJZDanMuLabel

/* 创建 */
+ (instancetype)dmInitDML:(NSString *)content dmlOriginY:(CGFloat)dmlOriginY superFrame:(CGRect)superFrame style:(ZJZDMLStyle)style
{
    ZJZDanMuLabel *dmLabel = [[ZJZDanMuLabel alloc] init];
    dmLabel.superFrame = superFrame;
    dmLabel.zjzDMLStyle = style;
    
    [dmLabel dmInitWithContent:content dmlOriginY:dmlOriginY];
    
    return dmLabel;
}

/* 初始化 */
- (void)dmInitWithContent:(NSString *)content dmlOriginY:(CGFloat)dmlOriginY
{
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:14];
    self.text = content;
    self.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.layer.cornerRadius = 6.0;
    self.layer.masksToBounds = YES;
    
    CGSize size = [self countString:content size:CGSizeMake(MAXFLOAT, KZJZDMHEIGHT) font:self.font];
    
    // 当文字显示大于一屏时，自动调整为滚动显示
    if (size.width > self.superFrame.size.width - 90) {
        self.zjzDMLStyle = ZJZDMLRoll;
    }
    
    if (self.zjzDMLStyle == ZJZDMLRoll) {
        self.frame = CGRectMake(self.superFrame.size.width, dmlOriginY, size.width, size.height);
    } else {
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.center = CGPointMake(self.superFrame.size.width/2 - 30 + arc4random_uniform(60), dmlOriginY + size.height/2);
        self.alpha = 0.0f;
    }
}

#pragma mark - polyv danmu

+ (instancetype)dmInitDMLTitle:(NSString *)title content:(NSString *)content dmlOriginY:(CGFloat)dmlOriginY superFrame:(CGRect)superFrame style:(ZJZDMLStyle)style {
    ZJZDanMuLabel *dmLabel = [[ZJZDanMuLabel alloc] init];
    dmLabel.superFrame = superFrame;
    dmLabel.zjzDMLStyle = style;
    
    [dmLabel dmInitWithTitle:title content:content dmlOriginY:dmlOriginY];
    
    return dmLabel;
}

- (void)dmInitWithTitle:(NSString *)title content:(NSString *)content dmlOriginY:(CGFloat)dmlOriginY
{
    if (!title || !content || [title isKindOfClass:[NSNull class]] || [content isKindOfClass:[NSNull class]]) return;
    
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:14];
    self.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.layer.cornerRadius = 6.0;
    self.layer.masksToBounds = YES;
    
    @try {
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[title stringByAppendingString:content]];
        UIColor *titleColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0];
        // add a placeholder that is a clear color word.
        [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"I" attributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}]];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:titleColor range:NSMakeRange(0, title.length)];
        
        self.attributedText = attributedStr;
    } @catch (NSException *exception) {
        NSLog(@"弹幕属性字符串设置失败：%@",exception.reason);
        self.text = [NSString stringWithFormat:@"%@：%@",title,content];
    }

    CGSize size = [self countString:[title stringByAppendingString:content] size:CGSizeMake(MAXFLOAT, KZJZDMHEIGHT) font:self.font];
    
    // 当文字显示大于一屏时，自动调整为滚动显示
    if (size.width > self.superFrame.size.width - 90) {
        self.zjzDMLStyle = ZJZDMLRoll;
    }
    
    if (self.zjzDMLStyle == ZJZDMLRoll) {
        self.frame = CGRectMake(self.superFrame.size.width, dmlOriginY, size.width, size.height);
    } else {
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.center = CGPointMake(self.superFrame.size.width/2 - 30 + arc4random_uniform(60), dmlOriginY + size.height/2);
        self.alpha = 0.0f;
    }
}

+ (instancetype)dmInitDMLTitle:(NSString *)title attriContent:(NSAttributedString *)attriContent dmlOriginY:(CGFloat)dmlOriginY superFrame:(CGRect)superFrame style:(ZJZDMLStyle)style {
    ZJZDanMuLabel *dmLabel = [[ZJZDanMuLabel alloc] init];
    dmLabel.superFrame = superFrame;
    dmLabel.zjzDMLStyle = style;
    
    [dmLabel dmInitWithTitle:title attriContent:attriContent dmlOriginY:dmlOriginY];
    
    return dmLabel;
}

- (void)dmInitWithTitle:(NSString *)title attriContent:(NSAttributedString *)attriContent dmlOriginY:(CGFloat)dmlOriginY
{
    if (!title || !attriContent || [title isKindOfClass:[NSNull class]] || [attriContent isKindOfClass:[NSNull class]]) return;
    
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:14];
    self.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.layer.cornerRadius = 6.0;
    self.layer.masksToBounds = YES;
    
    @try {
        UIColor *titleColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:titleColor,NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        // add a placeholder that is a clear color word.
        [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"I" attributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}]];
        [attributedStr appendAttributedString:attriContent];
        
        self.attributedText = attributedStr;
        self.rollDuration = attributedStr.length < 100 ? KZJZDMLROLLANIMATION : KZJZDMLROLLANIMATION*2;
    } @catch (NSException *exception) {
        NSLog(@"弹幕属性字符串设置失败：%@",exception.reason);
        self.text = [NSString stringWithFormat:@"%@：%@",title,attriContent];
    }
    
    CGSize size = [self autoCalculateSize:CGSizeMake(MAXFLOAT, KZJZDMHEIGHT) attributedContent:self.attributedText];
    
    // 当文字显示大于一屏时，自动调整为滚动显示
    if (size.width > self.superFrame.size.width - 90) {
        self.zjzDMLStyle = ZJZDMLRoll;
    }
    
    if (self.zjzDMLStyle == ZJZDMLRoll) {
        self.frame = CGRectMake(self.superFrame.size.width, dmlOriginY, size.width, size.height);
    } else {
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.center = CGPointMake(self.superFrame.size.width/2 - 30 + arc4random_uniform(60), dmlOriginY + size.height/2);
        self.alpha = 0.0f;
    }
}


/* 开始弹幕动画 */
- (void)dmBeginAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.zjzDMLState = ZJZDMLStateRunning;
        self.startTime = [NSDate date];
        
        if (self.zjzDMLStyle == ZJZDMLRoll) {
            [UIView animateWithDuration:self.rollDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                CGRect frame = self.frame;
                frame.origin.x = - self.frame.size.width;
                self.frame = frame;
            } completion:^(BOOL finished) {
                if (finished) {
                    [self removeDanmu];
                }
            }];
        } else {
            [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                self.alpha = 1.0f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1.0f delay:KZJZDMLFADEANIMATION options:UIViewAnimationOptionCurveLinear animations:^{
                    self.alpha = 0.2f;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self removeDanmu];
                    }
                }];
            }];
        }
    });
}

/* 移除弹幕 */
- (void)removeDanmu {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.zjzDMLState = ZJZDMLStateFinish;
        [self.layer removeAllAnimations];
        [self removeFromSuperview];
    });
}

/** 动态计算文本高度 **/
- (CGSize)countString:(NSString *)content size:(CGSize)size font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize expectedLabelSize = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return CGSizeMake(ceil(expectedLabelSize.width) + 10, ceil(expectedLabelSize.height) + 10);
}

- (CGSize)autoCalculateSize:(CGSize)size attributedContent:(NSAttributedString *)attributedContent {
    CGRect rect = [attributedContent boundingRectWithSize:size
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                  context:nil];
    return CGSizeMake(ceil(rect.size.width) + 20, ceil(rect.size.height) + 10);
}

#pragma mark - GET
- (CGFloat)dmlSpeed
{
    return (self.frame.size.width + self.superFrame.size.width)/self.rollDuration;
}

- (CGFloat)dmlFadeTime
{
    return 1.0f + 1.0f + KZJZDMLFADEANIMATION;
}

@end
