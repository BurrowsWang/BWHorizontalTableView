//
//  NSIndexPath+Column.m
//  HorizontalTableView
//
//  Created by wangruicheng on 12/26/15.
//  Copyright © 2015 burrowswang. All rights reserved.
//

#import "NSIndexPath+Column.h"

#import <UIKit/UIKit.h>

@implementation NSIndexPath (Column)

- (NSInteger)column {
    return self.row;
}

+ (NSIndexPath *)indexPathForColumn:(NSInteger)column inSection:(NSInteger)section {
    return [NSIndexPath indexPathForRow:column inSection:section];
}

@end
