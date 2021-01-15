//
//  PLVViewer.h
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/8.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVViewer : NSObject

/// userId
@property (nonatomic, copy) NSString *userId;
/// 频道号
@property (nonatomic, copy) NSString *roomId;
/// 昵称
@property (nonatomic, copy) NSString *nick;
/// 头像
@property (nonatomic, copy) NSString *pic;
/// uid
@property (nonatomic, copy) NSString *uid;
/// clientIp
@property (nonatomic, copy) NSString *clientIp;

/// 同类比较
- (BOOL)isEqualToPLVViewer:(PLVViewer *)viewer;
@end
