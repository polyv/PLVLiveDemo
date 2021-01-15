//
//  PLVUtil.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "PLVUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <AVFoundation/AVFoundation.h>
#import <PolyvFoundationSDK/PLVProgressHUD.h>

//PLVColorComponent PLVColorComponentMake(UInt32 hex, CGFloat alpha){
//    PLVColorComponent com = {
//        ((hex >> 16) & 0xFF)/255.0,
//        ((hex >> 8) & 0xFF)/255.0,
//        (hex & 0xFF)/255.0,
//        alpha
//    };
//    return com;
//}
//
//PLVColorComponent PLVColorComponentWithHex(UInt32 hex){
//    return PLVColorComponentMake(hex, 1.0);
//}

@implementation PLVUtil


/// md5加密传入参数
+ (NSString *)md5HexDigest:(NSString *)input{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

/// 弹出错误信息
+ (void)alertErrorWithTitle:(NSString *)title reason:(NSString *)reason target:(id)target{
    NSString *msg = [NSString stringWithFormat:@"错误：%@", reason];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    __weak typeof(target) weakTarget = target;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakTarget presentViewController:alert animated:YES completion:nil];
    });
}

/// 弹出信息
+ (void)alertInfo:(NSString *)info target:(id)target{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:sure];
    __weak typeof(target) weakTarget = target;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakTarget presentViewController:alertController animated:YES completion:nil];
    });
}

/// 弹出信息
+ (void)alertInfo:(NSString *)info target:(id)target completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:sure];
    __weak typeof(target) weakTarget = target;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakTarget presentViewController:alertController animated:YES completion:nil];
    });
}

+ (void)alertInfoWithTitle:(NSString *)title info:(NSString *)info target:(id)target completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:sure];
    __weak typeof(target) weakTarget = target;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakTarget presentViewController:alertController animated:YES completion:^{}];
    });
}

/// 显示HUD信息
+ (void)showHUDViewWithMessage:(NSString *)message superView:(UIView *)superView {
    if (!message) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:superView animated:YES];
        [hud.bezelView setStyle:PLVProgressHUDBackgroundStyleBlur];
        hud.mode = PLVProgressHUDModeText;
        [hud setAnimationType:PLVProgressHUDAnimationZoomIn];
        hud.label.text = message;
        // 显示时间 1.5s
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [hud setHidden:YES];
        });
    });
}



//// test
//- (void)shareTextToSina
//{
//    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
//    messageObject.text = @"【直播活动名称】非常有价值的直播！快来看看吧！";
//
//    [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Sina messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
//        NSString *message = nil;
//        if (!error) {
//            message = [NSString stringWithFormat:@"分享成功"];
//        } else {
//            message = [NSString stringWithFormat:@"失败原因Code: %d\n",(int)error.code];
//
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"share"
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
//        [alert show];
//    }];
//}

#pragma mark - 请求权限
/// 请求视频访问
+ (void)requestAccessForVideoWithCompletionHandler:(void (^)(void))completionHandler{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    completionHandler();
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            completionHandler();
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            
            break;
        default:
            break;
    }
}

/// 请求音频访问
+ (void)requestAccessForAudio{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

+ (int)calculateTextLength:(NSString *)strTemp {
    int strlength = 0;
    char* p = (char*)[strTemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strTemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }
    return strlength;
}

@end

/// 时间字符串
NSString *stringWithTime(long time){
    if (time <= 0) return @"00:00";
    
    long second = time;
    long minute = second / 60;
    long hour = minute / 60;
    long day = hour / 24;
    
    //    if (second < 60)
    //        return [NSString stringWithFormat:@"%02d", second];
    
    second = second % 60;
    if (minute < 60) // 1小时以内
        return [NSString stringWithFormat:@"%02ld:%02ld", minute, second];
    
    minute = minute % 60;
    if (hour < 24) // 1天以内
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, minute, second];
    else{
        hour = hour % 24;
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld:%02ld", day, hour, minute, second];
    }
}

/// 中文时间字符串
/*NSString *stringWithTimeZh(long time){
    if (time <= 0) return @"0秒";
    
    long second = time;
    long minute = second / 60;
    long hour = minute / 60;
    long day = hour / 24;
    
    if (second < 60)
        return [NSString stringWithFormat:@"%ld秒", second];
    
    second = second % 60;
    if (minute < 60) // 1小时以内
        return [NSString stringWithFormat:@"%ld分钟%ld秒", minute, second];
    
    minute = minute % 60;
    if (hour < 24) // 1天以内
        return [NSString stringWithFormat:@"%ld小时%ld分钟%ld秒", hour, minute, second];
    else{
        hour = hour % 24;
        return [NSString stringWithFormat:@"%ld天%ld小时%ld分钟%ld秒", day, hour, minute, second];
    }
}*/

NSString *stringWithTimeZh(long time){
    if (time <= 0) return @"0 小时 0 分钟 0 秒";
    
    long second = time;
    long minute = second / 60;
    long hour = minute / 60;
    
    if (second < 60)
        return [NSString stringWithFormat:@"0 小时 0 分钟 %ld 秒", second];
    
    second = second % 60;
    if (minute < 60) // 1小时以内
        return [NSString stringWithFormat:@"0 小时 %ld 分钟 %ld 秒", minute, second];
    
    minute = minute % 60;
    return [NSString stringWithFormat:@"%ld 小时 %ld 分钟 %ld 秒", hour, minute, second];
}


NSAttributedString *attributedStringWithTimeZh(long time) {
    NSString *timerStr = stringWithTimeZh(time);
    NSMutableAttributedString *mAttributedStr = [[NSMutableAttributedString alloc] initWithString:timerStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24.0]}];
    
    NSDictionary *unitAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16.0]};
    [mAttributedStr setAttributes:unitAttributes range:[timerStr rangeOfString:@"秒"]];
    [mAttributedStr setAttributes:unitAttributes range:[timerStr rangeOfString:@"分钟"]];
    [mAttributedStr setAttributes:unitAttributes range:[timerStr rangeOfString:@"小时"]];
    
    return mAttributedStr;
}

/// 网速字符串
NSString *stringWithSpeed(CGFloat speed){
    if (speed <= 0) return @"0 KB/s";
    if (speed >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", speed / 1000 / 1000];
    } else if (speed >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", speed / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)speed];
    }
}

