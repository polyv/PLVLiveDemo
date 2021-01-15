//
//  PLVLiveMaskView+VM.h
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/21.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVLiveMaskView.h"
#define VIEWER_LIST_FETCH_TIMER @"vierListFetchTimer"

@interface PLVLiveMaskView (VM)

/// 获取观众列表
- (void)fetchViewerListWithInterval:(NSTimeInterval)interval;

@end
