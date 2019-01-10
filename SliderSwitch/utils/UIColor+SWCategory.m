//
//  UIColor+SWCategory.m
//  SliderSwitch
//
//  Created by kkmm on 2019/1/8.
//  Copyright © 2019 kkmm. All rights reserved.
//

#import "UIColor+SWCategory.h"

@implementation UIColor (SWCategory)
+(UIColor *)redomColor{
	return  [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
}
@end
