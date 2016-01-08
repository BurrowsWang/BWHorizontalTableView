//
//  BWHorizontalTableViewDataSource.h
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
