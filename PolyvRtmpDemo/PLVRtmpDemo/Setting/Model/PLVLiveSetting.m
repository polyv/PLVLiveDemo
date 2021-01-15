//
//  PLVLiveSetting.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2021/1/4.
//  Copyright © 2021 easefun. All rights reserved.
//

#import "PLVLiveSetting.h"
#import <PLVLiveSDK/PLVNetworking.h>


@interface PLVLiveSetting ()

/// useId
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;

/// 仅音频
@property (nonatomic, assign) BOOL audioOnly;

/// 子账号列表（需做字典转对象）
@property (nonatomic, strong) NSArray *subAccounts;

/// 频道号（主账号id）
@property (nonatomic, copy) NSString *channelId;
/// 当前账号（主账号或子账号id）
@property (nonatomic, copy) NSString *accountId;
/// 流名（currentStream？？）
@property (nonatomic, copy) NSString *streamName;
/// url
@property (nonatomic, copy) NSString *urlRTMP;

/// isNgbEnabled
@property (nonatomic, assign) BOOL ngbEnable;
/// isUrlProtected
@property (nonatomic, assign) BOOL isUrlProtected;
/// ngbUrl
@property (nonatomic, copy) NSString *urlNgb;
/// bakUrl
@property (nonatomic, copy) NSString *bakUrl;
/// suffix
@property (nonatomic, copy) NSString *suffix;

/// suffixCamera

/// isLowLatency

/// role

/// 分房间开关
@property (nonatomic, assign) BOOL childRoomEnabled;
/// 分房间号数组
@property (nonatomic, assign) NSArray <NSString *>*roomIds;

@end

BOOL BOOLOfString(NSString *string){
    BOOL value = [@"Y" isEqualToString:string] || [@"y" isEqualToString:string];
    return value;
}

@implementation PLVLiveSetting

- (instancetype)initWithLoginResponse:(NSDictionary *)responseDict{
    if (self = [super init]) {
        _urlAvatar = responseDict[@"avatar"];
        _liveTitle = responseDict[@"nickname"];
        _subAccounts = responseDict[@"channelAccountList"];

        _channelId = responseDict[@"channelId"];
        _accountId = responseDict[@"accountId"];
        _streamName = responseDict[@"stream"];
        _urlRTMP = responseDict[@"url"];
        _urlPreview = responseDict[@"preview"];

        _userId = responseDict[@"useId"];
        _appId = responseDict[@"appId"];
        _appSecret = responseDict[@"appSecret"];

        _ngbEnable = BOOLOfString(responseDict[@"isNgbEnabled"]);
        _isUrlProtected = [responseDict[@"isUrlProtected"] boolValue];
        _childRoomEnabled = BOOLOfString(responseDict[@"childRoomEnabled"]);

        // 分房间数组
        NSString * roomIdsString = responseDict[@"roomIds"];
        if (roomIdsString && [roomIdsString isKindOfClass:NSString.class] && roomIdsString.length > 0) {
            _roomIds = [roomIdsString componentsSeparatedByString:@","];
        }

        _urlNgb = responseDict[@"ngbUrl"];
        _bakUrl = responseDict[@"bakUrl"];
        _suffix = responseDict[@"suffix"];

        _audioOnly = [@"Y" isEqualToString:responseDict[@"isOnlyAudio"]];

        _maxRate = (NSUInteger)[[NSString stringWithFormat:@"%@",responseDict[@"maxRate"]] integerValue];
        if (_maxRate == 0) {
            _maxRate = 1000;
        } else if (_maxRate < 600) {
            _maxRate = 600;
        }

        [self commonInit];
    }
    return self;
}

/// 其他初始化
- (void)commonInit{
    PLVChannel *channel = [PLVChannel sharedChannel];
    channel.channelId = self.channelId;
    channel.chatRoomId = self.chatRoomId;
    channel.accountId = self.accountId;
    channel.streamName = self.streamName;
    if (self.appId && self.appSecret) {
        channel.appId = self.appId;
        channel.appSecret = self.appSecret;
    }else {
        NSLog(@"Error: appId or appSecret be nil!");
    }

    NSMutableDictionary *mDict = [NSMutableDictionary new];
    for (NSDictionary *dict in self.subAccounts) {
        [mDict setObject:dict[@"accountName"] forKey:dict[@"accountId"]];
    }
    [PLVChannel sharedChannel].channelAccountList = mDict;
}

