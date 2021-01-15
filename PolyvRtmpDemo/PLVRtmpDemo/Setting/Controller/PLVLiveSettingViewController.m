//
//  PLVLiveSettingViewController.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/29.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "PLVLiveSettingViewController.h"
#import "PLVUtil.h"
#import "PLVLiveViewController.h"
#import "PLVReachabilityManager.h"
#import "PLVSettingViewModel.h"
#import <Masonry/Masonry.h>
#import <PolyvFoundationSDK/PLVAuthorizationManager.h>
#import "PLVLiveSettingViewController+Share.h"
#import <PLVLiveSDK/PLVNetworking.h>


#define TEXT_MAX_LENGTH 50


@interface PLVLiveSettingViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

/**
 TableView相关
 */

@property (nonatomic, strong) UITableView *tableView;
/// 推流模式
@property (nonatomic, copy) NSArray *rtmpModeArr;
/// 推流清晰度
@property (nonatomic, copy) NSArray *videoQualityArr;
/// 美颜开关
@property (nonatomic, copy) NSArray *beautifyFaceArr;

/// 直播间标题
@property (nonatomic, strong) UITextField *liveTitleField;
/// 当前选中的参数
@property (nonatomic, assign) NSInteger selectedRtmpModeRow;
@property (nonatomic, assign) NSInteger selectedVideoQualityRow;
@property (nonatomic, assign) NSInteger selectedbeautifyFaceRow;
/// 分享视图
@property (nonatomic, strong) UIView *shareContentView;


@end

@implementation PLVLiveSettingViewController


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSetting];
    [self setupUI];
}

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - init


/// 参数初始化
- (void)initSetting{
    self.setting.landscapeEnable = YES;
    self.setting.definition = PLVDefinitionHigh;
    /// 默认参数
    self.selectedRtmpModeRow = 1;
    self.selectedVideoQualityRow = 1;
    self.selectedbeautifyFaceRow = 1;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:68.0/255.0 green:110.0/255.5 blue:171.0/255.5 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plv_logout_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonBeClicked)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    /// 点击空白处收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self initTableView];
    [self initStartLiveView];
    [self initShareContentView];
}


- (void)initTableView {
    self.tableView = [[UITableView alloc]init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.top.mas_offset(0);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-80);
        } else {
            make.bottom.mas_offset(-80);
        }
    }];
    self.tableView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    self.tableView.tableFooterView = tableFooterView;
    
    [self initLiveTitleField];

}

- (void)initLiveTitleField {
    self.liveTitleField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 44)];
    self.liveTitleField.text = self.setting.liveTitle;
    self.liveTitleField.font = [UIFont systemFontOfSize:14.0];
    self.liveTitleField.placeholder = @"请输入直播名称（30个中文字以内）";
    self.liveTitleField.delegate = self;
    UILabel *rightView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    rightView.textColor = [UIColor blackColor];
    
    self.liveTitleField.userInteractionEnabled = [PLVChannel sharedChannel].isMasterAccount;
    self.liveTitleField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    self.liveTitleField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.liveTitleField.rightView = rightView;
}


- (void)initStartLiveView {
    UIView *startLiveView = [[UIView alloc]init];
    startLiveView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:startLiveView];
    [startLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.height.mas_equalTo(80);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.mas_offset(0);
        }
    }];
    
    UIButton *startLiveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
    [startLiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startLiveButton.layer.cornerRadius = 20.0;
    startLiveButton.layer.masksToBounds = YES;
    startLiveButton.backgroundColor = [UIColor colorWithRed:76/255.0 green:154/255.5 blue:1.0 alpha:1.0];
    [startLiveButton addTarget:self action:@selector(enterLivePage) forControlEvents:UIControlEventTouchUpInside];
    [startLiveView addSubview:startLiveButton];
    [startLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(300, 44));
    }];
}

