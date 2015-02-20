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

@interface BaseTableViewController ()

@property (strong, nonatomic) NSMutableSet *showIndexes;
@property (nonatomic, strong) MDCScrollBarLabel *scrollBarLabel;
@property (nonatomic, assign) NSTimeInterval scrollBarFadeDelay;

@end

static CGFloat const kMDCScrollBarViewControllerDefaultFadeDelay = 1.0f;

@implementation BaseTableViewController{
    KYCell *kycell;
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
    
    //设置滑杆
    self.scrollBarFadeDelay = kMDCScrollBarViewControllerDefaultFadeDelay;
    self.scrollBarLabel = [[MDCScrollBarLabel alloc] initWithScrollView:self.tableView];
    [self.tableView addSubview:self.scrollBarLabel];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 200;
//}

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
        
        kycell.avator.layer.opacity = 0;
        kycell.avator.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        kycell.avator.layer.transform = CATransform3DRotate(kycell.avator.layer.transform, -180 * (M_PI / 180), 0, 0, 1);

        [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            kycell.avator.layer.opacity = 1;
            kycell.avator.layer.transform = CATransform3DIdentity;
            cell.layer.transform = CATransform3DIdentity;
            cell.layer.opacity = 1;
        } completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    
    kycell = (KYCell *)cell;
}


#pragma mark - UIScrollViewDelegate
#pragma mark - Show/Hide the Label Using UIScrollViewDelegate Callbacks

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

    NSString *createDate =  kycell.weiboModel.createDate;
    NSString *formate = @"EEE MMM d HH:mm:ss Z yyyy";
    NSDate *scrollBarDate = [Utils dateFromFomate:createDate formate:formate];
    self.scrollBarLabel.date = scrollBarDate;

    
//    NSInteger rowNumber = self.scrollBarLabel.frame.origin.y / 200;
//    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(60 * 12 * rowNumber)];
//    self.scrollBarLabel.date = date;


    [self.scrollBarLabel adjustPositionForScrollView:scrollView];
    [self.scrollBarLabel setDisplayed:YES animated:YES afterDelay:0.0f];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.scrollBarLabel setDisplayed:NO animated:YES afterDelay:self.scrollBarFadeDelay];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self.scrollBarLabel setDisplayed:NO animated:YES afterDelay:self.scrollBarFadeDelay];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.scrollBarLabel setDisplayed:NO animated:YES afterDelay:self.scrollBarFadeDelay];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.scrollBarLabel setDisplayed:NO animated:YES afterDelay:self.scrollBarFadeDelay];
}



@end
