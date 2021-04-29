//
//  PLVCheckBox.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/11/30.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "PLVCheckBox.h"

#define HEIGHT self.bounds.size.height
#define WIDTH self.bounds.size.width

@interface PLVCheckBox ()

@property (nonatomic, strong) UIImageView *checkBox;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation PLVCheckBox

#pragma mark - property

- (void)setText:(NSString *)text{
    _text = text;
    self.textLabel.text = _text;
}

- (UIImage *)offImage{
    return [[UIImage imageNamed:@"plv_checkbox_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIImage *)onImage{
    return [[UIImage imageNamed:@"plv_checkbox_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.checkBox.image = self.isSelected ? self.onImage : self.offImage;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.textLabel.textColor = self.checkBox.tintColor = tintColor;
}

#pragma mark - init

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
    self.tintColor = [UIColor whiteColor];
    self.checkBox = [[UIImageView alloc] initWithImage:self.offImage];
    self.checkBox.tintColor = self.tintColor;
    [self addSubview:self.checkBox];
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.text = self.text;
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.textColor = self.tintColor;
    [self addSubview:self.textLabel];
}

- (void)layoutSubviews{
    self.checkBox.frame = CGRectMake(0, 0, HEIGHT, HEIGHT);
    CGFloat textLabelX = HEIGHT + 10;
    self.textLabel.frame = CGRectMake(textLabelX, 0, WIDTH - textLabelX, HEIGHT);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.selected = !self.isSelected;
    self.checkBox.image = self.isSelected ? self.onImage : self.offImage;
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
