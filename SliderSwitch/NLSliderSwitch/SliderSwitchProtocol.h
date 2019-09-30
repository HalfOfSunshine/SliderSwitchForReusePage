//
//  NLSliderSwotchProtocol.h
//  SliderSwitch
//
//  Created by kkmm on 2018/10/16.
//  Copyright © 2018 kkmm. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <objc/objc-api.h>

#ifndef SliderSwitchProtocol_h
#define SliderSwitchProtocol_h
@protocol SliderSwitchProtocol<NSObject>

/**
 是否为当前可见VC
 实现协议的类加上：
 @synthesize isVisiableVC;
 */
@property (nonatomic,readonly) BOOL isVisiableVC;

/**
 是否以页卡的方式展示
 实现协议的类加上：
 @synthesize showAsPageCard;
 */
@property (nonatomic) BOOL showAsPageCard;

/*! 滑动到当前子页面*/
-(void)viewDidScrollToVisiableArea DEPRECATED_MSG_ATTRIBUTE("使用 sliderSwitchDidEndDecelerating: 替换此方法:"); ;

/*! 当前页面离开显示页*/
-(void)viewDidScrollToUnVisiableArea DEPRECATED_MSG_ATTRIBUTE("使用 sliderSwitchWillBeginDragging: 替换此方法:");//使用 sliderSwitchWillBeginDragging: 替换此方法:

/*! 当前页面从不可见页面滑动到可显示的左右页面*/
-(void)viewDidScrollToSideArea DEPRECATED_MSG_ATTRIBUTE("使用 sliderSwitchDidEndDecelerating: 替换此方法:");


/*! 开始拖动 仅在isVisiableVC中回调 */
-(void)sliderSwitchWillBeginDragging;

/*! 停止滚动 仅在isVisiableVC中回调 */
-(void)sliderSwitchDidEndDecelerating;

/*! sliderSwitch请求刷新当前页面 主要用于点击menubar调用刷新数据方法 */
-(void)sliderSwitchRequestRefresh;
@end


#endif /* SliderSwitchProtocol_h */
