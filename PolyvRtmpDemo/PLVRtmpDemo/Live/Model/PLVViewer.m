//
//  PLVViewer.m
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/8.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVViewer.h"

@implementation PLVViewer

- (NSString *)pic{
    if (!_pic) return @"https://live.polyv.cn/assets/wimages/missing_face.png";    // 默认图标
    
    /* 后台返回图片处理*/
    if ([_pic isKindOfClass:[NSNull class]])                // 处理null地址类型
    {
        return @"https://live.polyv.cn/assets/wimages/missing_face.png";           // 默认图标
    }
    else if ([_pic hasPrefix:@"http"])                      // HTTP强转HTTPS(包括微信头像和"live.polyv.cn"域名)
    {
        return [_pic stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
    }
    else if ([_pic hasPrefix:@"//"])                        // 处理"//"类型开头的地址
    {
        return [NSString stringWithFormat:@"https:%@", _pic];
    }
    else {
        return _pic;
    }
    //    // 后台返回图片处理
    //    if ([_pic hasPrefix:@"//"]) {
    //        _pic = [NSString stringWithFormat:@"https:%@", _pic];
    //    }
    //    // 微信头像处理
    //    if ([_pic containsString:@"http://wx.qlogo.cn"]) {
    //        _pic = [_pic stringByReplacingOccurrencesOfString:@"http://wx.qlogo.cn" withString:@"https://wx.qlogo.cn"];
    //    }
}

- (NSString *)description{
    NSString *desc = [NSString stringWithFormat:@"userId = %@; roomId = %@; nick = %@; pic = %@; uid = %@; clientIp = %@",
                      _userId, _roomId, _nick, _pic, _uid, _clientIp];
    return desc;
}


#pragma mark - equality
/// 同类比较，自定义
- (BOOL)isEqualToPLVViewer:(PLVViewer *)viewer{
    if (!viewer) return NO;
    BOOL uidEqual = (!self.uid && !viewer.uid) || [self.uid isEqualToString:viewer.uid];
    //BOOL useridEqual = (!self.userId && !viewer.userId) || [self.userId isEqualToString:viewer.userId];
    return uidEqual;
}

- (BOOL)isEqual:(id)object{
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    return [self isEqualToPLVViewer:object];
}
- (NSUInteger)hash{
    return [self.uid hash] ^ [self.userId hash];
}
@end
