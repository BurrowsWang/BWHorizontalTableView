//
//  BWHorizontalTableView.m
//  HorizontalTableView
//
//  Created by wangruicheng on 12/26/15.
//  Copyright © 2015 burrowswang. All rights reserved.
//

#import "BWHorizontalTableView.h"

#import "BWHorizontalTableViewCell.h"

#import <objc/runtime.h>

// width for the buffer area outside visible zone
#define kBWOuterEdge 15

#define kBWDefaultColumnWidth 44.0f
#define kBWDefaultSectionNumber 1

// the key for indexpath stored in every cell
static void* const kBWCellIndexPathKey = "__BWCellIndexPath__";

// the key for cursor info stored in section header and footer container views
static void* const kBWSectionCursorKey = "__BWSectionCursor";
// this key indicate the cursor is section header or footer
static NSString* const kBWIsSectionHeaderKey = @"__BWIsSectionHeader__";
// this key indicate the index in the section cursor
static NSString* const kBWSectionIndexKey = @"__BWSectionIndex__";


#pragma mark - struct BWHrange

typedef NS_ENUM(NSInteger, HrangeIntersectResult) {
    HrangeIntersectOverlap = 1, // the two horizontal range overlapped
    HrangeIntersectNoneLeft = -1, // one is on the left side of another
    HrangeIntersectNoneRight = -2 // one is on the right side of another
};

/*!
 * Struct that representing Horizontal Range.
 * left represents left edge.
 * right represents right edge.
 */
struct BWHrange {
    CGFloat left;
    CGFloat right;
};
typedef struct BWHrange BWHrange;

/*!
 * make a horizontal range with its left and right edge
 */
NS_INLINE BWHrange BWMakeHrange(CGFloat left, CGFloat right) {
    BWHrange hrange;
    hrange.left = left;
    hrange.right = right;
    
    return hrange;
}

/*!
 * Try to intersect two horizontal range, detect whether they are overlapped or not.
 * If the two ranges are overlapped, HrangeIntersectOverlap is returned.
 * If the tgtRange range is one the left side of referRange, HrangeIntersectNoneLeft is returned.
 * Otherwise HrangeIntersectNoneRight is returned.
 */
NS_INLINE HrangeIntersectResult HrangeIntersectsHrange(BWHrange referRange, BWHrange tgtRange) {
    if ((tgtRange.left < referRange.left && tgtRange.right < referRange.left)) {
        return HrangeIntersectNoneLeft;
    } else if (tgtRange.left > referRange.right && tgtRange.right > referRange.right) {
        return HrangeIntersectNoneRight;
    } else {
        return HrangeIntersectOverlap;
    }
}


#pragma mark - class DelegateProxy

/*!
 * DelegateProxy is actually a agent between the real scroll view delegate and a interceptor.
 * All methods of UIScrollViewDelegate will be fowarded to the real delegate except the method scrollViewDidScroll:,
 * which will be handled by the interceptor.
 */
@interface DelegateProxy : NSProxy <UIScrollViewDelegate>

/*!
 * The method scrollViewDidScroll: will be handled by interceptor.
 * WARNING: must not retain here
 */
@property (nonatomic, weak) NSObject *interceptor;

/*!
 * All other methods will be handled by the real delegate.
 * WARNING: must not retain here
 */
@property (nonatomic, weak) NSObject<BWHorizontalTableViewDelegate> *realDelegate;

@end


@implementation DelegateProxy

- (void)dealloc {
    
}

- (instancetype)initWithInterceptor:(NSObject *)interceptor
                       realDelegate:(NSObject<BWHorizontalTableViewDelegate> *)realDelegate {
    self.interceptor = interceptor;
    self.realDelegate = realDelegate;
    
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (sel == @selector(scrollViewDidScroll:)) {
        // return the interceptor's signature of this method
        return [self.interceptor methodSignatureForSelector:sel];
    } else {
        return [self.realDelegate methodSignatureForSelector:sel];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (invocation.selector == @selector(scrollViewDidScroll:)) {
        // agent scrollViewDidScroll: to the interceptor
        [invocation setTarget:self.interceptor];
    } else {
        [invocation setTarget:self.realDelegate];
    }
    
    [invocation invoke];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(scrollViewDidScroll:)) {
        return YES;
    }
    
    return [self.realDelegate respondsToSelector:aSelector];
}

@end


#pragma mark - BWHorizontalTableView Implementation

@interface BWHorizontalTableView ()

// stores the cells which are currently presented on the visible zone
@property (nonatomic, strong) NSMutableArray *onscreenCells;
// stores the cells that have been created but not on screen now
@property (nonatomic, strong) NSMutableDictionary *offscreenCells;

// stores the header and footer containers which are currently on the screen
@property (nonatomic, strong) NSMutableArray *onscreenHeaderFooters;
// stores the header and footer container which are currently not on the screen
@property (nonatomic, strong) NSMutableSet *offscreenHeaderFooters;

