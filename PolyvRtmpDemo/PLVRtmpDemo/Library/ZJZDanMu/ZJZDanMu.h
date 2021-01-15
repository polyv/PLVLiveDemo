//
//  ZJZDanMu.h
//  DanMu
//
//  Created by 郑家柱 on 16/6/17.
//  Copyright © 2016年 Jiangsu Houxue Network Information Technology Limited By Share Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJZDanMuLabel.h"

@interface ZJZDanMu : UIView

/* 插入弹幕 */
- (void)insertDML:(NSString *)content;

/* 插入弹幕(随机类型) */
- (void)insertDMLTitle:(NSString *)title content:(NSString *)content;

/* 插入指定类型的弹幕 */
- (void)insertDMLTitle:(NSString *)title content:(NSString *)content style:(ZJZDMLStyle)style;

/* 插入指定类型的弹幕(属性字符串)*/
- (void)insertDMLTitle:(NSString *)title attriContent:(NSAttributedString *)attriContent style:(ZJZDMLStyle)style;

/* 重置Frame */
- (void)resetFrame:(CGRect)frame;

@end
