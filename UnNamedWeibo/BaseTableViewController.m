//
//  BaseTableViewController.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/14/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "BaseTableViewController.h"
#import "KYCell.h"
#import "Utils.h"
#import "ACTimeScroller.h"
#import "MJRefresh.h"


@interface BaseTableViewController ()<ACTimeScrollerDelegate>

@property (strong, nonatomic) NSMutableSet *showIndexes;


@end


@implementation BaseTableViewController{

    ACTimeScroller *_timeScroller;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 250;
    
    UIImage* logo = [UIImage imageNamed:@"Woohu"];
    CGRect frameimg = CGRectMake(0, 0, 70, 30);
    UIButton *logoButton = [[UIButton alloc] initWithFrame:frameimg];
    [logoButton setImage:logo forState:UIControlStateNormal];
    logoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 4, 0);
    logoButton.adjustsImageWhenHighlighted = NO;
    
    UIBarButtonItem *logoItem =[[UIBarButtonItem alloc] initWithCustomView:logoButton];
    self.navigationItem.leftBarButtonItem=logoItem;
    
    UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 568, 20)];
    [self.navigationController.view addSubview:statusView];
    statusView.backgroundColor = [UIColor redColor];

    //保存indexpath的数组
    _showIndexes = [NSMutableSet set];
    
    //时间滚动条
    _timeScroller = [[ACTimeScroller alloc] initWithDelegate:self];

    //下拉刷新
   [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupRefresh{
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"table"];
    [self.tableView headerBeginRefreshing];
    
    self.tableView.headerPullToRefreshText = @"下拉可以刷新了";
    self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.tableView.headerRefreshingText = @"MJ哥正在帮你刷新中,不客气";

}

- (void)headerRereshing
{
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView headerEndRefreshing];
    });
}





#pragma mark - TimeScollDelegate
- (UITableView *)tableViewForTimeScroller:(ACTimeScroller *)timeScroller
{
    return self.tableView;
}

- (NSDate *)timeScroller:(ACTimeScroller *)timeScroller dateForCell:(UITableViewCell *)cell
{
    KYCell *kycell = (KYCell *)cell;
    NSString *createDate =  kycell.weiboModel.createDate;
    NSString *formate = @"EEE MMM d HH:mm:ss Z yyyy";
    NSDate *scrollBarDate = [Utils dateFromFomate:createDate formate:formate];

    return scrollBarDate;
}



#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    //动画1：
    if (![self.showIndexes containsObject:indexPath]) {
        [self.showIndexes addObject:indexPath];
        CGFloat rotationAngleDegrees = -10;
        CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/ 180);
        CGPoint offsetPositioning = CGPointMake(-30, -20);
        
        
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0,  0.0, 1.0);
        transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y , 0.0);
        cell.layer.transform = transform;
        cell.alpha = 0.7;
        
        KYCell *kycell_ = (KYCell *)cell;
        
        kycell_.avator.layer.opacity = 0;
        kycell_.avator.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        kycell_.avator.layer.transform = CATransform3DRotate(kycell_.avator.layer.transform, -180 * (M_PI / 180), 0, 0, 1);

        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            kycell_.avator.layer.opacity = 1;
            kycell_.avator.layer.transform = CATransform3DIdentity;
            cell.layer.transform = CATransform3DIdentity;
            cell.layer.opacity = 1;
        } completion:nil];
    }
}


#pragma mark - UIScrollViewDelegate
#pragma mark - Show/Hide the Label Using UIScrollViewDelegate Callbacks

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_timeScroller scrollViewWillBeginDragging];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_timeScroller scrollViewDidScroll];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_timeScroller scrollViewDidEndDecelerating];
}



@end
