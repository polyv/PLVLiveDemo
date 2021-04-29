//
//  ViewController.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/27.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVLoginViewController.h"
#import "PLVLoginTextField.h"
#import "PLVCheckBox.h"
#import "PLVCheckPrivacyView.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import <PLVLiveSDK/PLVNetworking.h>
#import "PLVLiveSettingViewController.h"
#import "PLVPrivacyViewController.h"
#import "AES.h"
#import "PLVUtil.h"
#import "UIImage+PLV.h"

#define CHANELID @"channelID"
#define CHANELPASSWD @"channelPasswd"
#define PASSW @"bqlin@polyv"

@interface PLVLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet PLVLoginTextField *channelTextField;
@property (weak, nonatomic) IBOutlet PLVLoginTextField *passwdTextField;
@property (weak, nonatomic) IBOutlet PLVCheckBox *rememberLogin;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIStackView *outStackView;
@property (weak, nonatomic) IBOutlet UIStackView *inStackView;
@property (weak, nonatomic) IBOutlet PLVCheckPrivacyView *privacyView;

@end

@implementation PLVLoginViewController

#pragma mark - Lift Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadLoginInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Control

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        [self.passwdTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    int newLength = [PLVUtil calculateTextLength:toBeString];
    NSUInteger maxLength = (textField.tag == 10508) ? 10 : 20;
    if (newLength <= maxLength) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - 加载页面

- (void)setupUI {
    UIImageView *channelLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_channel_img"]];
    channelLeftView.frame = CGRectMake(0, 0, 24, 24);
    self.channelTextField.leftView = channelLeftView;
    self.channelTextField.leftViewMode = UITextFieldViewModeAlways;
    self.channelTextField.delegate = self;
    self.channelTextField.pasteNumberOnly = YES;
    self.channelTextField.tag = 10508;
    
    UIImageView *passwdLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_password_img"]];
    passwdLeftView.frame = CGRectMake(0, 0, 24, 24);
    self.passwdTextField.leftView = passwdLeftView;
    self.passwdTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwdTextField.delegate = self;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight < 667) {
        self.outStackView.spacing -= 5;
        self.inStackView.spacing -= 5;
    }
    
    
    // 自定义颜色
    self.loginButton.tintColor = self.loginButton.currentBackgroundImage.centerColor;
    PLVCustomization *customization = [PLVCustomization sharedCustomization];
    if (customization.loginButtonColor) self.loginButton.tintColor = customization.loginButtonColor;
    if (customization.loginButtonTextColor) [self.loginButton setTitleColor:customization.loginButtonTextColor forState:UIControlStateNormal];
    if (customization.loginInputColor) {
        self.channelTextField.color = self.passwdTextField.color = self.rememberLogin.tintColor = customization.loginInputColor;
    }
    
    self.loginButton.enabled = [PLVCheckPrivacyView isPrivacyAgreed];
    __weak typeof(self) weakSelf = self;
    self.privacyView.didCheckBox = ^(BOOL checked) {
        weakSelf.loginButton.enabled = checked;
    };
    self.privacyView.didTapPrivacy = ^(NSString * _Nonnull urlString) {
        PLVPrivacyViewController *vctrl = [[PLVPrivacyViewController alloc] initWithUrlString:urlString];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vctrl];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [weakSelf presentViewController:nav animated:YES completion:nil];
    };
}

#pragma mark - 储存账号密码

- (void)loadLoginInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelID = [defaults stringForKey:CHANELID];
    NSString *passwd = [defaults stringForKey:CHANELPASSWD];
    
    channelID = [AES decrypt:channelID password:PASSW];
    passwd = [AES decrypt:passwd password:PASSW];
    
    self.channelTextField.text = channelID;
    self.passwdTextField.text = passwd;
    self.rememberLogin.selected = channelID.length || passwd.length;
}

- (void)saveLoginInfo {
    NSString *channelID = self.channelTextField.text;
    NSString *passwd = self.passwdTextField.text;
    channelID = [AES encrypt:channelID password:PASSW];
    passwd = [AES encrypt:passwd password:PASSW];
    
    [[NSUserDefaults standardUserDefaults] setObject:channelID forKey:CHANELID];
    [[NSUserDefaults standardUserDefaults] setObject:passwd forKey:CHANELPASSWD];
}

- (void)clearLoginInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CHANELID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CHANELPASSWD];
}

#pragma mark - 登陆跳转

- (IBAction)loginButtonClick:(id)sender {
    [self.view endEditing:YES];
    self.rememberLogin.isSelected ? [self saveLoginInfo] : [self clearLoginInfo];
    NSString *title = @"登录失败";
    if (!self.channelTextField.text.length) {
        [PLVUtil alertErrorWithTitle:title reason:@"请输入频道号" target:self];
        return;
    }
    if (!self.passwdTextField.text.length) {
        [PLVUtil alertErrorWithTitle:title reason:@"请输入频道号" target:self];
        return;
    }
    [PLVCheckPrivacyView savePrivacyAgreed];
    
    __weak typeof(self)weakSelf = self;
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:self.view animated:YES];
    [PLVNetworking loginWithChanelid:self.channelTextField.text password:self.passwdTextField.text completion:^(NSDictionary *responseDict) {
        [hud hideAnimated:YES];
        NSString *liveScene = responseDict[@"liveScene"];
        if ([liveScene isEqualToString:@"alone"] || [liveScene isEqualToString:@"topclass"]) {
            PLVLiveSettingViewController *settingVC = [[PLVLiveSettingViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:settingVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            PLVLiveSetting *setting = [[PLVLiveSetting alloc]initWithLoginResponse:responseDict];
            settingVC.setting = setting;
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            [PLVUtil alertInfo:@"请使用普通直播场景频道登录" target:weakSelf];
        }
    } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
        NSLog(@"loginWithChanelid failed: %ld, %@",errorCode,description);
        [hud hideAnimated:YES];
        [PLVUtil alertErrorWithTitle:title reason:description target:weakSelf];
    }];
}

@end
