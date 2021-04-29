//
//  PLVLoginTextField.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "PLVLoginTextField.h"

@interface PLVLoginTextField ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation PLVLoginTextField

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

- (void)commonInit{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 4.0;
    // Xcode 11 上 iOS 13.0 上会崩溃，如需要可使用 attributedPlaceholder替代
    // Terminating app due to uncaught exception 'NSGenericException', reason: 'Access to UITextField's _placeholderLabel ivar is prohibited. This is an application bug'
    //[self setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.pasteNumberOnly = NO;
}

#pragma mark - rewrite

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 11.0;
    return iconRect;
}

//控制文本所在的的位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 40.0, 0 );
}

//控制编辑文本时所在的位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 40.0, 0 );
}

#pragma mark - propety

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:18];
    }
    return _nameLabel;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    if (!color) {
        return;
    }
    self.layer.borderColor = color.CGColor;
    self.nameLabel.textColor = self.textColor = color;
    //[self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}

#pragma mark - UIResponder

- (void)paste:(id)sender {
    UIPasteboard *pasteboard =[UIPasteboard generalPasteboard];
    if ([pasteboard hasStrings]) {
        NSString *pastedString = pasteboard.string;
        if (self.pasteNumberOnly) {
            if ([self isIntegerString:pastedString]) {
                [self insertText:pastedString];
            }
        } else {
            [self insertText:pastedString];
        }
    }
}

- (BOOL)isIntegerString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSInteger val;
    return [scanner scanInteger:&val] && [scanner isAtEnd];
}

/// disable paste
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    if (action == @selector(paste:)) {  // disable paste
//        return NO;
//    }
//    return [super canPerformAction:action withSender:sender];
//}

@end
