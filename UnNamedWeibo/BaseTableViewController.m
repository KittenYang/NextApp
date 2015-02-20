//
//  BaseTableViewController.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/14/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "BaseTableViewController.h"
#import "KYCell.h"
#import "MDCScrollBarLabel.h"
#import "Utils.h"
#import "ACTimeScroller.h"

@interface BaseTableViewController ()<ACTimeScrollerDelegate>

@property (strong, nonatomic) NSMutableSet *showIndexes;
@property (nonatomic, strong) MDCScrollBarLabel *scrollBarLabel;
@property (nonatomic, assign) NSTimeInterval scrollBarFadeDelay;

@end


@implementation BaseTableViewController{
    
    NSMutableArray *_datasource;
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

    
    _showIndexes = [NSMutableSet set];
    

    _timeScroller = [[ACTimeScroller alloc] initWithDelegate:self];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        CGFloat rotationAngleDegrees = -30;
        CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/ 180);
        CGPoint offsetPositioning = CGPointMake(-20, -20);
        
        
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0,  0.0, 1.0);
        transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y , 0.0);
        cell.layer.transform = transform;
        cell.alpha = 0.7;
        
        KYCell *kycell_ = (KYCell *)cell;
        
        kycell_.avator.layer.opacity = 0;
        kycell_.avator.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        kycell_.avator.layer.transform = CATransform3DRotate(kycell_.avator.layer.transform, -180 * (M_PI / 180), 0, 0, 1);

        [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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
