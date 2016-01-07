//
//  NSIndexPath+Column.h
//  HorizontalTableView
//
//  Created by wangruicheng on 12/26/15.
//  Copyright © 2015 burrowswang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (Column)

/*!
 * An index number identifying a column in a section of a table view.
 */
@property (nonatomic, readonly) NSInteger column;

/*!
 * Returns an index-path object initialized with the indexes of a specific column and section in a table view.
 * @param column An index number identifying a column in a BWHorizontalTableView object in a section identified by section.
 * @param section An index number identifying a section in a BWHorizontalTableView object.
 * @return An NSIndexPath object.
 */
+ (NSIndexPath *)indexPathForColumn:(NSInteger)column inSection:(NSInteger)section;

@end
