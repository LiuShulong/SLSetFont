//
//  ViewController.m
//  SLSetFont
//
//  Created by LiuShulong on 4/5/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "ViewController.h"

#import "UILabel+SLWebFont.h"

#import "UIButton+SLWebFont.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *testButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 60)];
    label.text = @"字体下载测试";
    [self.view addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor redColor];
    
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 280, 60)];
    label2.text = @"字体2";
    [self.view addSubview:label2];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor cyanColor];
    
    NSArray * fontNames = [[NSArray alloc] initWithObjects:
                           @"STXingkai-SC-Light",
                           @"DFWaWaSC-W5",
                           @"FZLTXHK--GBK1-0",
                           @"STLibian-SC-Regular",
                           @"LiHeiPro",
                           @"HiraginoSansGB-W3",
                           nil];
    
    [label sl_setFontWithFontName:fontNames[0] size:14];
    [label2 sl_setFontWithFontName:fontNames[3] size:16];
    
    [_testButton sl_setFontWithFontName:fontNames[2] size:15];
//11111
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
