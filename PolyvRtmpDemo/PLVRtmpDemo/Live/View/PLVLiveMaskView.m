//
//  PLVLiveMaskView.m
//  LiveStreamer
//
//  Created by LinBq on 16/10/20.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVLiveMaskView.h"

#import "PLVViewerAvatarCell.h"
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>
#import "PLVUtil.h"
#define AVATAR_CellID @"avatarCell"

@interface PLVLiveMaskView ()<UICollectionViewDataSource>

@property (nonatomic, weak) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *moreView;

/// 观众列表
@property (weak, nonatomic) IBOutlet UICollectionView *viewerListView;
@property (nonatomic, strong) NSMutableArray<PLVViewer *> *viewers;
@property (weak, nonatomic) IBOutlet UILabel *liveTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveSpeedLabel;

@end

@implementation PLVLiveMaskView

#pragma mark - 存取器

#pragma mark 懒加载
- (NSMutableArray<PLVViewer *> *)viewers{
	if (!_viewers) {
		_viewers = [NSMutableArray array];
	}
	return _viewers;
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
	_contentView.frame = self.bounds;
}

- (void)commonInit{
	_contentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil] lastObject];
	[self addSubview:_contentView];
}

- (void)commonSetup{
	[self setupUI];
}

- (void)setupUI{
	self.contentView.backgroundColor = [UIColor clearColor];
	[self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.moreView.superview.mas_bottom);
	}];
    	
	// 观众列表
	self.viewerListView.backgroundColor = [UIColor clearColor];
	[self.viewerListView registerClass:[PLVViewerAvatarCell class] forCellWithReuseIdentifier:AVATAR_CellID];
	self.viewerListView.dataSource = self;
}

- (IBAction)more:(UIButton *)sender {
	sender.selected = !sender.isSelected;
	if (sender.isSelected) {
		[self.moreView mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(sender.mas_top).offset(-10);
		}];
		
		[UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations: ^{
			[self.moreView.superview layoutIfNeeded];
			self.moreView.alpha = 1;
		} completion: nil];
	}else{
		[UIView animateWithDuration:.2 animations:^{
			self.moreView.alpha = 0;
		} completion:^(BOOL finished) {
			[self.moreView mas_remakeConstraints:^(MASConstraintMaker *make) {
				make.top.equalTo(self.moreView.superview.mas_bottom);
			}];
		}];
	}
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return self.viewers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	PLVViewerAvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AVATAR_CellID forIndexPath:indexPath];
	NSURL *URL = [NSURL URLWithString:self.viewers[self.viewers.count - 1 - indexPath.item].pic];
	[cell.avatarView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"plv_placeholder_avatar"]];
	return cell;
}

#pragma mark - 外部接口
/// 合并观众列表
- (void)mergeViewerWithViewerList:(NSArray<PLVViewer *> *)viewerList {
	// 对viewerList进行集合操作
	NSMutableSet *currentList = [NSMutableSet setWithArray:viewerList];
	[currentList minusSet:[NSSet setWithArray:self.viewers]];
	if (currentList.count){ // 增
		if (_logEnable) NSLog(@"currentList = %@", currentList);
		// 合并
		NSMutableArray *indexPaths = [NSMutableArray array];
		int count = 0;
		for (PLVViewer *viewer in currentList) {
			[self.viewers addObject:viewer];
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count inSection:0];
			[indexPaths addObject:indexPath];
			count ++;
		}
		[self.viewerListView insertItemsAtIndexPaths:indexPaths];
	}else{ // 减
		NSMutableSet *lastList = [NSMutableSet setWithArray:self.viewers];
		[lastList minusSet:[NSSet setWithArray:viewerList]];
		if (!lastList.count){
			//[self.viewerListView reloadData];
			return;
		}
		if (_logEnable) NSLog(@"lastList = %@", lastList);
		// 除去
		NSMutableArray *indexPaths = [NSMutableArray array];
		for (PLVViewer *viewer in lastList) {
			NSUInteger index = [self.viewers indexOfObject:viewer];
			[self.viewers removeObjectAtIndex:index];
			NSUInteger itemIndex = self.viewers.count - index;
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
			[indexPaths addObject:indexPath];
		}
		//NSLog(@"indexPaths = %@", indexPaths);
//		[self.viewerListView deleteItemsAtIndexPaths:indexPaths];
	}
	[self.viewerListView reloadData];
}

/// 设置时间标签
- (void)setLiveTime:(long)liveTime{
	_liveTime = liveTime;
	NSString *timeStr = stringWithTime(liveTime);
	dispatch_async(dispatch_get_main_queue(), ^{
		self.liveTimeLabel.text = timeStr;
	});
}

/// 设置网速标签
- (void)setLiveSpeed:(CGFloat)speed{
	dispatch_async(dispatch_get_main_queue(), ^{
		self.liveSpeedLabel.textColor = [UIColor whiteColor];
		self.liveSpeedLabel.text = stringWithSpeed(speed);
	});
}

/// 设置网速状态
- (void)setLiveStatus:(NSString *)text{
	dispatch_async(dispatch_get_main_queue(), ^{
		self.liveSpeedLabel.textColor = [UIColor redColor];
		self.liveSpeedLabel.text = text;
	});
}

/// 设置直播状态
- (void)setLiveStatus:(NSString *)text color:(UIColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveStatusLabel.text = text;
        self.liveStatusLabel.textColor = color;
    });
}

- (void)setShowRetryButton:(BOOL)showRetryButton {
    _showRetryButton = showRetryButton;
    _retryBtn.hidden = !showRetryButton;
    _liveSpeedLabel.hidden = showRetryButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
