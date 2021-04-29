//
//  PLVLoginTextField.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVLoginTextField : UITextField

@property (nonatomic, strong) UIColor *color;

/// default is NO.
@property (nonatomic, assign) BOOL pasteNumberOnly;

@end

NS_ASSUME_NONNULL_END
