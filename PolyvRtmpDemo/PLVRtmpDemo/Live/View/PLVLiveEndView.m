//
//  PLVLiveEndView.m
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/11.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVLiveEndView.h"
#import "PLVUtil.h"

@interface PLVLiveEndView ()

@property (weak, nonatomic) IBOutlet UILabel *livePopulationLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveTimeLabel;

@property (nonatomic, weak) UIView *xibView;

@end

@implementation PLVLiveEndView

/// 设置直播时间
- (void)setLiveTime:(long)time{
	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.liveTimeLabel.attributedText = attributedStringWithTimeZh(time);
		[weakSelf.livePopulationLabel sizeToFit];
	});
}

/// 设置直播人数
- (void)setLivePopulation:(long)population{
	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		weakSelf.livePopulationLabel.text = [NSString stringWithFormat:@"%ld", population];
	});
}

#pragma mark - init&dealloc
- (void)dealloc{
	NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithCoder:(NSCoder *)coder{
	if (_logEnable) NSLog(@"%s", __FUNCTION__);
	if (self = [super initWithCoder:coder]) {
		[self commonInit];
	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
	if (_logEnable) NSLog(@"%s", __FUNCTION__);
	if (self = [super initWithFrame:frame]) {
		[self commonInit];
		[self commonSetup];
	}
	return self;
}
- (void)awakeFromNib{
	[super awakeFromNib];
	if (_logEnable) NSLog(@"%s", __FUNCTION__);
	[self commonSetup];
}

- (void)layoutSubviews{
	_xibView.frame = self.bounds;
}

- (void)commonInit{
	_xibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil] lastObject];
	[self.contentView addSubview:_xibView];
}

- (void)commonSetup{
	[self setupUI];
}

- (void)setupUI{
	self.xibView.backgroundColor = [UIColor clearColor];
	self.backgroundColor = [UIColor clearColor];
	
	//设置UIVisualEffectView
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	self.effect = blurEffect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