- (void)initShareContentView {
    self.shareContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 112)];
    self.shareContentView.backgroundColor = [UIColor whiteColor];
    
    CGFloat y = 20;
    CGFloat width = 54;
    CGFloat height = 112 - 40;
    float padding = (SCREEN_WIDTH - width * 5) / 6.0;
    
    for (int i = 0; i < 5; i++) {
        UIButton *shareButton;
        switch (i) {
            case 0:
                shareButton = [self buttonWithTitle:@"微信好友" NormalImageString:@"plv_shared_wechat_disable" selectedImageString:@"plv_shared_wechat"];
                break;
            case 1:
                shareButton = [self buttonWithTitle:@"朋友圈" NormalImageString:@"plv_shared_moments_disable" selectedImageString:@"plv_shared_moments"];
                break;
            case 2:
                shareButton = [self buttonWithTitle:@"新浪微博" NormalImageString:@"plv_shared_weibo_disbale" selectedImageString:@"plv_shared_weibo"];
                break;
            case 3:
                shareButton = [self buttonWithTitle:@"QQ" NormalImageString:@"plv_shared_qq_disable" selectedImageString:@"plv_shared_qq"];
                break;
            case 4:
                shareButton = [self buttonWithTitle:@"观看URL" NormalImageString:@"plv_shared_link_disable" selectedImageString:@"plv_shared_link"];
                break;
            default:
                break;
        }
        shareButton.frame = CGRectMake((i * width) + (i + 1) * padding, y, width, height);
        [self.shareContentView addSubview:shareButton];
        shareButton.tag = i;
        [shareButton addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    }

    
}

#pragma mark - private

- (UIButton *)buttonWithTitle:(NSString *)title NormalImageString:(NSString *)normalImageString selectedImageString:(NSString *)selectedImageString {
    UIButton *button = [[UIButton alloc]init];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage: [UIImage imageNamed:normalImageString] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImageString] forState:UIControlStateSelected];
    
    button.imageEdgeInsets = UIEdgeInsetsMake(0,5,25,5);
    button.titleEdgeInsets = UIEdgeInsetsMake(44,-44,0,0);
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];

    return button;
}

/// 计算输入框文本长度
- (double)calculateTextLengthWithString:(NSString *)text {
    double strLength = 0;
    for (int i = 0; i < text.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *strFromSubStr = [text substringWithRange:range];
        const char * cStringFromstr = [strFromSubStr UTF8String];
        if (cStringFromstr != NULL && strlen(cStringFromstr) == 3){
            strLength += 1;
        } else {
            strLength += 0.5;
        }
    }
    return round(strLength);
}


#pragma mark - Click Action

- (void)enterLivePage {
    if (!self.liveTitleField.text.length) {
        [PLVUtil alertInfo:@"当前活动标题为空，请输入活动标题" target:self];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [PLVAuthorizationManager requestAuthorizationForAudioAndVideo:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if ([PLVReachabilityManager sharedManager].reachable) {
                    PLVLiveViewController *liveViewController = [PLVLiveViewController new];
                    liveViewController.setting = self.setting;
                    liveViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [weakSelf presentViewController:liveViewController animated:YES completion:nil];
                }else{
                    [PLVUtil alertInfo:@"网络连接失败，请重试" target:self];
                }
            } else {
                [PLVAuthorizationManager showAlertWithTitle:nil message:@"POLYV云直播需要获取您的摄像机及音频权限，前往设置" viewController:weakSelf];
            }
        });
    }];
}

- (void)shareClick:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self shareWithWechat:sender];
            break;
        case 1:
            [self shareWithMoment:sender];
            break;
        case 2:
            [self shareWithWeibo:sender];
            break;
        case 3:
            [self shredWithQQ:sender];
            break;
        case 4:
            [self shareWithQzone:sender];
            break;
        default:
            break;
    }
}


