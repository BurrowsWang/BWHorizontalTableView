//
//  BWHorizontalTableViewCell.h
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

@interface BWHorizontalTableViewCell : UIView

/*!
 * A string used to identify a cell that is reusable.
 */
@property (nonatomic, readonly, copy) NSString              *reuseIdentifier;

/*!
 * The style of selected cells. The default value is UITableViewCellSelectionStyleNone.
 * If the value is something other than UITableViewCellSelectionStyleNone, a translucent mask view will cover the cell when be touched.
 */
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

/*!
 * The color of the mask view. The default value is rgba(128,128,128,0.15).
 */
@property (nonatomic, strong) UIColor                       *maskColor;


/*!
 * Initializes a table cell with a reuse identifier and returns it to the caller.
 * @param reuseIdentifier A string used to identify the cell object if it is to be reused for drawing multiple columns of a table view. Pass nil if the cell object is not to be reused. You should use the same reuse identifier for all cells of the same form.
 */
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

/*!
 * Prepares a reusable cell for reuse by the table view's delegate.
 */
- (void)prepareForReuse;

@end
