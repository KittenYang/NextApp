//
//  HomeTableViewController.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/13/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

//关于未读气泡提示
#define BubbleWidth  30
#define BubbleX      18
#define BubbleY      500
#define BubbleColor  [UIColor redColor]
//[UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];



#import "HomeTableViewController.h"
#import "KYCell.h"
#import "Utils.h"
#import "SKSplashIcon.h"
#import "KYLoadingHUD.h"
#import "JellyButton.h"
#import "KYCuteView.h"




@interface HomeTableViewController ()

@property (strong, nonatomic) SKSplashView *splashView;
@property (nonatomic,copy   ) NSString     *topWeiboId;// 最新一条微博的ID
@property (nonatomic,copy   ) NSString     *lastWeiboId;// 最久一条微博的ID
@property (nonatomic,strong) KYCuteView *cuteView;

@end

@implementation HomeTableViewController{
    NSArray *array;
    KYLoadingHUD *hud;
    
    
    //刷新了几条微博的视图
    JellyButton *refreshNumberView;
    UILabel *updatedNumberforBanner;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareToLoadWeibo) name:kWeiboAuthSuccessNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kWeiboAuthSuccessNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self twitterSplash];

//    hud = [[KYLoadingHUD alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 50, self.view.bounds.size.height / 2 -100, 100, 100)];
//    [self.view addSubview:hud];


    //登录按钮
    UIButton *authBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    authBtn.frame = CGRectMake(260, 20, 50, 30);
    [authBtn setTitle:@"登录" forState:UIControlStateNormal];
    [authBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [authBtn addTarget:self action:@selector(authWeibo) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *authItem =[[UIBarButtonItem alloc]initWithCustomView:authBtn];
    self.navigationItem.rightBarButtonItem=authItem;

    
    //下拉加载更多
    super.loademoredelegate = self;
    
    
    //数据持久化
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreData"];
    NSDictionary *weiboDataFromKeyedUnarchiver = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.data = [weiboDataFromKeyedUnarchiver objectForKey:@"WEIBOS"];
    self.topWeiboId = [weiboDataFromKeyedUnarchiver objectForKey:@"topWeiboId"];
    self.weibos = self.data;

    if (self.data.count == 0) {
        [self loadWeibo];
    }else{
        [self.tableView reloadData];
    }
    
    
    //获取未读微博数的定时器
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(fetchToUnread) userInfo:nil repeats:YES];
    
 }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 定时获取未读微博数
-(void)fetchToUnread{
    NSString *uid = [[[NSUserDefaults standardUserDefaults]objectForKey:@"WeiboAuthData"]objectForKey:@"hostUserID"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid", nil];

    [WBHttpRequest requestWithAccessToken:[Utils WEIBOTOKEN] url:WB_unRead httpMethod:@"GET" params:params delegate:self withTag:@"unRead"];
}

#pragma mark -- 启动动画
- (void) twitterSplash
{
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"twitter.png"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:0.25098 green:0.6 blue:1.0 alpha:1.0];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeBounce];
    _splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    _splashView.animationDuration = 2; //Optional -> set animation duration. Default: 1s
    [self.tabBarController.view addSubview:_splashView];
    [_splashView startAnimation];
}

#pragma mark -- splashView animation delegate
- (void) splashView:(SKSplashView *)splashView didBeginAnimatingWithDuration:(float)duration
{
    NSLog(@"Started animating from delegate");
    
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeiboModel *model = [self.data objectAtIndex:indexPath.row];
    
    
    KYCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiboCell" forIndexPath:indexPath];
   
    cell.weiboModel = model;
    
    [self updateCellContentView:cell withWeiboModel:model];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}


//填充数据
-(void)updateCellContentView:(KYCell *)cell withWeiboModel:(WeiboModel *)model{

    //----------微博内容--------------
    cell.cellView.weiboView.weiboText.text = model.text;
    
    
    //-----------创建日期---------------
    NSString *createDate =  model.createDate;
    NSString *dateString = [Utils fomateString:createDate];
    if (createDate != nil ) {
        cell.cellView.createDateLabel.text = dateString;
    }else{
        cell.cellView.createDateLabel.hidden = YES;
    }
    
    //----------微博来源---------------
    NSString *ret = [Utils parseSource: model.source];
    if (ret != nil) {
        
        cell.cellView.sourceLabel.text = [NSString stringWithFormat:@"来自 %@",ret];
        
    }else{
        cell.cellView.sourceLabel.hidden = YES;
    }
    

    //---图片视图----
    if (model.pic_urls.count > 0) {

        cell.cellView.weiboView.collectionViewHeight.constant = 130.0f;
    
    }else {
        cell.cellView.weiboView.collectionViewHeight.constant = 0.0f;
    }
    
    //------转发视图-------
    if (model.retWeibo) {
        
        cell.cellView.weiboView.reWeiboView.reWeiboModel = model.retWeibo;
        NSString *nickName = model.retWeibo.user.screen_name;

        cell.cellView.weiboView.reWeiboView.reWeiboText.text = [NSString stringWithFormat:@"@%@:%@",nickName,model.retWeibo.text];
        CGRect oldFrame = cell.cellView.weiboView.reWeiboView.reWeiboText.frame;

        cell.cellView.weiboView.reWeiboView.reWeiboText.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [cell.cellView.weiboView.reWeiboView.reWeiboText sizeThatFits:CGSizeMake(cell.cellView.weiboView.reWeiboView.reWeiboText.frame.size.width, MAXFLOAT)];
        
        cell.cellView.weiboView.reWeiboView.reWeiboText.frame =CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, size.height);
        
        if (model.retWeibo.pic_urls.count > 0) {
            
            cell.cellView.weiboView.reWeiboView.reCollectionViewHeight.constant = 130.0f;
            
        }else {
            cell.cellView.weiboView.reWeiboView.reCollectionViewHeight.constant = 0.0f;
        }
        
        cell.cellView.weiboView.reWeiboView.reWeiboHeight.constant = cell.cellView.weiboView.reWeiboView.reWeiboText.bounds.size.height + cell.cellView.weiboView.reWeiboView.reCollectionViewHeight.constant + 5 + 5 + 5;
        
    }else{
        
        cell.cellView.weiboView.reWeiboView.reWeiboText.text = nil;
        cell.cellView.weiboView.reWeiboView.reCollectionViewHeight.constant = 0.0f;
        cell.cellView.weiboView.reWeiboView.reWeiboHeight.constant = 0;
    }


    

}

