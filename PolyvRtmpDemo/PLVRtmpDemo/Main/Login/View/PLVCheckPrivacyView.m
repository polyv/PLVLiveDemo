//
//  PLVCheckPrivacyView.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "PLVCheckPrivacyView.h"

#define HEIGHT self.bounds.size.height
#define WIDTH self.bounds.size.width

static NSString * const kUserDefaultAgreeUserProtocol = @"UserDefaultAgreeUserProtocol";
static NSString * const PLV_PrivacyPolicy = @"https://s2.videocc.net/app-simple-pages/privacy-policy/index.html";
static NSString * const PLV_UserProtocol = @"https://s2.videocc.net/app-simple-pages/user-agreement/index.html";

@interface PLVCheckPrivacyView ()<UITextViewDelegate>

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation PLVCheckPrivacyView

#pragma mark - Life Cycle

- (instancetype)initWithCoder:(NSCoder *)decoder{
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Private

- (void)commonInit{
    self.backgroundColor = [UIColor clearColor];
    
    self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkButton setImage:[UIImage imageNamed:@"plv_checkbox_off"] forState:UIControlStateNormal];
    [self.checkButton setImage:[UIImage imageNamed:@"plv_checkbox_on"] forState:UIControlStateSelected];
    [self.checkButton addTarget:self action:@selector(checkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.checkButton];
    
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.delegate = self;
    [self addSubview:self.textView];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    UIColor *normalColor = [UIColor whiteColor];
    
    NSDictionary *normalAttributes = @{NSFontAttributeName:font,
                                          NSForegroundColorAttributeName:normalColor};
    
    NSString *string = @"已阅读并同意《隐私政策》和《使用协议》";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttributes:normalAttributes range:NSMakeRange(0, string.length)];
    [attributedString addAttribute:NSLinkAttributeName value:PLV_PrivacyPolicy range:NSMakeRange(6, 6)];
    [attributedString addAttribute:NSLinkAttributeName value:PLV_UserProtocol range:NSMakeRange(13, 6)];
    self.textView.linkTextAttributes = normalAttributes;
    self.textView.attributedText = [attributedString copy];
    
    self.checkButton.selected = [PLVCheckPrivacyView isPrivacyAgreed];
}

- (void)layoutSubviews{
    self.checkButton.frame = CGRectMake(0, 0, 20, 20);
    CGFloat textLabelX = HEIGHT + 10;
    self.textView.frame = CGRectMake(HEIGHT + 10, 2, WIDTH - textLabelX, 16);
}

#pragma mark - Action

- (void)checkButtonAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (self.didCheckBox) {
        self.didCheckBox(btn.selected);
    }
}

#pragma mark - Public

+ (BOOL)isPrivacyAgreed {
    NSNumber *agree = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultAgreeUserProtocol];
    return (agree && [agree integerValue] == 1);
}

+ (void)savePrivacyAgreed {
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:kUserDefaultAgreeUserProtocol];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (self.didTapPrivacy) {
        self.didTapPrivacy(URL.absoluteString);
    }
    return NO;
}

@end
