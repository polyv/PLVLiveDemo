//
//  PLVPrivacyViewController.m
//  PLVRtmpDemo
//
//  Created by jiaweihuang on 2020/12/28.
//  Copyright © 2020 easefun. All rights reserved.
//

#import "PLVPrivacyViewController.h"
#import <WebKit/WebKit.h>

@interface PLVPrivacyViewController ()

@end

@interface PLVPrivacyViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *urlString;

@end

@implementation PLVPrivacyViewController

#pragma mark - Public

- (instancetype)initWithUrlString:(NSString *)urlString {
    self = [super init];
    if (self) {
        _urlString = urlString;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavigationBar];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"title" context:nil];
    _webView = nil;
}

#pragma mark - Initialize

- (void)initNavigationBar {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    UIColor *titleColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:20],
                                      NSForegroundColorAttributeName:titleColor};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 44, 44);
    [leftButton setImage:[UIImage imageNamed:@"plv_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem =[[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Getter & Setter

- (WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.contentMode = UIViewContentModeRedraw;
        _webView.opaque = NO;
        [self.view addSubview:_webView];

        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        if(@available(iOS 11.0, *)) {
            CGRect navigationBarRect = self.navigationController.navigationBar.frame;
            CGFloat originY = navigationBarRect.origin.y + navigationBarRect.size.height + statusBarHeight;
            _webView.frame = CGRectMake(0, originY, self.view.bounds.size.width, self.view.bounds.size.height - originY);
            _webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        } else {
            _webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            
            UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, statusBarHeight)];
            bg.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:bg];
        }
        
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}

#pragma mark - Action

- (void)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

@end