#pragma mark - View Control

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3) {
        /// 实现单选
        [PLVSettingViewModel configRadioButtonWithTableView:tableView indexPathSelected:indexPath];
        // 处理选项
        [PLVSettingViewModel flushSetting:self.setting indexPath:indexPath tableView:tableView];
        switch (indexPath.section) {
            case 1:
                self.selectedRtmpModeRow = indexPath.row;
                break;
            case 2:
                self.selectedVideoQualityRow = indexPath.row;
                break;
            case 3:
                self.selectedbeautifyFaceRow = indexPath.row;
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        return 112;
    } else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headView = [UITableViewHeaderFooterView new];
    headView.contentView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.5 blue:244/255.0 alpha:1.0];

    if (section == 0) {
        headView.textLabel.text = @"直播名称";
    } else if (section == 1) {
        headView.textLabel.text = @"推流模式";
    } else if (section == 2) {
        headView.textLabel.text = @"推流清晰度";
    } else if (section == 3){
        headView.textLabel.text = @"美颜开关";
    } else {
        headView.textLabel.text = @"分享到";
    }
    return headView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headView = (UITableViewHeaderFooterView *)view;
    headView.textLabel.font = [UIFont systemFontOfSize:16.0];
    headView.textLabel.textColor = [UIColor grayColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.rtmpModeArr.count;
    } else if (section == 2) {
        return self.videoQualityArr.count;
    } else if (section == 3){
        return self.beautifyFaceArr.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"identifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.section == 0) {
        if (![cell.contentView.subviews containsObject:self.liveTitleField]) {
            [cell.contentView addSubview:self.liveTitleField];
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = self.rtmpModeArr[indexPath.row];
        cell.accessoryType = (indexPath.row == _selectedRtmpModeRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.section == 2) {
        cell.textLabel.text = self.videoQualityArr[indexPath.row];
        cell.accessoryType = (indexPath.row == _selectedVideoQualityRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.section == 3){
        cell.textLabel.text = self.beautifyFaceArr[indexPath.row];
        cell.accessoryType = (indexPath.row == _selectedbeautifyFaceRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        if (![cell.contentView.subviews containsObject:self.shareContentView]) {
            [cell.contentView addSubview:self.shareContentView];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UILabel *rightLabel = (UILabel *)textField.rightView;
    rightLabel.text = [NSString stringWithFormat:@"%.0f/%d",[self calculateTextLengthWithString:textField.text],TEXT_MAX_LENGTH];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }

    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    double newLength = [self calculateTextLengthWithString:toBeString];
    //NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength <= TEXT_MAX_LENGTH) {
        UILabel *rightLabel = (UILabel *)textField.rightView;
        rightLabel.text = [NSString stringWithFormat:@"%.0f/%d",newLength,TEXT_MAX_LENGTH];
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *liveTitle = textField.text;
    if (liveTitle.length && ![self.setting.liveTitle isEqualToString:liveTitle]) {
        [PLVNetworking logEnable:YES];
        [PLVNetworking updateChanelName:liveTitle completion:^(NSDictionary *responseDict) {
            if ([responseDict[@"status"] isEqualToString:@"success"]) {
                [PLVUtil showHUDViewWithMessage:@"更新成功" superView:self.view];
            } else {
                [PLVUtil showHUDViewWithMessage:responseDict[@"msg"] superView:self.view];
            }
        } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
            [PLVUtil showHUDViewWithMessage:@"更新失败" superView:self.view];
        }];
        self.setting.liveTitle = liveTitle;
    }
}

#pragma mark - Actions

- (void)logoutButtonBeClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)hideKeyBoard {
    [self.liveTitleField endEditing:YES];
}



#pragma mark - getter

- (PLVLiveSetting *)setting {
    if (!_setting) {
        _setting = [[PLVLiveSetting alloc] init];
        [PLVUtil alertErrorWithTitle:@"载入信息出错" reason:@"载入的设置信息为空" target:self];
    }
    return _setting;
}

- (NSArray *)rtmpModeArr {
    if (!_rtmpModeArr) {
        _rtmpModeArr = @[@"竖屏模式",@"横屏模式"];
    }
    return _rtmpModeArr;
}

- (NSArray *)videoQualityArr {
    if (!_videoQualityArr) {
        _videoQualityArr = @[@"超清",@"高清",@"标清"];
    }
    return _videoQualityArr;
}

- (NSArray *)beautifyFaceArr {
    if (!_beautifyFaceArr) {
        _beautifyFaceArr = @[@"开启美颜", @"关闭美颜"];
    }
    return _beautifyFaceArr;
}


@end
