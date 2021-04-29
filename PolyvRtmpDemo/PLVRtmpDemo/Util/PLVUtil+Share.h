//
//  PLVUtil+Share.h
//  PLVLiveStreamer
//
//  Created by LinBq on 2017/6/12.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVUtil.h"

#if __has_include (<UMSocialCore/UMSocialCore.h>)
    #import <UMSocialCore/UMSocialCore.h>
    #define INCLUDE_UMSDK
#endif

@interface PLVUtil (Share)

#ifdef INCLUDE_UMSDK
/// 分享至第三方平台 v1.1
+ (void)shareToPlatform:(UMSocialPlatformType)platformType
                  title:(NSString *)title
              thumImage:(id)thumImage
             webpageUrl:(NSString *)webpageUrl
                 sender:(UIButton *)sender
                 target:(id)target;
#endif

@end
