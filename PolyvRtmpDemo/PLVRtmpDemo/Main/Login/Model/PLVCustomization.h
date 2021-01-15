//
//  PLVCustomization.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PLVCustomization : NSObject

@property (nonatomic, strong) UIColor *loginButtonColor;
@property (nonatomic, strong) UIColor *loginButtonTextColor;
@property (nonatomic, strong) UIColor *loginInputColor;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIColor *settingBarColor;
@property (nonatomic, strong) UIColor *settingTableTintColor;
@property (nonatomic, strong) UIColor *settingStartButtonColor;

+ (instancetype)sharedCustomization;

@end

