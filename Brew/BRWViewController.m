//
//  BRWViewController.m
//  Brew
//
//  Created by Katie Porter on 4/30/14.
//  Copyright (c) 2014 Tivona & Porter. All rights reserved.
//

#import "BRWViewController.h"

@interface BRWViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation BRWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImage *image = [UIImage imageNamed:@"Excited"];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    
    [self.view addSubview:self.imageView];
    
    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(153));
        make.height.equalTo(@(196));
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
