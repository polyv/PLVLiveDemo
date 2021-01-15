//
//  PLVViewerAvatarCell.m
//  PLVCarousel
//
//  Created by LinBq on 16/11/9.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVViewerAvatarCell.h"
#import "UIImageView+CornerRadius.h"

@implementation PLVViewerAvatarCell

//#pragma mark - 存取器
- (UIImageView *)avatarView{
	if (!_avatarView) {
		_avatarView = [[UIImageView alloc] initWithRoundingRectImageView];
	}
	return _avatarView;
}

#pragma mark - init&dealloc
- (void)dealloc{
	NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
//		NSLog(@"%s", __FUNCTION__);
		[self.contentView addSubview:self.avatarView];
	}
	return self;
}

- (void)layoutSubviews{
	self.avatarView.frame = self.contentView.bounds;
}

@end
