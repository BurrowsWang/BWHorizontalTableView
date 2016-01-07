//
//  HorizontalTableViewCell.m
//  BWHorizontalTableView Demo
//
//  Created by wangruicheng on 1/1/16.
//  Copyright © 2016 burrowswang. All rights reserved.
//

#import "HorizontalTableViewCell.h"

@interface HorizontalTableViewCell ()

@property (nonatomic, strong) UIImageView           *planetImageView;
@property (nonatomic, strong) UILabel               *planetNameLabel;

@end

@implementation HorizontalTableViewCell

- (void)dealloc {
    NSLog(@"%@", @"One HorizontalTableViewCell deallocated!");
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        NSLog(@"%@", @"One HorizontalTableViewCell created!");
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(10, 10, 64, 64);
        [self addSubview:iconView];
        self.planetImageView = iconView;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(10, 84, 64, 20);
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        [self addSubview:label];
        self.planetNameLabel = label;
    }
    
    return self;
}

- (void)showPlanet:(NSString *)planet {
    self.planetImageView.image = [UIImage imageNamed:planet];
    self.planetNameLabel.text = planet;
}

@end
