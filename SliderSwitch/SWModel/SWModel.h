//
//  SWModel.h
//  SliderSwitch
//
//  Created by kkmm on 2019/1/9.
//  Copyright © 2019 kkmm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLSliderSwitchProtocol.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SWModel : NSObject
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) UIViewController <NLSliderSwitchProtocol>* VC;
@end

NS_ASSUME_NONNULL_END
