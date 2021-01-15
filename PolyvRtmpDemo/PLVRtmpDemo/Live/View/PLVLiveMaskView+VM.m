//
//  PLVLiveMaskView+VM.m
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/21.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import "PLVLiveMaskView+VM.h"
#import "PLVTimerManager.h"
#import <PLVLiveSDK/PLVNetworking.h>
#import "PLVViewer.h"

@implementation PLVLiveMaskView (VM)

- (void)fetchViewerListWithInterval:(NSTimeInterval)interval{
	__weak typeof(self) weakSelf = self;
	[[PLVTimerManager sharedTimerManager] scheduledDispatchTimerWithName:VIEWER_LIST_FETCH_TIMER timeInterval:interval queue:nil repeats:YES actionOption:AbandonPreviousAction action:^{
        [PLVNetworking requestViewerListWithLength:100 page:1 completion:^(NSInteger count, NSArray *viewerList, NSError *error) {
            NSMutableArray *modelArray = [NSMutableArray array];
            for (NSDictionary *dict in viewerList) {
                PLVViewer *viewer = [PLVViewer new];
                viewer.userId = [NSString stringWithFormat:@"%@",dict[@"userId"]];
                viewer.roomId = [NSString stringWithFormat:@"%@",dict[@"roomId"]];
                viewer.nick = [NSString stringWithFormat:@"%@",dict[@"nick"]];
                viewer.pic = [NSString stringWithFormat:@"%@",dict[@"pic"]];
                viewer.uid = [NSString stringWithFormat:@"%@",dict[@"uid"]];
                viewer.clientIp = [NSString stringWithFormat:@"%@",dict[@"clientIp"]];
                [modelArray addObject:viewer];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.channelAvatar.onelineCount = count;
                @try {
                    [weakSelf mergeViewerWithViewerList:modelArray];
                } @catch (NSException *exception) {
                    NSLog(@"-mergeViewerWithViewerList: crashed:%@",exception.reason);
                }
            });
            
        } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
            NSLog(@"requestViewerListWithLength failed: %ld, %@",errorCode,description);
        }];
	}];
}

@end
