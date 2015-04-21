//
//  DetailViewController.h
//  UnNamedWeibo
//
//  Created by Kitten Yang on 3/15/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "BaseTableViewController.h"
#import "WeiboModel.h"

@interface DetailViewController : BaseTableViewController

-(id)initWithModel:(WeiboModel *)model;
@property (nonatomic,strong)WeiboModel *model;

@end
