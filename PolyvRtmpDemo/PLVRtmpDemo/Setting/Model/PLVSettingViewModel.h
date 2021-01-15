//
//  PLVSettingViewModel.h
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2021/1/5.
//  Copyright © 2021 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PLVLiveSetting.h"


@interface PLVSettingViewModel : NSObject

/// 配置单元格为单选
+ (void)configRadioButtonWithTableView:(UITableView *)tableView indexPathSelected:(NSIndexPath *)indexPath;

/// 刷新配置信息
+ (void)flushSetting:(PLVLiveSetting *)setting indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end