// an agent between the real delegate and scrollViewDidScroll: handler
@property (nonatomic, strong) DelegateProxy *delegateProxy;

@end

@implementation BWHorizontalTableView {
    // As variable '_delegate' is a member of the super class UIScrollView,
    // we use '__delegate' here instead.
    __weak id<BWHorizontalTableViewDataSource>          __dataSource;
    __weak id<BWHorizontalTableViewDelegate>            __delegate;
}

- (void)dealloc {
    
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self reloadData];
}

- (void)setup {
    self.alwaysBounceVertical = NO;
    self.alwaysBounceHorizontal = YES;
    self.directionalLockEnabled = YES;
    
    // setup default values
    self.columnWidth = kBWDefaultColumnWidth;
    self.sectionHeaderWidth = 0.0f;
    self.sectionFooterWidth = 0.0f;
}

#pragma mark - Properties

- (void)setDataSource:(id<BWHorizontalTableViewDataSource>)dataSource {
    __dataSource = dataSource;
    
    // clear all the subviews first
    [self clearSubViews:self];
    
    /* clear these collections */
    if (self.onscreenCells) {
        [self.onscreenCells removeAllObjects];
    } else {
        self.onscreenCells = [NSMutableArray array];
    }
    
    if (self.offscreenCells) {
        [self.offscreenCells removeAllObjects];
    } else {
        self.offscreenCells = [NSMutableDictionary dictionary];
    }
    
    if (self.onscreenHeaderFooters) {
        [self.onscreenHeaderFooters removeAllObjects];
    } else {
        self.onscreenHeaderFooters = [NSMutableArray array];
    }
    
    if (self.offscreenHeaderFooters) {
        [self.offscreenHeaderFooters removeAllObjects];
    } else {
        self.offscreenHeaderFooters = [NSMutableSet set];
    }
}

- (id<BWHorizontalTableViewDataSource>)dataSource {
    return __dataSource;
}

- (void)setDelegate:(id<BWHorizontalTableViewDelegate>)delegate {
    __delegate = delegate;
    
    if (delegate) {
        // make an agent to act as delegate of UIScrollView
        self.delegateProxy = [[DelegateProxy alloc] initWithInterceptor:self
                                                           realDelegate:__delegate];
    } else {
        self.delegateProxy = nil;
    }
    
    super.delegate = self.delegateProxy;
}

- (id<BWHorizontalTableViewDelegate>)delegate {
    return __delegate;
}

- (NSInteger)numberOfSections {
    if ([__dataSource respondsToSelector:@selector(numberOfSectionsInHorizontalTableView:)]) {
        return [__dataSource numberOfSectionsInHorizontalTableView:self];
    }
    
    return kBWDefaultSectionNumber;
}

- (NSArray<__kindof BWHorizontalTableViewCell*> *)visibleCells {
    if ([self.onscreenCells count] > 0) {
        return [NSArray arrayWithArray:self.onscreenCells];
    }
    
    return nil;
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleColumns {
    if ([self.onscreenCells count] > 0) {
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[self.onscreenCells count]];
        
        for (BWHorizontalTableViewCell *cell in self.onscreenCells) {
            NSIndexPath *indexPath = [self indexPathForCell:cell];
            
            if (indexPath) {
                [indexPaths addObject:indexPath];
            }
        }
        
        return [NSArray arrayWithArray:indexPaths];
    }
    
    return nil;
}

#pragma mark - Public Methods

- (void)reloadData {
    // calculate the content size
    CGFloat totalWidth = [self calculateTotalWidth];
    [self setContentSize:CGSizeMake(totalWidth, self.frame.size.height)];
    
    // adjust offset position
    CGPoint contentOffset = self.contentOffset;
    if (contentOffset.x < 0) {
        contentOffset.x = 0;
        [super setContentOffset:contentOffset];
    } else if (contentOffset.x + self.frame.size.width > totalWidth) {
        contentOffset.x = totalWidth - self.frame.size.width;
        [super setContentOffset:contentOffset];
    }

    // recycle all existing cells
    for (NSInteger i = [self.onscreenCells count] - 1; i >= 0; i--) {
        BWHorizontalTableViewCell *onscreenCell = self.onscreenCells[i];
        [onscreenCell removeFromSuperview];
        [self.onscreenCells removeObjectAtIndex:i];
        
        [self pushCellToOffscreenRepository:onscreenCell];
    }
    
    // recycle all existing header footer containers
    for (NSInteger j = [self.onscreenHeaderFooters count] - 1; j >= 0; j--) {
        UIView *containerView = self.onscreenHeaderFooters[j];
        [self clearSubViews:containerView];
        [containerView removeFromSuperview];
        [self.onscreenHeaderFooters removeObjectAtIndex:j];
        
        [self.offscreenHeaderFooters addObject:containerView];
    }
    
    [self renderOnscreenCells];
}

