//
//  PLVSettingViewModel.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2021/1/5.
//  Copyright © 2021 easefun. All rights reserved.
//

#import "PLVSettingViewModel.h"

@implementation PLVSettingViewModel

/// 配置单元格为单选
+ (void)configRadioButtonWithTableView:(UITableView *)tableView indexPathSelected:(NSIndexPath *)indexPath{
    // 获取需要的数据
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger rowCount = [tableView numberOfRowsInSection:indexPath.section];
    
    // 取消选中
    cell.selected = NO;
    
    // 进行单选
    for (int i = 0; i < rowCount; i ++) {
        if (indexPath.row == i) continue;
        NSIndexPath *indexPathx = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        UITableViewCell *cellx = [tableView cellForRowAtIndexPath:indexPathx];
        if (cellx.accessoryType == UITableViewCellAccessoryCheckmark) cellx.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

/// 刷新配置信息
+ (void)flushSetting:(PLVLiveSetting *)setting indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    switch (indexPath.section) {
        case 1: { // 推流模式
            switch (indexPath.row) {
                case 0: { // 竖屏
                    setting.landscapeEnable = NO;
                } break;
                case 1: { // 横屏
                    setting.landscapeEnable = YES;
                } break;
                default: {} break;
            }
            break;
        }
        case 2: { // 推流清晰度
            switch (indexPath.row) {
                case 0: { // 超清
                    setting.definition = PLVDefinitionUltra;
                } break;
                case 1: { // 高清
                    setting.definition = PLVDefinitionHigh;
                } break;
                case 2: { // 标清
                    setting.definition = PLVDefinitionStandard;
                } break;
                default: {} break;
            }
            break;
        }
        case 3: { // 美颜开关
            switch (indexPath.row) {
                case 0: { // 开启美颜
                    setting.beautyEnable = YES;
                } break;
                case 1: { // 关闭美颜
                    setting.beautyEnable = NO;
                } break;
                default: {} break;
            }
            break;
        }
        case 4: { // 镜像开关
            switch (indexPath.row) {
                case 0: { // 开启美颜
                    setting.mirrorEnable = YES;
                } break;
                case 1: { // 关闭美颜
                    setting.mirrorEnable = NO;
                } break;
                default: {} break;
            }
            break;
        }
        default: {} break;
    }
}

@end
