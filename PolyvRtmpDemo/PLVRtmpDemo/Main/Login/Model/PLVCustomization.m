//
//  PLVCustomization.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "PLVCustomization.h"
#import "UIColor+PLV.h"

static NSString * const CustomColorFile = @"ColorCustom";
static NSString * const ColorLoginButtonKey = @"login_loginButton";
static NSString * const ColorLoginButtonTextKey = @"login_loginButton_text";
static NSString * const ColorLoginInput = @"login_input";
static NSString * const ColorThemeKey = @"theme";
static NSString * const ColorSettingBar = @"setting_navigationBar";
static NSString * const ColorSettingTableTint = @"setting_tableTint";
static NSString * const ColorSettingStartButton = @"setting_startButton";

@implementation PLVCustomization

+ (instancetype)sharedCustomization {
    static PLVCustomization *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *colorDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CustomColorFile ofType:@"plist"]];
        //NSLog(@"color = %@", colorDict);
        _loginButtonColor = [UIColor colorWithString:colorDict[ColorLoginButtonKey] alpha:1];
        _loginButtonTextColor = [UIColor colorWithString:colorDict[ColorLoginButtonTextKey] alpha:1];
        _loginInputColor = [UIColor colorWithString:colorDict[ColorLoginInput] alpha:1];
        
        _themeColor = [UIColor colorWithString:colorDict[ColorThemeKey] alpha:1];
        _settingBarColor = [UIColor colorWithString:colorDict[ColorSettingBar] alpha:1];
        _settingTableTintColor = [UIColor colorWithString:colorDict[ColorSettingTableTint] alpha:1];
        _settingStartButtonColor = [UIColor colorWithString:colorDict[ColorSettingStartButton] alpha:1];
    }
    return self;
}


//#pragma mark - 颜色定制
//+ (UIColor *)loginButtonColor {
//
//}
//
//+ (UIColor *)loginButtonTextColor {
//
//}
//
//+ (UIColor *)themeColor {
//
//}
//
//+ (UIColor *)settingBarColor {
//
//}
//
//+ (UIColor *)settingTableTintColor {
//
//}
//
//+ (UIColor *)settingStartButtonColor {
//
//}

@end