- (__kindof BWHorizontalTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    NSAssert(identifier != nil, @"CellIdentifier can not be null!");
    
    // look up cells which same identifier
    NSSet *idleCells = self.offscreenCells[identifier];
    if (idleCells) {
        BWHorizontalTableViewCell *cell = [idleCells anyObject];
        
        // tell cell that it will be reused soon
        [cell prepareForReuse];
        
        return cell;
    } else {
        return nil;
    }
}

- (__kindof BWHorizontalTableViewCell *)cellForColumnAtIndexPath:(NSIndexPath *)indexPath {
    // loop up from cells which are currently on screen
    for (BWHorizontalTableViewCell *cell in self.onscreenCells) {
        NSIndexPath *cellIndexPath = [self indexPathForCell:cell];
        
        if ([cellIndexPath isEqual:indexPath]) {
            return cell;
        }
    }
    
    return nil;
}

- (NSInteger)numberOfColumnsInSection:(NSInteger)section {
    if ([__dataSource respondsToSelector:@selector(horizontalTableView:numberOfColumnsInSection:)]) {
        return [__dataSource horizontalTableView:self numberOfColumnsInSection:section];
    }
    
    return 0;
}

- (NSIndexPath *)indexPathForCell:(BWHorizontalTableViewCell *)cell {
    NSAssert(cell != nil, @"Cell can not be null!");
    
    return (NSIndexPath *)objc_getAssociatedObject(cell, kBWCellIndexPathKey);
}

- (CGRect)rectForColumnAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat offsetX = 0.0f;
    NSInteger sectionCount = [self numberOfSections];
    
    for (NSInteger i = 0; i < sectionCount; i++) {
        offsetX += [self widthForHeaderInSection:i];
        BOOL isThisSection = (indexPath.section == i);
        
        NSInteger columnCount = [self numberOfColumnsInSection:i];
        for (NSInteger j = 0; j < columnCount; j++) {
            CGFloat columnWidth = [self widthForColumnAtIndexPath:[NSIndexPath indexPathForColumn:j inSection:i]];
            
            if (isThisSection && j == indexPath.column) {
                return CGRectMake(offsetX, 0, columnWidth, self.frame.size.height);
            }
            
            offsetX += columnWidth;
        }
        
        offsetX += [self widthForFooterInSection:i];
    }
    
    return CGRectZero;
}

- (void)scrollToColumnAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    CGRect columnRect = [self rectForColumnAtIndexPath:indexPath];
    CGRect wholeRect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    if (CGRectContainsRect(wholeRect, columnRect)) {
        [self scrollRectToVisible:columnRect animated:animated];
    }
}

#pragma mark - Render Onscreen Cells And Recycle Offscreen Cells

/*!
 * Render all the cells which should be on the currently visible zone
 */
- (void)renderOnscreenCells {
    NSInteger sectionCount = [self numberOfSections];
    
    if (sectionCount <= 0) {
        // no section should be rendered
        return;
    }
    
    BWHrange visibleRange = BWMakeHrange(self.contentOffset.x - kBWOuterEdge,
                                         self.contentOffset.x + self.frame.size.width + kBWOuterEdge);
    CGFloat offsetX = 0.0f;
    BOOL stop = NO;

    for (NSInteger i = 0; i < sectionCount; i++) {
        CGFloat headerWidth = [self widthForHeaderInSection:i];
        
        // check if we should render header of this section
        if (headerWidth > 0) {
            BWHrange headerRange = BWMakeHrange(offsetX, offsetX + headerWidth);
            
            // check if we have beyond the visible range
            HrangeIntersectResult intersectResult = HrangeIntersectsHrange(visibleRange, headerRange);
            
            if (intersectResult == HrangeIntersectNoneRight) {
                // do not need to go on, already beyond the visible range
                break;
            } else if (intersectResult == HrangeIntersectOverlap) {
                // render header view for this section
                [self renderHeaderViewForSection:i atHrange:headerRange];
            }
            
            offsetX += headerWidth;
        }
        
        NSInteger columnCount = [self numberOfColumnsInSection:i];
        
        // iterate columns of this section
        for (NSInteger j = 0; j < columnCount; j++) {
            CGFloat columnWidth = [__delegate horizontalTableView:self
                                        widthForColumnAtIndexPath:[NSIndexPath indexPathForColumn:j inSection:i]];
            BWHrange cellRange = BWMakeHrange(offsetX, offsetX + columnWidth);
            
            // check if we have beyond the visible range
            HrangeIntersectResult intersectResult = HrangeIntersectsHrange(visibleRange, cellRange);
            
            if (intersectResult == HrangeIntersectNoneRight) {
                // beyond the visible range, should stop rendering immediately
                stop = YES;
                break;
            } else if (intersectResult == HrangeIntersectOverlap) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForColumn:j inSection:i];
                
                // render cell at index path
                [self renderCellAtIndexPath:indexPath hrange:cellRange];
            }
            
            offsetX += columnWidth;
        }
        
        // check if we have beyond the visible range
        if (stop) {
            break;
        }
        
        CGFloat footerWidth = [self widthForFooterInSection:i];
        
        // check if we need to render the footer of this section
        if (footerWidth > 0) {
            BWHrange footerRange = BWMakeHrange(offsetX, offsetX + footerWidth);
            
            // check if we have beyond the visible range
            HrangeIntersectResult intersectResult = HrangeIntersectsHrange(visibleRange, footerRange);
            
            if (intersectResult == HrangeIntersectNoneRight) {
                // beyond the visible range, stop rendering
                break;
            } else if (intersectResult == HrangeIntersectOverlap) {
                // render footer of this section
                [self renderFooterViewForSection:i atHrange:footerRange];
            }
            
            offsetX += footerWidth;
        }
    }
}

