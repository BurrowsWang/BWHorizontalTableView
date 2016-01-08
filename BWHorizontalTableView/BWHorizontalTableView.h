//
//  BWHorizontalTableView.h
//  HorizontalTableView
//
//  Created by wangruicheng on 12/26/15.
//  Copyright (c) 2016 Burrows Wang.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "BWHorizontalTableViewDataSource.h"
#import "BWHorizontalTableViewDelegate.h"

#import "NSIndexPath+Column.h"
#import <UIKit/UIKit.h>

@class BWHorizontalTableViewCell;


@interface BWHorizontalTableView : UIScrollView

/*!
 * The data source must adopt the BWHorizontalTableViewDataSource protocol. The data source is not retained.
 */
@property (nullable, nonatomic, weak) id<BWHorizontalTableViewDataSource> dataSource;

/*!
 * The delegate must adopt the BWHorizontalTableViewDelegate protocol. The delegate is not retained.
 */
@property (nullable, nonatomic, weak) id<BWHorizontalTableViewDelegate> delegate;


/*!
 * The number of sections in the table view.
 */
@property (nonatomic, readonly) NSInteger numberOfSections;

/*!
 * The table cells that are visible in the table view.
 */
@property(nullable, nonatomic, readonly) NSArray<__kindof BWHorizontalTableViewCell*> *visibleCells;

/*!
 * An array of index paths each identifying a visible column in the table view.
 */
@property(nullable, nonatomic, readonly) NSArray<NSIndexPath *> *indexPathsForVisibleColumns;

/*!
 * The width of each column (that is, table cell) in the table view. The default value is 44.0.
 * This nonnegative value is used only if the delegate doesn’t implement the horizontalTableView:widthForColumnAtIndexPath: method.
 */
@property (nonatomic, assign) CGFloat columnWidth;

/*!
 * The width of section headers in the table view. The default value is 0.
 * This nonnegative value is used only if the delegate doesn’t implement the horizontalTableView:widthForHeaderInSection: method.
 */
@property (nonatomic, assign) CGFloat sectionHeaderWidth;

/*!
 * The width of section footers in the table view. The default value is 0.
 * This nonnegative value is used only if the delegate doesn’t implement the horizontalTableView:widthForFooterInSection: method.
 */
@property (nonatomic, assign) CGFloat sectionFooterWidth;


/*!
 * Returns the number of columns (table cells) in a specified section.
 * @param section An index number that identifies a section of the table.
 * @return The number of columns in the section.
 */
- (NSInteger)numberOfColumnsInSection:(NSInteger)section;

/*!
 * Call this method to reload all the data that is used to construct the table, including cells, section headers and footers, and so on.
 */
- (void)reloadData;

/*!
 * Returns a reusable table-view cell object located by its identifier.
 * If no cell is available for reuse, this method returns nil.
 * @param identifier A string identifying the cell object to be reused. This parameter must not be nil.
 * @return A BWHorizontalTableViewCell object with the associated identifier or nil if no such object exists in the reusable-cell queue.
 */
- (nullable __kindof BWHorizontalTableViewCell *)dequeueReusableCellWithIdentifier:(nullable NSString *)identifier;

/*!
 * Returns the table cell at the specified index path.
 * @param indexPath The index path locating the column in the table view.
 * @return An object representing a cell of the table, or nil if the cell is not visible or indexPath is out of range.
 */
- (nullable __kindof BWHorizontalTableViewCell *)cellForColumnAtIndexPath:(nonnull NSIndexPath *)indexPath;

/*!
 * Returns an index path representing the column and section of a given table-view cell.
 * @param cell A cell object of the table view.
 * @return An index path representing the column and section of the cell, or nil if the index path is invalid.
 */
- (nullable NSIndexPath *)indexPathForCell:(nonnull BWHorizontalTableViewCell *)cell;

/*!
 * Returns the drawing area for a column identified by index path.
 * @param indexPath An index path object that identifies a column by its index and its section index.
 * @return A rectangle defining the area in which the table view draws the column or CGRectZero if indexPath is invalid.
 */
- (CGRect)rectForColumnAtIndexPath:(nonnull NSIndexPath *)indexPath;

/*!
 * Scrolls through the table view until a column identified by index path is at a particular location on the screen.
 * @param indexPath An index path that identifies a column in the table view by its column index and its section index.
 * @param animated YES if you want to animate the change in position; NO if it should be immediate.
 */
- (void)scrollToColumnAtIndexPath:(nonnull NSIndexPath *)indexPath animated:(BOOL)animated;

@end
