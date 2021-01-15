//
//  PLVChanelAvatarView.m
//  LiveStreamer
//
//  Created by LinBq on 16/10/12.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVChanelAvatarView.h"
#import "UIImageView+CornerRadius.h"
#import <Masonry/Masonry.h>

@interface PLVChanelAvatarView ()

@property (nonatomic, strong) UILabel *infoView;

@end

@implementation PLVChanelAvatarView

- (UIImageView *)avatarView{
	if (!_avatarView) {
		_avatarView = [[UIImageView alloc] initWithRoundingRectImageView];
		_avatarView.image = [UIImage imageNamed:@"plv_placeholder_avatar"];
	}
	return _avatarView;
}


- (void)setOnelineCount:(NSUInteger)onelineCount{
	_onelineCount = onelineCount;
	self.infoView.text = [NSString stringWithFormat:@"%lu人在线", _onelineCount];
}

- (instancetype)initWithCoder:(NSCoder *)decoder{
	if (self = [super initWithCoder:decoder]) {
		//NSLog(@"%s", __FUNCTION__);
		[self setupUI];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
		[self setupUI];
	}
	return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_round_bg_36"]];
    if ([self.subviews firstObject]) {
        [[self.subviews firstObject] removeFromSuperview];
    }
    [self insertSubview:bgView atIndex:0];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_offset(0);
    }];
    
    UIImageView *avatarView = self.avatarView;
    [self addSubview:avatarView];
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.mas_offset(0);
        make.width.equalTo(self.mas_height);
    }];

    UILabel *infoView = [[UILabel alloc] init];
    infoView.textColor = [UIColor whiteColor];
    infoView.font = [UIFont systemFontOfSize:14];
    [self addSubview:infoView];
    self.infoView = infoView;
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(avatarView.mas_right).mas_offset(14);
        make.right.equalTo(self).mas_offset(-25);
    }];
}
@end
