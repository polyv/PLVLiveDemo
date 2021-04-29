//
//  PLVCheckPrivacyView.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVCheckPrivacyView : UIView

@property (nonatomic, copy) void (^didCheckBox)(BOOL checked);

@property (nonatomic, copy) void (^didTapPrivacy)(NSString *urlString);

+ (BOOL)isPrivacyAgreed;

+ (void)savePrivacyAgreed;

@end

NS_ASSUME_NONNULL_END
