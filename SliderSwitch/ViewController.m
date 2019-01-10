//
//  ViewController.m
//  SliderSwitch
//
//  Created by kkmm on 2018/10/16.
//  Copyright © 2018 kkmm. All rights reserved.
//

#import "ViewController.h"
#import "SonViewController.h"
#import "NLSliderSwitch.h"
#import "UIColor+SWCategory.h"
#import "SWModel.h"
#define KScreen [UIScreen mainScreen].bounds.size
#define TopBarHeight (([UIScreen mainScreen].bounds.size.height >= 812.0) ? 88.f : 64.f)
@interface ViewController ()<NLSliderSwitchDelegate,UIScrollViewDelegate>
//数据源
@property (nonatomic, strong) NSMutableArray <SWModel *>* listArray;

//滚动页面，左右滑动切换页面
@property (nonatomic, strong) UIScrollView * backScrollV;

//页签控件
@property (nonatomic, strong) NLSliderSwitch *sliderSwitch;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationController.navigationBar.translucent = YES;
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
	[self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:30/255. green:144/255. blue:255/255. alpha:1.]];
	self.titleCount = 10;
	[self setUI];
	
}

- (void)setUI
{
	self.backScrollV.backgroundColor = [UIColor greenColor];
	
	self.sliderSwitch = [[NLSliderSwitch alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40) buttonSize:CGSizeMake(53, 30)];
	self.listArray = [[NSMutableArray alloc]init];
	for (NSInteger i=0; i<self.titleCount; i++) {
		SWModel *model = [[SWModel alloc]init];
		model.title = [NSString stringWithFormat:@"%ld",(long)i];
		[self.listArray addObject:model];
	}
	self.sliderSwitch.dataArray = self.listArray;
	self.sliderSwitch.normalTitleColor = [UIColor whiteColor];
	self.sliderSwitch.selectedTitleColor = [UIColor whiteColor];
	self.sliderSwitch.selectedButtonColor = [UIColor whiteColor];
	self.sliderSwitch.titleFont = [UIFont systemFontOfSize:15];
	self.sliderSwitch.backgroundColor = [UIColor clearColor];
	self.sliderSwitch.delegate = (id)self;
	self.navigationItem.titleView = self.sliderSwitch;
	self.backScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, TopBarHeight, KScreen.width,KScreen.height-TopBarHeight)];
	self.backScrollV.pagingEnabled = YES;
	self.backScrollV.showsVerticalScrollIndicator = NO;
	self.backScrollV.showsHorizontalScrollIndicator = NO;
	self.backScrollV.bounces = NO;
	self.backScrollV.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.backScrollV];
	self.backScrollV.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * self.sliderSwitch.dataArray.count, 1);//禁止竖向滚动
//	[self.sliderSwitch slideToIndex:5];
//	[self.backScrollV scrollRectToVisible:CGRectMake(5*KScreen.width,0, KScreen.width, 1) animated:YES];
	self.sliderSwitch.containerScroll = self.backScrollV;

	
}


-(UIViewController <NLSliderSwitchProtocol>*)sliderSwitch:(NLSliderSwitch *)sliderSwitch setSubViewControllerInIndex:(NSInteger)index{
	SonViewController *sonViewController = [[SonViewController alloc]init];
	sonViewController.delegateVC = self;
	[self addChildViewController:sonViewController];
	[sonViewController.view setFrame:CGRectMake(index*KScreen.width, 0, KScreen.width, self.backScrollV.frame.size.height)];
	sonViewController.view.backgroundColor = [UIColor redomColor];
	sonViewController.titleLabStr = [NSString stringWithFormat:@"%li",(long)index];
	return sonViewController;
}

-(void)sliderSwitch:(NLSliderSwitch *)sliderSwitch didSelectedIndex:(NSInteger)selectedIndex{
	
}

@end
