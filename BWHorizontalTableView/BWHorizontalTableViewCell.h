//
//  BWHorizontalTableViewCell.h
//  HorizontalTableView
//
//  Created by wangruicheng on 12/26/15.
//  Copyright © 2015 burrowswang. All rights reserved.
//

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