/*!
 * recycle all cells and header footers which are beyond visible zone but still been rendered
 */
- (void)recycleOffscreenCells {
    BWHrange visibleRange = BWMakeHrange(self.contentOffset.x - kBWOuterEdge,
                                         self.contentOffset.x + self.frame.size.width + kBWOuterEdge);
    
    for (NSInteger i = [self.onscreenCells count] - 1; i >= 0; i--) {
        BWHorizontalTableViewCell *onscreenCell = self.onscreenCells[i];
        
        // check if it is beyond the visible range
        if (CGRectGetMaxX(onscreenCell.frame) < visibleRange.left
            || onscreenCell.frame.origin.x > visibleRange.right) {
            // remove it from screen and repository
            [onscreenCell removeFromSuperview];
            [self.onscreenCells removeObjectAtIndex:i];
            
            // store it to offscreen repository
            [self pushCellToOffscreenRepository:onscreenCell];
        }
    }
    
    // recycle header and footer containers as well
    for (NSInteger j = [self.onscreenHeaderFooters count] - 1; j >= 0; j--) {
        UIView *headerFooterContainer = self.onscreenHeaderFooters[j];
        
        // check if it is beyond the visible range
        if (CGRectGetMaxX(headerFooterContainer.frame) < visibleRange.left
            || headerFooterContainer.frame.origin.x > visibleRange.right) {
            // remove it from screen and repository
            [self clearSubViews:headerFooterContainer];
            [headerFooterContainer removeFromSuperview];
            [self.onscreenHeaderFooters removeObjectAtIndex:j];
            
            // store it to offscreen repository
            [self.offscreenHeaderFooters addObject:headerFooterContainer];
        }
    }
}

/*!
 * render cell of given indexPath at hrange
 */
- (void)renderCellAtIndexPath:(NSIndexPath *)indexPath hrange:(BWHrange)hrange {
    // ask for the cell of indexPath
    BWHorizontalTableViewCell *cell = [self.dataSource horizontalTableView:self
                                                  cellForColumnAtIndexPath:indexPath];
    
    // make sure the cell is qualified
    NSAssert(cell != nil, @"Horizontal Cell can not be null!");
    NSAssert([cell isKindOfClass:[BWHorizontalTableViewCell class]],
             @"Horizontal Cell must be subclass of BWHorizontalTableViewCell");
    
    NSString *identifier = cell.reuseIdentifier;
    NSMutableSet *idleCells = self.offscreenCells[identifier];
    
    // remove it from offscreen repository
    [idleCells removeObject:cell];
    
    // render it at the right position
    cell.frame = CGRectMake(hrange.left, 0, hrange.right - hrange.left, self.frame.size.height);
    
    // store indexPath of the cell
    objc_setAssociatedObject(cell, kBWCellIndexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // listen tap event of the cell. WARNING: must not retain here, risk of causing reference cycle.
    objc_setAssociatedObject(cell, "__BWCell_TapListener__", self, OBJC_ASSOCIATION_ASSIGN);
    
    if ([self.delegate respondsToSelector:@selector(horizontalTableView:willDisplayCell:forColumnAtIndexPath:)]) {
        // tell delegate this cell is about to be rendered
        [self.delegate horizontalTableView:self willDisplayCell:cell forColumnAtIndexPath:indexPath];
    }
    
    [self addSubview:cell];
    [self.onscreenCells addObject:cell];
    
    // sort the array by index of cells
    [self.onscreenCells sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        BWHorizontalTableViewCell *leftCell = (BWHorizontalTableViewCell *)obj1;
        BWHorizontalTableViewCell *rightCell = (BWHorizontalTableViewCell *)obj2;
        NSIndexPath *leftIndex = objc_getAssociatedObject(leftCell, kBWCellIndexPathKey);
        NSIndexPath *rightIndex = objc_getAssociatedObject(rightCell, kBWCellIndexPathKey);
        
        return [leftIndex compare:rightIndex];
    }];
}

