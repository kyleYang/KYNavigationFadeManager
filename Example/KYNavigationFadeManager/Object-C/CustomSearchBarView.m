//
//  CustomSearchBarView.m
//  lexiwed2
//
//  Created by IOS开发 on 2017/3/18.
//  Copyright © 2017年 乐喜网. All rights reserved.
//

#import "CustomSearchBarView.h"

@interface CustomSearchBarView ()

@end

@implementation CustomSearchBarView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.searchBar = [[UITextField alloc]init];
        self.searchBar.layer.cornerRadius = 14.0;
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false;
        self.searchBar.clipsToBounds = YES;
        self.searchBar.font = [UIFont systemFontOfSize:13.0];
        self.searchBar.textColor = [UIColor darkGrayColor];
        self.searchBar.returnKeyType = UIReturnKeyYahoo;
        self.searchBar.textAlignment = NSTextAlignmentLeft;
        self.searchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.searchBar.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
        [self addSubview:self.searchBar];
        
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)];
        leftView.backgroundColor = [UIColor clearColor];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sousou_ss"]];
        imgView.frame = CGRectMake(8, 6, 16, 16);
        [leftView addSubview:imgView];
        self.searchBar.leftView = leftView;
        self.searchBar.leftViewMode = UITextFieldViewModeAlways;
        self.searchBar.clearButtonMode = UITextFieldViewModeWhileEditing;

        NSDictionary *views = @{@"bar":self.searchBar};

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[bar]|" options:0 metrics:nil views:views]];
         [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bar]|" options:0 metrics:nil views:views]];
    }
    return self;
}

@end