#pragma  mark - 微博登录
-(void)authWeibo{

    WBAuthorizeRequest *authrequest = [WBAuthorizeRequest request];
    authrequest.redirectURI = kWeiboRedirectURI;
    authrequest.scope = @"all";
    authrequest.userInfo = @{@"SSO_From": @"HomeTableViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:authrequest];

}


-(void)prepareToLoadWeibo{
    if (self.data.count != 0) {
        return;
    }else{
        if ( [Utils WEIBOTOKEN] == nil || [[Utils WEIBOTOKEN]  isEqualToString:@""]) {
        }else{
            NSDate *nowDate = [NSDate date];
            if([nowDate compare:[Utils WEIBOEXDATE]] == NSOrderedAscending){
                
                [self loadWeibo];
                
            }else{
            }
        }
    }
}


-(void)loadWeibo{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"100" forKey:@"count"];
    
    [WBHttpRequest requestWithAccessToken:[Utils WEIBOTOKEN] url:WB_home  httpMethod:@"GET" params:params delegate:self withTag:@"load"];
}

#pragma mark  - loadMoreDelegate
//下拉
- (void)pullDown{
    if (self.topWeiboId.length == 0) {
        NSLog(@"最新一条微博的ID为空");
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"50",@"count",self.topWeiboId,@"since_id",nil];
    [WBHttpRequest requestWithAccessToken:[Utils WEIBOTOKEN] url:WB_home  httpMethod:@"GET" params:params delegate:self withTag:@"pullDown"];

}
//上拉
- (void)pullUp{
    
}
//选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark  - WBHttpRequestDelegate
- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data{
    if ([request.tag isEqual: @"load"]) {
//        [hud dismissHUD];

        NSError *error;
        NSDictionary *WEIBOJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]; // 100条JSON，一个statuses对应一个WeiboModel
        NSDictionary *WEIBOMODELS = [WEIBOJSON objectForKey:@"statuses"]; //100条微博
        NSMutableArray *WEIBOS = [NSMutableArray arrayWithCapacity:WEIBOMODELS.count];
        for (NSDictionary *_wbmodel in WEIBOMODELS) {
            WeiboModel *wbmodel = [[WeiboModel alloc]initWithWeiboDic:_wbmodel];
            [WEIBOS addObject:wbmodel];
        }
        
        self.data = WEIBOS;
        self.weibos = WEIBOS;
        
        if (WEIBOS.count > 0) {
            //记下最新的微博ID
            WeiboModel *topWeibo= [WEIBOS objectAtIndex:0];     //取出最新的一条微博
            self.topWeiboId = [topWeibo.weiboId stringValue];   //把最新的微博ID赋值给我们定义的这个topWeiboId变量
            //同理，记下最久的微博ID
            WeiboModel *lastWeibo = [WEIBOS lastObject];  //取出最久的一条微博
            self.lastWeiboId = [lastWeibo.weiboId stringValue];//把最久的微博ID复制给我们定义的这个lastWeiboId变量
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.data,@"WEIBOS",self.topWeiboId,@"topWeiboId",nil];
        NSData *StoreData = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [[NSUserDefaults standardUserDefaults] setObject:StoreData forKey:@"StoreData"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        [self.tableView reloadData];
    }
    
    if ([request.tag isEqual:@"pullDown"]) {
        NSError *error;
        NSDictionary *WEIBOJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]; // 100条JSON，一个statuses对应一个WeiboModel
        NSDictionary *WEIBOMODELS = [WEIBOJSON objectForKey:@"statuses"]; //100条微博
        //更新的条数
        int updateCount = (int)[WEIBOMODELS count];
        if (updateCount == 0) {
            [self backToTop];
            return;
        }
        
        NSMutableArray *WEIBOS = [NSMutableArray arrayWithCapacity:WEIBOMODELS.count];
        for (NSDictionary *_wbmodel in WEIBOMODELS) {
            WeiboModel *wbmodel = [[WeiboModel alloc]initWithWeiboDic:_wbmodel];
            [WEIBOS addObject:wbmodel];
        }
        
        [WEIBOS addObjectsFromArray:self.weibos];
        //移除超出100条的
        NSRange overHundredRange;
        overHundredRange.location = 100;
        overHundredRange.length   = [WEIBOS count]-100;
        [WEIBOS removeObjectsInRange:overHundredRange];
        
        //移除刚刷新的几条
        NSRange updatedRange;
        updatedRange.location = [self.showIndexes count]-updateCount;
        updatedRange.length = updateCount;
        [self.showIndexes removeObjectsInRange:updatedRange];
        if (self.afterRemovedshowIndexes.count != 0 ) {
            [self.afterRemovedshowIndexes removeAllObjects];
        }
        [self.afterRemovedshowIndexes addObjectsFromArray:self.showIndexes];
        NSLog(@"移除：%@",self.showIndexes);
        self.isFirstTime = NO;
        
        self.data   = WEIBOS;
        self.weibos = WEIBOS;
        
        if (WEIBOS.count > 0) {
            WeiboModel *topWeibo= [WEIBOS objectAtIndex:0];
            self.topWeiboId = [topWeibo.weiboId stringValue];
        }
        
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.data,@"WEIBOS",self.topWeiboId,@"topWeiboId",nil];
        NSData *StoreData = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [[NSUserDefaults standardUserDefaults] setObject:StoreData forKey:@"StoreData"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        // 刷新前保存高度旧的tableview高度
//        CGFloat oldTableViewHeight = self.tableView.contentSize.height;
        
        //刷新tableview
        [self.tableView reloadData];
        [self backToTop];
        [self showNumberOfRefresh:updateCount];
        //刷新之后移除未读提示
        self.cuteView.frontView.hidden = YES;

        
        // 刷新后位置保持在原地
//        CGFloat newTableViewHeight = self.tableView.contentSize.height;
//        self.tableView.contentOffset = CGPointMake(0, newTableViewHeight - oldTableViewHeight);
        
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:updateCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }
    
    if ([request.tag isEqual:@"unRead"]) {
        NSError *error;
        NSDictionary *WEIBOJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSNumber *unReadNum = [WEIBOJSON objectForKey:@"status"];
        int n = [unReadNum intValue];
        if (n == 0) {
            return;
        }
        
        
        if (self.cuteView == nil) {

            self.cuteView = [[KYCuteView alloc]initWithPoint:CGPointMake(BubbleX,BubbleY) superView:self.tabBarController.view];
            self.cuteView.bubbleWidth = 35;
            self.cuteView.bubbleColor = BubbleColor;
            self.cuteView.viscosity  = 25;
            [self.cuteView setUp];
            [self.cuteView addGesture];
            self.tabBarController.view.backgroundColor = [UIColor whiteColor];

            NSLog(@"提示框+1");
        }
        
        if (n > 0){
            if (n > 50) {
                self.cuteView.frontView.hidden = NO;
                self.cuteView.bubbleLabel.text  = @"...";
            }else{
                self.cuteView.frontView.hidden = NO;
                self.cuteView.bubbleLabel.text  =[NSString stringWithFormat:@"%d",n];
            }
        }
    
    }
}