- (void)renderHeaderViewForSection:(NSInteger)section atHrange:(BWHrange)hrange {
    UIView *headerView = [self viewForHeaderInSection:section];
    
    if (headerView) {
        UIView *containerView = [self makeSectionHeaderFooterContainer];
        
        // store section cursor (contains header flag and section index)
        objc_setAssociatedObject(containerView,
                                 kBWSectionCursorKey,
                                 @{kBWIsSectionHeaderKey: @(YES), kBWSectionIndexKey: @(section)},
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // tell delegate that headerView is about to be displayed
        if ([__delegate respondsToSelector:@selector(horizontalTableView:willDisplayHeaderView:forSection:)]) {
            [__delegate horizontalTableView:self willDisplayHeaderView:headerView forSection:section];
        }
        
        // render the real headerView in reusable containerView
        [self renderHeaderFooterView:headerView inContainer:containerView atHrange:hrange];
    }
}

- (void)renderFooterViewForSection:(NSInteger)section atHrange:(BWHrange)hrange {
    UIView *footerView = [self viewForFooterInSection:section];
    
    if (footerView) {
        UIView *containerView = [self makeSectionHeaderFooterContainer];
        
        // store section cursor (contains footer flag and section index)
        objc_setAssociatedObject(containerView,
                                 kBWSectionCursorKey,
                                 @{kBWIsSectionHeaderKey: @(NO), kBWSectionIndexKey: @(section)},
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // tell delegate that footerView is about to be displayed
        if ([__delegate respondsToSelector:@selector(horizontalTableView:willDisplayFooterView:forSection:)]) {
            [__delegate horizontalTableView:self willDisplayFooterView:footerView forSection:section];
        }
        
        // render the real footerView in reusable containerView
        [self renderHeaderFooterView:footerView inContainer:containerView atHrange:hrange];
    }
}

- (void)renderHeaderFooterView:(UIView *)headerFooter
                   inContainer:(UIView *)container
                      atHrange:(BWHrange)hrange {
    container.frame = CGRectMake(hrange.left, 0, hrange.right - hrange.left, self.frame.size.height);
    [container addSubview:headerFooter];
    
    [self addSubview:container];
    
    [self.onscreenHeaderFooters addObject:container];
    
    // sort header footer containers by position x
    [self.onscreenHeaderFooters sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UIView *leftContainer = (UIView *)obj1;
        UIView *rightContainer = (UIView *)obj2;
        
        if (leftContainer.frame.origin.x < rightContainer.frame.origin.x) {
            return NSOrderedAscending;
        } else if (leftContainer.frame.origin.x > rightContainer.frame.origin.x) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

#pragma mark - Handle ScrollViewDidScroll Event

// this is an intermediate interceptor
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // recycle cells and header footer containers which are beyond visible range now first
    [self recycleOffscreenCells];
    
    if ([self.onscreenCells count] == 0) {
        // if no one is currently rendered, reload cells according to current visible range
        [self renderOnscreenCells];
        return;
    }
    
    BWHrange visibleRange = BWMakeHrange(self.contentOffset.x - kBWOuterEdge,
                                         self.contentOffset.x + self.frame.size.width + kBWOuterEdge);
    
    BOOL reachedLeftest = NO;
    while (!reachedLeftest) {
        // render until the leftest cell or header is beyond visible range
        reachedLeftest = [self renderLeftestCellInVisibleRange:visibleRange];
    }
    
    BOOL reachedRightest = NO;
    while (!reachedRightest) {
        // render until the rightest cell or footer is beyond visible range
        reachedRightest = [self renderRightestCellInVisibleRange:visibleRange];
    }

    if ([__delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [__delegate scrollViewDidScroll:scrollView];
    }
}

- (BOOL)renderLeftestCellInVisibleRange:(BWHrange)visibleRange {
    // find the leftest view on screen now
    BWHorizontalTableViewCell *leftestCell = [self.onscreenCells firstObject];
    UIView *leftestHeader = [self.onscreenHeaderFooters firstObject];
    
    CGFloat leftestCellX = leftestCell ? leftestCell.frame.origin.x : visibleRange.right;
    CGFloat leftestHeaderX = leftestHeader ? leftestHeader.frame.origin.x : visibleRange.right;
    CGFloat leftestX = fminf(leftestCellX, leftestHeaderX);
    
    if (leftestX < visibleRange.left) {
        // the leftest view is already beyond visible range
        return YES;
    }

    NSIndexPath *lefterIndexPath = nil;
    
    // check if the leftest view is header container or cell
    if (leftestHeaderX < leftestCellX) {
        // get section cursor of this section container
        NSDictionary *sectionCursor = objc_getAssociatedObject(leftestHeader, kBWSectionCursorKey);
        BOOL isHeader = [sectionCursor[kBWIsSectionHeaderKey] boolValue];
        NSInteger section = [sectionCursor[kBWSectionIndexKey] integerValue];
        
        if (isHeader) {
            if (section <= 0) {
                // reached the first section header, no more lefter view
                return YES;
            }
            
            NSInteger preSection = section - 1;
            
            // render the footer of the previous section
            if ([self renderLefterFooterInSection:preSection
                                     withLeftestX:&leftestX
                                     visibleRange:visibleRange]) {
                return YES;
            }
            
            NSInteger columnCount = [self numberOfColumnsInSection:preSection];
            if (columnCount > 0) {
                // get the index path of previous cell
                lefterIndexPath = [NSIndexPath indexPathForColumn:(columnCount - 1)
                                                        inSection:preSection];
            }
        } else {
            // the leftest view is a footer, at it's left side should be a cell
            NSInteger columnCount = [self numberOfColumnsInSection:section];
            
            if (columnCount > 0) {
                // get the index path of the lefter cell
                lefterIndexPath = [NSIndexPath indexPathForColumn:(columnCount - 1)
                                                        inSection:section];
            }
        }
    } else {
        // the leftest view is a cell, we can get its index path here
        NSIndexPath *leftestIndexPath = [self indexPathForCell:leftestCell];
        
        // and get the index path of the lefter cell
        lefterIndexPath = [self leftIndexOfIndex:leftestIndexPath];
        
        // check if the leftest cell is first cell of its section
        if (lefterIndexPath == nil || leftestIndexPath.section != lefterIndexPath.section) {
            // if it is the first cell, render the header of that section
            if ([self renderLefterHeaderInsection:leftestIndexPath.section
                                     withLeftestX:&leftestX
                                     visibleRange:visibleRange]) {
                return YES;
            }
            
            // then render footer for the section previous
            if (lefterIndexPath) {
                if ([self renderLefterFooterInSection:lefterIndexPath.section
                                         withLeftestX:&leftestX
                                         visibleRange:visibleRange]) {
                    return YES;
                }
            }
        }
    }
    
    // no more lefter cells or headers
    if (lefterIndexPath == nil) {
        return YES;
    }

    CGFloat width = [self widthForColumnAtIndexPath:lefterIndexPath];
    BWHrange cellHrange = BWMakeHrange(leftestX - width, leftestX);
    
    // render lefter cell
    [self renderCellAtIndexPath:lefterIndexPath hrange:cellHrange];
    
    leftestX = cellHrange.left;
    
    // then check if the lefter cell is beyond visible range
    if (leftestX < visibleRange.left) {
        return YES;
    }
    
    return NO;
}

- (BOOL)renderRightestCellInVisibleRange:(BWHrange)visibleRange {
    // find the rightest view on screen now
    BWHorizontalTableViewCell *rightestCell = [self.onscreenCells lastObject];
    UIView *rightestFooter = [self.onscreenHeaderFooters lastObject];
    
    CGFloat rightestCellX = rightestCell ? CGRectGetMaxX(rightestCell.frame) : visibleRange.left;
    CGFloat rightestFooterX = rightestFooter ? CGRectGetMaxX(rightestFooter.frame) : visibleRange.left;
    CGFloat rightestX = fmaxf(rightestCellX, rightestFooterX);
    
    if (rightestX > visibleRange.right) {
        // the rightest view is already beyond visible range
        return YES;
    }
    
    NSIndexPath *righterIndexPath = nil;
    
    // check if the rightest view is footer or cell
    if (rightestFooterX > rightestCellX) {
        // get section cursor of the rightest footer
        NSDictionary *sectionCursor = objc_getAssociatedObject(rightestFooter, kBWSectionCursorKey);
        BOOL isHeader = [sectionCursor[kBWIsSectionHeaderKey] boolValue];
        NSInteger section = [sectionCursor[kBWSectionIndexKey] integerValue];
        
        if (isHeader) {
            // the rightest view is a header, so the righter view should be a cell
            NSInteger columnCount = [self numberOfColumnsInSection:section];
            
            if (columnCount > 0) {
                // get the index path of righter cell
                righterIndexPath = [NSIndexPath indexPathForColumn:0 inSection:section];
            }
        } else {
            NSInteger sectionCount = [self numberOfSections];
            
            if (section >= sectionCount - 1) {
                // reached the footer of the last section, no more views on the righter side
                return YES;
            }
            
            NSInteger nextSection = section + 1;
            
            // render the header of next section
            if ([self renderRighterHeaderInSection:nextSection
                                     withRightestX:&rightestX
                                      visibleRange:visibleRange]) {
                return YES;
            }
            
            NSInteger columnCount = [self numberOfColumnsInSection:nextSection];
            if (columnCount > 0) {
                // at the right side of header should be a cell, render the cell of next section
                righterIndexPath = [NSIndexPath indexPathForColumn:0 inSection:nextSection];
            }
        }
    } else {
        // the rightest view is a cell, get the index path of the rightest cell
        NSIndexPath *rightestIndexPath = [self indexPathForCell:rightestCell];
        
        // get the righter index path of this cell
        righterIndexPath = [self rightIndexOfIndex:rightestIndexPath];
        
        // check if the rightest cell is the last cell of its section
        if (righterIndexPath == nil || rightestIndexPath.section != righterIndexPath.section) {
            // if it is the last cell of its section, render footer of that section
            if ([self renderRighterFooterInSection:rightestIndexPath.section
                                     withRightestX:&rightestX
                                      visibleRange:visibleRange]) {
                return YES;
            }
            
            // then render header next to the footer
            if (righterIndexPath) {
                if ([self renderRighterHeaderInSection:righterIndexPath.section
                                         withRightestX:&rightestX
                                          visibleRange:visibleRange]) {
                    return YES;
                }
            }
        }
    }
    
    // no more righter cells or footers
    if (righterIndexPath == nil) {
        return YES;
    }

    CGFloat width = [self widthForColumnAtIndexPath:righterIndexPath];
    BWHrange cellHrange = BWMakeHrange(rightestX, rightestX + width);
    
    // render righter cell
    [self renderCellAtIndexPath:righterIndexPath hrange:cellHrange];
    
    rightestX = cellHrange.right;
    
    // check if the righter cell is beyond visible range
    if (rightestX > visibleRange.right) {
        return YES;
    }
    
    return NO;
}

/*!
 * check if the section has a header, if does, render the header
 * and then check if this header is beyond left side of the visible range
 */
- (BOOL)renderLefterHeaderInsection:(NSInteger)section
                       withLeftestX:(CGFloat *)leftestX
                       visibleRange:(BWHrange)visibleRange {
    CGFloat headerWidth = [self widthForHeaderInSection:section];
    
    if (headerWidth > 0) {
        BWHrange headerHrange = BWMakeHrange(*leftestX - headerWidth, *leftestX);
        [self renderHeaderViewForSection:section atHrange:headerHrange];
        
        // track and update the leftest position
        *leftestX = headerHrange.left;
        
        if (*leftestX < visibleRange.left) {
            return YES;
        }
    }
    
    return NO;
}

/*!
 * check if the section has a footer, if does, render the footer
 * and then check if this footer is beyond left side of the visible range
 */
- (BOOL)renderLefterFooterInSection:(NSInteger)section
                       withLeftestX:(CGFloat *)leftestX
                       visibleRange:(BWHrange)visibleRange {
    CGFloat footerWidth = [self widthForFooterInSection:section];
    
    if (footerWidth > 0) {
        BWHrange footerHrange = BWMakeHrange(*leftestX - footerWidth, *leftestX);
        [self renderFooterViewForSection:section atHrange:footerHrange];
        
        // track and update the leftest position
        *leftestX = footerHrange.left;
        
        if (*leftestX < visibleRange.left) {
            return YES;
        }
    }
    
    return NO;
}

/*!
 * check if the section has a header, if does, render the header
 * and then check if this header is beyond right side of the visible range
 */
- (BOOL)renderRighterHeaderInSection:(NSInteger)section
                       withRightestX:(CGFloat *)rightestX
                        visibleRange:(BWHrange)visibleRange {
    CGFloat headerWidth = [self widthForHeaderInSection:section];
    
    if (headerWidth > 0) {
        BWHrange headerHrange = BWMakeHrange(*rightestX, *rightestX + headerWidth);
        [self renderHeaderViewForSection:section atHrange:headerHrange];
        
        // track and update the rightest position
        *rightestX = headerHrange.right;
        
        if (*rightestX > visibleRange.right) {
            return YES;
        }
    }
    
    return NO;
}

/*!
 * check if the section has a footer, if does, render the footer
 * and then check if this footer is beyond right side of the visible range
 */
- (BOOL)renderRighterFooterInSection:(NSInteger)section
                       withRightestX:(CGFloat *)rightestX
                        visibleRange:(BWHrange)visibleRange {
    CGFloat footerWidth = [self widthForFooterInSection:section];
    
    if (footerWidth > 0) {
        BWHrange footerHrange = BWMakeHrange(*rightestX, *rightestX + footerWidth);
        [self renderFooterViewForSection:section atHrange:footerHrange];
        
        // track and update the rightest position
        *rightestX = footerHrange.right;
        
        if (*rightestX > visibleRange.right) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Utility Methods

- (void)pushCellToOffscreenRepository:(BWHorizontalTableViewCell *)cell {
    NSString *identifier = cell.reuseIdentifier;
    
    // make sure the identifier is valid
    if (!identifier) return;
    
    NSMutableSet *cellReposity = self.offscreenCells[identifier];
    
    if (!cellReposity) {
        cellReposity = [NSMutableSet setWithObject:cell];
        
        self.offscreenCells[identifier] = cellReposity;
    } else {
        [cellReposity addObject:cell];
    }
}

/*!
 * Cell tap event listener, for internal use only
 */
- (void)__BWCellDidTapped__:(BWHorizontalTableViewCell *)cell {
    if ([__delegate respondsToSelector:@selector(horizontalTableView:didSelectColumnAtIndexPath:)]) {
        NSIndexPath *indexPath = objc_getAssociatedObject(cell, kBWCellIndexPathKey);
        
        // tell delegate that the cell at this index path has been tapped
        [__delegate horizontalTableView:self didSelectColumnAtIndexPath:indexPath];
    }
}

- (CGFloat)calculateTotalWidth {
    CGFloat totalWidth = 0.0f;

    NSInteger sectionCount = [self numberOfSections];
    
    for (NSInteger i = 0; i < sectionCount; i++) {
        // count header
        CGFloat headerWidth = [self widthForHeaderInSection:i];
        totalWidth += headerWidth;
        
        NSInteger columnCount = [self numberOfColumnsInSection:i];
        
        for (NSInteger j = 0; j < columnCount; j++) {
            // count every cell
            CGFloat columnWidth = [__delegate horizontalTableView:self
                                        widthForColumnAtIndexPath:[NSIndexPath indexPathForColumn:j inSection:i]];
            totalWidth += columnWidth;
        }
        
        // count footer
        CGFloat footerWidth = [self widthForFooterInSection:i];
        totalWidth += footerWidth;
    }
    
    return totalWidth;
}

/*!
 * get the index path at left side of the given indexPath
 */
- (NSIndexPath *)leftIndexOfIndex:(NSIndexPath *)indexPath {
    if (indexPath.column > 0) {
        return [NSIndexPath indexPathForColumn:(indexPath.column - 1) inSection:indexPath.section];
    } else if (indexPath.section > 0) {
        NSInteger section = indexPath.section - 1;
        NSInteger columnCount = [self numberOfColumnsInSection:section];
        
        return [NSIndexPath indexPathForColumn:(columnCount - 1) inSection:section];
    } else {
        return nil;
    }
}

/*!
 * get the index path at right side of the given indexPath
 */
- (NSIndexPath *)rightIndexOfIndex:(NSIndexPath *)indexPath {
    NSInteger sectionCount = [self numberOfSections];
    NSInteger columnCount = [self numberOfColumnsInSection:indexPath.section];
    
    if ((indexPath.column + 1) < columnCount) {
        return [NSIndexPath indexPathForColumn:(indexPath.column + 1) inSection:indexPath.section];
    } else if ((indexPath.section + 1) < sectionCount) {
        return [NSIndexPath indexPathForColumn:0 inSection:(indexPath.section + 1)];
    } else {
        return nil;
    }
}

- (CGFloat)widthForColumnAtIndexPath:(NSIndexPath *)indexPath {
    if ([__delegate respondsToSelector:@selector(horizontalTableView:widthForColumnAtIndexPath:)]) {
        return [__delegate horizontalTableView:self widthForColumnAtIndexPath:indexPath];
    }
    
    return self.columnWidth;
}

- (CGFloat)widthForHeaderInSection:(NSInteger)section {
    if ([__delegate respondsToSelector:@selector(horizontalTableView:widthForHeaderInSection:)]) {
        return [__delegate horizontalTableView:self widthForHeaderInSection:section];
    }
    
    return self.sectionHeaderWidth;
}

- (CGFloat)widthForFooterInSection:(NSInteger)section {
    if ([__delegate respondsToSelector:@selector(horizontalTableView:widthForFooterInSection:)]) {
        return [__delegate horizontalTableView:self widthForFooterInSection:section];
    }
    
    return self.sectionFooterWidth;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    if ([__delegate respondsToSelector:@selector(horizontalTableView:viewForHeaderInSection:)]) {
        return [__delegate horizontalTableView:self viewForHeaderInSection:section];
    }
    
    return nil;
}

- (UIView *)viewForFooterInSection:(NSInteger)section {
    if ([__delegate respondsToSelector:@selector(horizontalTableView:viewForFooterInSection:)]) {
        return [__delegate horizontalTableView:self viewForFooterInSection:section];
    }
    
    return nil;
}

- (UIView *)makeSectionHeaderFooterContainer {
    // check if has recycled container
    UIView *containerView = [self.offscreenHeaderFooters anyObject];
    
    if (containerView) {
        [self.offscreenHeaderFooters removeObject:containerView];
    } else {
        // if not, create a new container
        containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor clearColor];
    }
    
    return containerView;
}

- (void)clearSubViews:(UIView *)targetView {
    NSArray *subViews = targetView.subviews;
    
    for (UIView *subView in subViews) {
        [subView removeFromSuperview];
    }
}

@end
