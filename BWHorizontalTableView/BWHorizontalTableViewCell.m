//
//  BWHorizontalTableViewCell.m
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

#import "BWHorizontalTableViewCell.h"

#import <objc/runtime.h>
#import <objc/message.h>

// the default color for mask view
#define kBWCellDefaultMaskColor [UIColor colorWithRed:(128.0f/255.0f) green:(128.0f/255.0f) blue:(128.0f/255.0f) alpha:0.15f]
// duration time when showing mask view
#define kBWCellMaskAnimationTime 0.15f

@interface BWHorizontalTableViewCell ()

/*!
 * The maskView will be shown when selectionStyle is not UITableViewCellSelectionStyleNone
 */
@property (nonatomic, strong) UIView *maskView;

/*!
 * Indicate whether the cell is been touching or not
 */
@property (nonatomic, assign) BOOL isTouching;

@end


@implementation BWHorizontalTableViewCell

- (void)dealloc {
    objc_removeAssociatedObjects(self);
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    
    if (self) {
        _reuseIdentifier = reuseIdentifier;
        _selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    _selectionStyle = selectionStyle;
    
    if (selectionStyle == UITableViewCellSelectionStyleNone && self.maskView) {
         /* 
         * if selectionStyle has been changed to UITableViewCellSelectionStyleNone,
         * clear mask view immediately.
         */
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
}

- (UIColor *)maskColor {
    return _maskColor ?: kBWCellDefaultMaskColor;
}

- (void)prepareForReuse {
    // do nothing here, clear all holding data in subclasses
}

#pragma mark - Handle Touch Events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    self.isTouching = YES;
    [self showMask];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.isTouching) {
        self.isTouching = NO;
        [self hideMask];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (self.isTouching) {
        self.isTouching = NO;
        [self hideMask];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.isTouching) {
        self.isTouching = NO;
        [self hideMask];
        
        // get the tap event listener
        id cellTapListener = objc_getAssociatedObject(self, "__BWCell_TapListener__");
        
        if (cellTapListener) {
            // tell tap event listener that the cell has been tapped
            ((void(*)(id, SEL, id))objc_msgSend)(cellTapListener, NSSelectorFromString(@"__BWCellDidTapped__:"), self);
        }
    }
}

- (void)showMask {
    if (self.selectionStyle == UITableViewCellSelectionStyleNone) return;
    
    if (self.maskView == nil) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = self.maskColor;
        _maskView.alpha = 0.0f;
        
        [self addSubview:_maskView];
        
        /* make sure the mask view always has the same size as this cell */
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_maskView);
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_maskView]-0-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views];
        NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_maskView]-0-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views];
        [self addConstraints:horizontalConstraints];
        [self addConstraints:verticalConstraint];
    }
    
    self.maskView.alpha = 0.0f;
    [self bringSubviewToFront:self.maskView];
    
    [UIView animateWithDuration:kBWCellMaskAnimationTime
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.maskView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         ;
                     }];
}

- (void)hideMask {
    if (self.maskView) {
        [UIView animateWithDuration:kBWCellMaskAnimationTime
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.maskView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             ;
                         }];
    }
}

@end
