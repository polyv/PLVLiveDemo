//
//  PLVCountdownView.m
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/10.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVCountdownView.h"
#import "UIColor+PLV.h"
#import "PLVTimerManager.h"

#define COUNTDOWN_TIMER @"countTimer"

@interface PLVCountdownView ()
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (nonatomic, weak) UIView *contentView;
@end

@implementation PLVCountdownView

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
	_contentView.frame = self.bounds;
}

- (void)commonInit{
	_contentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil] lastObject];
	[self addSubview:_contentView];
}

- (void)commonSetup{
	[self setupUI];
	self.userInteractionEnabled = NO;
}

- (void)setupUI{
	self.contentView.backgroundColor = [UIColor clearColor];
	self.backgroundColor = [UIColor clearColor];
	self.countdownLabel.layer.shadowOpacity = 1;
	self.countdownLabel.layer.shadowColor = [UIColor colorWithHex:0 alpha:.65].CGColor;
	self.countdownLabel.layer.shadowRadius = 25;
}

- (void)beginCountdown {
	self.hidden = NO;
	__block int count = 3;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.countdownLabel.text = [NSString stringWithFormat:@"%d", count];
	});
	__weak typeof(self) weakSelf = self;
	[[PLVTimerManager sharedTimerManager] scheduledDispatchTimerWithName:COUNTDOWN_TIMER timeInterval:1 queue:dispatch_get_main_queue() repeats:YES actionOption:AbandonPreviousAction action:^{
		count --;
		weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%d", count];
		if (!count) {
			[[PLVTimerManager sharedTimerManager] cancelTimerWithName:COUNTDOWN_TIMER];
			weakSelf.hidden = YES;
			if ([self.delegate respondsToSelector:@selector(countdownViewDidEnd:)]) {
				[self.delegate countdownViewDidEnd:self];
			}
		}
	}];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
