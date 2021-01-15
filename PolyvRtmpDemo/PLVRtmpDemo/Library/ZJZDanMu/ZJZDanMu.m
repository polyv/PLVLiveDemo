//
//  ZJZDanMu.m
//  DanMu
//
//  Created by 郑家柱 on 16/6/17.
//  Copyright © 2016年 Jiangsu Houxue Network Information Technology Limited By Share Ltd. All rights reserved.
//

#import "ZJZDanMu.h"

@interface ZJZDanMu ()

@property (nonatomic, assign) NSUInteger            rollChannel;        // 弹幕航道数
@property (nonatomic, strong) NSMutableDictionary   *rollChannelDict;   // 滚动弹幕样式队列
@property (nonatomic, strong) NSMutableDictionary   *fadeChannelDict;   // 渐变弹幕样式队列
@property (nonatomic, assign) CGRect                currentFrame;       // 当前弹幕图层Frame

@end

@implementation ZJZDanMu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.currentFrame = frame;
        
        [self dmInitChannel];
        
    }
    return self;
}

/* 初始化航道信息 */
- (void)dmInitChannel
{
    // 计算航道
    self.rollChannel = floorf((self.currentFrame.size.height - 10)/KZJZDMHEIGHT);
    
    // 初始化航道队列
    self.rollChannelDict = [NSMutableDictionary dictionaryWithCapacity:self.rollChannel];
    self.fadeChannelDict = [NSMutableDictionary dictionaryWithCapacity:self.rollChannel];
    
    for (int i = 0; i < self.rollChannel; i ++) {
        NSArray *array = [NSArray array];
        [self.rollChannelDict setObject:array forKey:@(i)];
        [self.fadeChannelDict setObject:array forKey:@(i)];
    }
}

/* 插入弹幕 */
- (void)insertDML:(NSString *)content
{
    ZJZDMLStyle dmlStyle = ZJZDMLFade;
    
    // 计算最佳航道
    NSUInteger bestChannel;
    if (arc4random_uniform(4)) {    // 控制弹幕类型出现的概率
        dmlStyle = ZJZDMLRoll;
        bestChannel = [self dmBestRollChannel];
    } else {
        bestChannel = [self dmBestFadeChannel];
    }
    
    // 初始化弹幕
    ZJZDanMuLabel *zjzDML = [ZJZDanMuLabel dmInitDML:content dmlOriginY:bestChannel * KZJZDMHEIGHT + 5 superFrame:self.currentFrame style:dmlStyle];
    [self addSubview:zjzDML];
    
    [zjzDML dmBeginAnimation];
    
    // 插入弹幕队列
    [self insertDMQueue:zjzDML channel:bestChannel];
}

/* 插入弹幕(自定义类型) */
- (void)insertDMLTitle:(NSString *)title content:(NSString *)content {
    
    ZJZDMLStyle dmlStyle = ZJZDMLFade;
    if (arc4random_uniform(4)) {    // 控制弹幕类型出现的概率
        dmlStyle = ZJZDMLRoll;
    }
    
    [self insertDMLTitle:title content:content style:dmlStyle];
}

- (void)insertDMLTitle:(NSString *)title content:(NSString *)content style:(ZJZDMLStyle)style {
    // 计算最佳航道
    NSUInteger bestChannel;
    if (style==ZJZDMLRoll) {
        bestChannel = [self dmBestRollChannel];
    }else {
        bestChannel = [self dmBestFadeChannel];
    }
    
    ZJZDanMuLabel *zjzDML;
    // 初始化弹幕
    if (title) {
        zjzDML = [ZJZDanMuLabel dmInitDMLTitle:title content:content dmlOriginY:bestChannel * KZJZDMHEIGHT + 5 superFrame:self.currentFrame style:style];
    }else {
        zjzDML = [ZJZDanMuLabel dmInitDML:content dmlOriginY:bestChannel * KZJZDMHEIGHT + 5 superFrame:self.currentFrame style:style];
    }
    
    [self addSubview:zjzDML];
    
    [zjzDML dmBeginAnimation];
    
    // 插入弹幕队列
    [self insertDMQueue:zjzDML channel:bestChannel];
}

- (void)insertDMLTitle:(NSString *)title attriContent:(NSAttributedString *)attriContent style:(ZJZDMLStyle)style {
    // 计算最佳航道
    NSUInteger bestChannel;
    if (style==ZJZDMLRoll) {
        bestChannel = [self dmBestRollChannel];
    }else {
        bestChannel = [self dmBestFadeChannel];
    }
    
    ZJZDanMuLabel *zjzDML;
    if (title) {
        zjzDML = [ZJZDanMuLabel dmInitDMLTitle:title attriContent:attriContent dmlOriginY:bestChannel * KZJZDMHEIGHT + 5 superFrame:self.currentFrame style:style];
        [self addSubview:zjzDML];
        
        [zjzDML dmBeginAnimation];
        
        // 插入弹幕队列
        [self insertDMQueue:zjzDML channel:bestChannel];
    } else {
    }
}

/* 加入弹幕队列 */
- (void)insertDMQueue:(ZJZDanMuLabel *)dml channel:(NSUInteger)channel
{
    if (dml.zjzDMLStyle == ZJZDMLRoll) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self.rollChannelDict objectForKey:@(channel)]];
        
        // 清除当前弹幕航道的所有信息后再加入最新的弹幕
        [array removeAllObjects];
        [array addObject:dml];
        [self.rollChannelDict setObject:array forKey:@(channel)];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self.fadeChannelDict objectForKey:@(channel)]];
        
        // 清除当前弹幕航道的所有信息后再加入最新的弹幕
        [array removeAllObjects];
        [array addObject:dml];
        [self.fadeChannelDict setObject:array forKey:@(channel)];
    }
    
}

/* 计算滚动最佳航道 */
- (NSUInteger)dmBestRollChannel
{
    for (NSUInteger i = 0; i < self.rollChannel; i ++) {
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self.rollChannelDict objectForKey:@(i)]];
        ZJZDanMuLabel *dml = [array lastObject];
        
        if (dml) {
            
            NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:dml.startTime];
            
            if (duration * dml.dmlSpeed >= dml.frame.size.width + 5 + arc4random_uniform(40)) {
                
                return i;
            }
            
        } else {
            
            return i;
            
        }
        
    }
    
    // 如果航道铺满整屏，则随机选择航道直接显示
    return arc4random_uniform((u_int32_t)self.rollChannel);
}

/* 计算浮动最佳航道 */
- (NSUInteger)dmBestFadeChannel
{
    for (NSUInteger i = 0; i < self.rollChannel; i ++) {
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self.fadeChannelDict objectForKey:@(i)]];
        ZJZDanMuLabel *dml = [array lastObject];
        
        if (dml) {
            
            NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:dml.startTime];
            
            if (duration >= dml.dmlFadeTime + 0.2f) {
                
                return i;
            }
            
        } else {
            
            return i;
            
        }
        
    }
    
    // 如果航道铺满整屏，则随机选择航道直接显示
    return arc4random_uniform((u_int32_t)self.rollChannel);
}

/* 重置Frame */
- (void)resetFrame:(CGRect)frame
{
    self.currentFrame = frame;
    
    [self dmInitChannel];
}

@end
