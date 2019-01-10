//
//  SonViewController.m
//  SliderSwitch
//
//  Created by kkmm on 2018/10/16.
//  Copyright © 2018 kkmm. All rights reserved.
//

#import "SonViewController.h"
@interface SonViewController ()

@end

@implementation SonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(150, 150, 150, 150)];
	[self.titleLab setBackgroundColor:[UIColor redColor]];
	[self.view addSubview:self.titleLab];
}

-(void)viewDidScrollToVisiableArea{
	NSLog(@"当前滑动到了‘%@’页面",self.title);
}
-(void)setTitleLabStr:(NSString *)titleLabStr{
	_titleLabStr = titleLabStr;
	self.titleLab.text = self.titleLabStr;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
