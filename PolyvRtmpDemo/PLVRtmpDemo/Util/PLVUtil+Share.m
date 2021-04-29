//
//  PLVUtil+Share.m
//  PLVLiveStreamer
//
//  Created by LinBq on 2017/6/12.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVUtil+Share.h"

@implementation PLVUtil (Share)

#ifdef INCLUDE_UMSDK
/// 分享至第三方平台 v1.1
+ (void)shareToPlatform:(UMSocialPlatformType)platformType title:(NSString *)title thumImage:(id)thumImage webpageUrl:(NSString *)webpageUrl sender:(UIButton *)sender target:(id)target {
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    switch (platformType) {
        case UMSocialPlatformType_QQ:
        case UMSocialPlatformType_WechatSession: {
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:@"正在直播" thumImage:thumImage];
            shareObject.webpageUrl = webpageUrl;
            messageObject.shareObject = shareObject;
        } break;
        case UMSocialPlatformType_WechatTimeLine: {
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:[NSString stringWithFormat:@"%@，正在直播！",title] descr:nil thumImage:thumImage];
            shareObject.webpageUrl = webpageUrl;
            messageObject.shareObject = shareObject;
        } break;
        case UMSocialPlatformType_Sina: {
            messageObject.text = [NSString stringWithFormat:@"%@，正在直播！观看链接：%@", title, webpageUrl];
        } break;
        default:
            break;
    }
    
    __weak typeof(target)weakTarget = target;
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:weakTarget completion:^(id data, NSError *error) {
        if (error) {
            sender.selected = NO;
            NSString *message = [NSString new];
            if (error.code==2008) {
                message = @"未安装该应用";
            }else {
                message = @"分享失败";
            }
            [PLVUtil alertInfo:message target:weakTarget];
            
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}
#endif

@end
