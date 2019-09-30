//
//  SonViewController.h
//  SliderSwitch
//
//  Created by kkmm on 2018/10/16.
//  Copyright © 2018 kkmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "SliderSwitchProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface SonViewController : UIViewController <SliderSwitchProtocol>
@property(nonatomic, weak) ViewController *delegateVC;
@property(nonatomic, strong) UILabel *titleLab;
@property(nonatomic, strong) NSString *titleLabStr;

@end

NS_ASSUME_NONNULL_END
