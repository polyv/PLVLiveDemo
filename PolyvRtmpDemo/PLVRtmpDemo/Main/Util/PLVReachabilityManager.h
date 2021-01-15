//
//  PLVReachabilityManager.h
//  PLVLiveStreamer
//
//  Created by LinBq on 16/11/22.
//  Copyright © 2016年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SystemConfiguration/SystemConfiguration.h>

typedef NS_ENUM(NSInteger, PLVReachabilityStatus) {
    PLVReachabilityStatusUnknown          = -1,
    PLVReachabilityStatusNotReachable     = 0,
    PLVReachabilityStatusReachableViaWWAN = 1,
    PLVReachabilityStatusReachableViaWiFi = 2,
};

NS_ASSUME_NONNULL_BEGIN

/**
 `PLVReachabilityManager` monitors the reachability of domains, and addresses for both WWAN and WiFi network interfaces.
 
 Reachability can be used to determine background information about why a network operation failed, or to trigger a network operation retrying when a connection is established. It should not be used to prevent a user from initiating a network request, as it's possible that an initial request may be required to establish reachability.
 
 See Apple's Reachability Sample Code ( https://developer.apple.com/library/ios/samplecode/reachability/ )
 
 @warning Instances of `PLVReachabilityManager` must be started with `-startMonitoring` before reachability status can be determined.
 */
@interface PLVReachabilityManager : NSObject

/// 当前网络状态
@property (readonly, nonatomic, assign) PLVReachabilityStatus networkReachabilityStatus;

/// 当前网络是否可达
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/// 当前通过WWAN是否可达
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/// 当前通过WiFi是否可达
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

///---------------------
/// @name 初始化
///---------------------

/// 返回共享的网络可达性管家
+ (instancetype)sharedManager;

/**
 用默认的socket地址创建并返回网络可达性管家
 
 @return An initialized network reachability manager, actively monitoring the default socket address.
 */
+ (instancetype)manager;

/**
 为指定域名创建并返回网络可达性管家
 
 @param domain The domain used to evaluate network reachability.
 
 @return An initialized network reachability manager, actively monitoring the specified domain.
 */
+ (instancetype)managerForDomain:(NSString *)domain;

/**
 为socket地址创建并返回网络可达性管家
 
 @param address The socket address (`sockaddr_in6`) used to evaluate network reachability.
 
 @return An initialized network reachability manager, actively monitoring the specified socket address.
 */
+ (instancetype)managerForAddress:(const void *)address;

/**
 从指定的可行性对象初始化网络可达性管家
 
 @param reachability The reachability object to monitor.
 
 @return An initialized network reachability manager, actively monitoring the specified reachability.
 */
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

/**
 *  Initializes an instance of a network reachability manager
 *
 *  @return nil as this method is unavailable
 */
- (nullable instancetype)init NS_UNAVAILABLE;

///--------------------------------------------------
/// @name 开始/停止网络可达性监听
///--------------------------------------------------

/// 开始监听网络可达性状态改变
- (void)startMonitoring;

/// 停止监听网络可达性状态
- (void)stopMonitoring;

///-------------------------------------------------
/// @name 获取本地化可达性描述
///-------------------------------------------------

/// 返回代表当前网络状态的本地化字符串
- (NSString *)localizedNetworkReachabilityStatusString;

///---------------------------------------------------
/// @name 设置网络可达性改变时回调
///---------------------------------------------------

/**
 当`baseURL`主机改变时，设置的回调执行
 
 @param block A block object to be executed when the network availability of the `baseURL` host changes.. This block has no return value and takes a single argument which represents the various reachability states from the device to the `baseURL`.
 */
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(PLVReachabilityStatus status))block;

@end

///----------------
/// @name Constants
///----------------

/**
 ## Network Reachability
 
 The following constants are provided by `PLVReachabilityManager` as possible network reachability statuses.
 
 enum {
 PLVReachabilityStatusUnknown,
 PLVReachabilityStatusNotReachable,
 PLVReachabilityStatusReachableViaWWAN,
 PLVReachabilityStatusReachableViaWiFi,
 }
 
 `PLVReachabilityStatusUnknown`
 The `baseURL` host reachability is not known.
 
 `PLVReachabilityStatusNotReachable`
 The `baseURL` host cannot be reached.
 
 `PLVReachabilityStatusReachableViaWWAN`
 The `baseURL` host can be reached via a cellular connection, such as EDGE or GPRS.
 
 `PLVReachabilityStatusReachableViaWiFi`
 The `baseURL` host can be reached via a Wi-Fi connection.
 
 ### Keys for Notification UserInfo Dictionary
 
 Strings that are used as keys in a `userInfo` dictionary in a network reachability status change notification.
 
 `PLVReachabilityNotificationStatusItem`
 A key in the userInfo dictionary in a `PLVReachabilityDidChangeNotification` notification.
 The corresponding value is an `NSNumber` object representing the `PLVReachabilityStatus` value for the current reachability status.
 */

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when network reachability changes.
 This notification assigns no notification object. The `userInfo` dictionary contains an `NSNumber` object under the `PLVReachabilityNotificationStatusItem` key, representing the `PLVReachabilityStatus` value for the current network reachability.
 
 @warning In order for network reachability to be monitored, include the `SystemConfiguration` framework in the active target's "Link Binary With Library" build phase, and add `#import <SystemConfiguration/SystemConfiguration.h>` to the header prefix of the project (`Prefix.pch`).
 */
FOUNDATION_EXPORT NSString * const PLVReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const PLVReachabilityNotificationStatusItem;

///--------------------
/// @name Functions
///--------------------

/**
 Returns a localized string representation of an `PLVReachabilityStatus` value.
 */
FOUNDATION_EXPORT NSString * PLVStringFromNetworkReachabilityStatus(PLVReachabilityStatus status);

NS_ASSUME_NONNULL_END
