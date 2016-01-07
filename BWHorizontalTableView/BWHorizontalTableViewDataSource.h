//
//  BWHorizontalTableViewDataSource.h
//  HorizontalTableView
//
//  Created by wangruicheng on 12/26/15.
//  Copyright © 2015 burrowswang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class BWHorizontalTableView;
@class BWHorizontalTableViewCell;

@protocol BWHorizontalTableViewDataSource <NSObject>

@required

/*!
 * Asks the data source to return the number of sections in the table view.
 * @param tableView An object representing the table view requesting this information.
 * @return The number of sections in tableView. The default value is 1.
 */
- (NSInteger)numberOfSectionsInHorizontalTableView:(BWHorizontalTableView *)tableView;

/*!
 * Tells the data source to return the number of columns in a given section of a table view.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return The number of columns in section.
 */
- (NSInteger)horizontalTableView:(BWHorizontalTableView *)tableView
        numberOfColumnsInSection:(NSInteger)section;

/*!
 * Asks the data source for a cell to insert in a particular location of the table view.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a column in tableView.
 * @return An object inheriting from BWHorizontalTableViewCell that the table view can use for the specified column. An assertion is raised if you return nil.
 */
- (BWHorizontalTableViewCell *)horizontalTableView:(BWHorizontalTableView *)tableView
                          cellForColumnAtIndexPath:(NSIndexPath *)indexPath;

@end