- (NSString *)chatRoomId{
    if (self.childRoomEnabled) {
        if (self.roomIds.count > 0) {
            return self.roomIds.firstObject;
        }
    }
    return self.channelId;
}

- (CGSize)videoSize {
    CGFloat width, height;
    switch (self.definition) {
        case PLVDefinitionStandard:{
            width = 360;
            height = 640;
        } break;
        case PLVDefinitionHigh:{
            width = 540;
            height = 960;
        } break;
        case PLVDefinitionUltra:{
            width = 720;
            height = 1280;
        } break;
        default:
            break;
    }
    if (self.landscapeEnable) {
        return CGSizeMake(height, width);
    }else{
        return CGSizeMake(width, height);
    }
}

- (NSURL *)rtmpURL{
    NSString *url = @"";
    if (self.ngbEnable){

    }else{
        url = [NSString stringWithFormat:@"%@%@", self.urlRTMP, self.streamName];
    }

//    if (self.protected) {
//        url = [NSString stringWithFormat:@"%@%@", url, self.suffix];
//    }

    NSLog(@"rtmp url = %@", url);

    NSURL *rtmpURL = [NSURL URLWithString:url];
    return rtmpURL;
}

- (void)requestUrlRtmpWithCompletionHandler:(void (^)(NSString *urlRTMP))completionHandler{
    if (self.ngbEnable) {
        [PLVNetworking requestUrlRtmpWithNgb:self.urlNgb stream:self.streamName completion:^(NSString *urlRTMP) {
            if (urlRTMP.length) {
                completionHandler(urlRTMP);
            } else {
                [PLVNetworking requestUrlRtmpWithNgb:self.bakUrl stream:self.streamName completion:^(NSString *urlRTMP) {
                    completionHandler(urlRTMP);
                } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
                    NSLog(@"requestUrlRtmpWithNgb failed: %ld, %@",errorCode,description);
                }];
            }
        } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
            NSLog(@"requestUrlRtmpWithNgb failed: %ld, %@",errorCode,description);
        }];
    }else if (self.isUrlProtected) {
        completionHandler([NSString stringWithFormat:@"%@%@%@",self.bakUrl,self.streamName,self.suffix]);
    }else {
        NSString *url = @"";
        url = [NSString stringWithFormat:@"%@%@", self.urlRTMP, self.streamName];
        completionHandler(url);
    }
}

- (NSString *)urlAvatar {
    // TODO: 可以简单判断是否为null后直接取参数值，无需处理。后台该字段已更新。提供https协议的完整URL
    @try {
        if (!_urlAvatar) return @"https://livestatic.polyv.net/assets/images/teacher.png";  // 讲师图标
        /* 后台返回图片处理*/
        if ([_urlAvatar isKindOfClass:[NSNull class]] || [_urlAvatar isEqualToString:@"null"]) // 处理null地址类型或输出为"null"
        {
            return @"https://livestatic.polyv.net/assets/images/teacher.png";   // 讲师图标
        }
        else if ([_urlAvatar hasPrefix:@"https://"])                 // HTTPS直接返回
        {
            return _urlAvatar;
        }
        else if ([_urlAvatar hasPrefix:@"http"])
        {
            if ([_urlAvatar containsString:@"static.live."]) {      // 处理四级HTTP地址域名
                return [_urlAvatar stringByReplacingOccurrencesOfString:@"http://static.live." withString:@"https://livestatic."];
            }else {
                return [_urlAvatar stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
            }
        }
        else if ([_urlAvatar hasPrefix:@"//"])                      // 处理"//"类型开头的地址
        {
            return [NSString stringWithFormat:@"https:%@", _urlAvatar];
        }
        else                                                        // 其他类型，如："/assets/wimages/pc_images/logo.png"类型地址和其他未知类型地址
        {
            return @"https://livestatic.polyv.net/assets/wimages/pc_images/logo.png";   // 红色默认图标
        }
    } @catch (NSException *exception) {
        NSLog(@"urlAvatar occur error: %@",exception.reason);
        return _urlAvatar;
    }
}

@end
