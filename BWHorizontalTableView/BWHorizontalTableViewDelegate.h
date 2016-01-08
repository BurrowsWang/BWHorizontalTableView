//
//  BWHorizontalTableViewDelegate.h
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

#import <UIKit/UIKit.h>

@class BWHorizontalTableView;
@class BWHorizontalTableViewCell;

@protocol BWHorizontalTableViewDelegate <UIScrollViewDelegate>

@optional

/*!
 * Asks the delegate for the width to use for a column in a specified location.
 * @param tableView The table-view object requesting this information.
 * @param indexPath An index path that locates a column in tableView.
 * @return A nonnegative floating-point value that specifies the width (in points) that column should be.
 */
- (CGFloat)horizontalTableView:(BWHorizontalTableView *)tableView
     widthForColumnAtIndexPath:(NSIndexPath *)indexPath;

/*!
 * Asks the delegate for the width to use for the header of a particular section.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section of tableView.
 * @return A nonnegative floating-point value that specifies the width (in points) of the header for section.
 */
- (CGFloat)horizontalTableView:(BWHorizontalTableView *)tableView
       widthForHeaderInSection:(NSInteger)section;

/*!
 * Asks the delegate for the width to use for the footer of a particular section.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section of tableView.
 * @return A nonnegative floating-point value that specifies the width (in points) of the footer for section.
 */
- (CGFloat)horizontalTableView:(BWHorizontalTableView *)tableView
       widthForFooterInSection:(NSInteger)section;

/*!
 * Asks the delegate for a view object to display in the header of the specified section of the table view.
 * @param tableView The table-view object asking for the view object.
 * @param section An index number identifying a section of tableView.
 * @return A view object to be displayed in the header of section.
 */
- (UIView *)horizontalTableView:(BWHorizontalTableView *)tableView
         viewForHeaderInSection:(NSInteger)section;

/*!
 * Asks the delegate for a view object to display in the footer of the specified section of the table view.
 * @param tableView The table-view object asking for the view object.
 * @param section An index number identifying a section of tableView.
 * @return A view object to be displayed in the footer of section.
 */
- (UIView *)horizontalTableView:(BWHorizontalTableView *)tableView
         viewForFooterInSection:(NSInteger)section;

/*!
 * Tells the delegate the table view is about to draw a cell for a particular column.
 * @param tableView The table-view object informing the delegate of this impending event.
 * @param cell A BWHorizontalTableViewCell object that tableView is going to use when drawing the column.
 * @param indexPath An index path locating the column in tableView.
 */
- (void)horizontalTableView:(BWHorizontalTableView *)tableView
            willDisplayCell:(BWHorizontalTableViewCell *)cell
       forColumnAtIndexPath:(NSIndexPath *)indexPath;

/*!
 * Tells the delegate that a header view is about to be displayed for the specified section.
 * @param tableView The table-view object informing the delegate of this event.
 * @param view The header view that is about to be displayed.
 * @param section An index number identifying a section of tableView.
 */
- (void)horizontalTableView:(BWHorizontalTableView *)tableView
      willDisplayHeaderView:(UIView *)view
                 forSection:(NSInteger)section;

/*!
 * Tells the delegate that a footer view is about to be displayed for the specified section.
 * @param tableView The table-view object informing the delegate of this event.
 * @param view The footer view that is about to be displayed.
 * @param section An index number identifying a section of tableView.
 */
- (void)horizontalTableView:(BWHorizontalTableView *)tableView
      willDisplayFooterView:(UIView *)view
                 forSection:(NSInteger)section;

/*!
 * Tells the delegate that the specified column is now selected.
 * @param tableView A table-view object informing the delegate about the new column selection.
 * @param indexPath An index path locating the new selected column in tableView.
 */
- (void)horizontalTableView:(BWHorizontalTableView *)tableView
 didSelectColumnAtIndexPath:(NSIndexPath *)indexPath;

@end
