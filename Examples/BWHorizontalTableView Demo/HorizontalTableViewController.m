//
//  HorizontalTableViewController.m
//  BWHorizontalTableView Demo
//
//  Created by wangruicheng on 1/1/16.
//  Copyright © 2016 burrowswang. All rights reserved.
//

#import "HorizontalTableViewController.h"

#import "BWHorizontalTableView.h"
#import "HorizontalTableViewCell.h"

@interface HorizontalTableViewController () <BWHorizontalTableViewDataSource, BWHorizontalTableViewDelegate>

@property (nonatomic, weak) BWHorizontalTableView   *tableView;
@property (nonatomic, strong) NSArray               *dataSource;

@end

@implementation HorizontalTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.dataSource = @[@"earth", @"moon", @"jupiter", @"mars", @"mercury", @"neptune", @"pluto", @"saturn", @"sun", @"venus"];
    
    BWHorizontalTableView *tableView = [[BWHorizontalTableView alloc] init];
    tableView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    tableView.frame = CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 114);
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - BWHorizontalTableViewDataSource

- (NSInteger)numberOfSectionsInHorizontalTableView:(BWHorizontalTableView *)tableView {
    return 50;
}

- (NSInteger)horizontalTableView:(BWHorizontalTableView *)tableView numberOfColumnsInSection:(NSInteger)section {
    return 10;
}

- (BWHorizontalTableViewCell *)horizontalTableView:(BWHorizontalTableView *)tableView cellForColumnAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HorizontalTableViewCell";
    
    HorizontalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[HorizontalTableViewCell alloc] initWithReuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSString *name = self.dataSource[arc4random() % [self.dataSource count]];
    [cell showPlanet:name];
    
    return cell;
}

#pragma mark - BWHorizontalTableViewDelegate

- (CGFloat)horizontalTableView:(BWHorizontalTableView *)tableView widthForColumnAtIndexPath:(NSIndexPath *)indexPath {
    return 84.0f;
}

- (CGFloat)horizontalTableView:(BWHorizontalTableView *)tableView widthForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (CGFloat)horizontalTableView:(BWHorizontalTableView *)tableView widthForFooterInSection:(NSInteger)section {
    return 20.0f;
}

- (UIView *)horizontalTableView:(BWHorizontalTableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, tableView.frame.size.height)];
    headerView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1f];
    return headerView;
}

- (UIView *)horizontalTableView:(BWHorizontalTableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, tableView.frame.size.height)];
    footerView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1f];
    return footerView;
}

- (void)horizontalTableView:(BWHorizontalTableView *)tableView didSelectColumnAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell at %ld:%ld has been tapped.", (long)indexPath.section, (long)indexPath.column);
}

- (void)horizontalTableView:(BWHorizontalTableView *)tableView willDisplayCell:(BWHorizontalTableViewCell *)cell forColumnAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell at %ld:%ld will be displayed", (long)indexPath.section, (long)indexPath.column);
}

@end