#pragma mark - banner上刷新之后提示刷新几条
-(void)showNumberOfRefresh:(int)updatedNum{
    if (refreshNumberView == nil) {
        refreshNumberView = [[JellyButton alloc]initWithFrame:CGRectMake(5, -120, 300, 50)
                                                jellyViewSize:CGSizeMake(300, 50)
                                                    fillColor:[UIColor redColor]
                                                   elasticity:0.1
                                                      density:1
                                                      damping:0.1
                                                    frequency:6];

        updatedNumberforBanner = [[UILabel alloc]initWithFrame:refreshNumberView.frame];
        NSLog(@"%@",NSStringFromCGRect(updatedNumberforBanner.frame));
        updatedNumberforBanner.textColor = [UIColor whiteColor];
        updatedNumberforBanner.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:refreshNumberView];
        [self.view addSubview:updatedNumberforBanner];
    }
    
    updatedNumberforBanner.text = [NSString  stringWithFormat:@"更新%d条微博",updatedNum];
    
    [UIView animateWithDuration:1.5 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        refreshNumberView.frame = CGRectMake(5, 5, 300, 50);
        updatedNumberforBanner.frame = CGRectMake(5, 8, 300, 50);
        [refreshNumberView show];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5 delay:1 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            refreshNumberView.frame = CGRectMake(5, -120, 300, 50);
            updatedNumberforBanner.frame = CGRectMake(5, -120, 300, 50);
        } completion:^(BOOL finished) {
            [refreshNumberView removeFromSuperview];
            [updatedNumberforBanner removeFromSuperview];
            refreshNumberView = nil;
            updatedNumberforBanner = nil;
        }];
    }];


}


@end
