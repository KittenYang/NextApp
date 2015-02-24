//
//  BaseTableViewController.h
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/14/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"
#import "CONST.h"

@protocol loadMoreDelegate <NSObject>

//下拉
- (void)pullDown;
//上拉
- (void)pullUp;
//选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface BaseTableViewController : UITableViewController<WBHttpRequestDelegate,UIGestureRecognizerDelegate>


@property(nonatomic,assign)id<loadMoreDelegate>loademoredelegate;


-(void)backToTop;//停止刷新，回到顶部
@end
