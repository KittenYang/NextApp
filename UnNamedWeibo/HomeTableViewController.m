//
//  HomeTableViewController.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/13/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "HomeTableViewController.h"
#import "KYCell.h"
#import "Utils.h"
#import "SKSplashIcon.h"
#import "KYLoadingHUD.h"



@interface HomeTableViewController ()

@property (strong, nonatomic) SKSplashView *splashView;
@property (nonatomic,copy   ) NSString     *topWeiboId;// 最新一条微博的ID
@property (nonatomic,copy   ) NSString     *lastWeiboId;// 最久一条微博的ID


@end

@implementation HomeTableViewController{
    NSArray *array;
    KYLoadingHUD *hud;
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
    
    UIView *new_feed_view = [[UIView alloc]initWithFrame:CGRectMake(10, 568-100, 30, 30)];
    new_feed_view.backgroundColor = [UIColor redColor];
    [self.tabBarController.view addSubview:new_feed_view];
 }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    KYCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiboCell" forIndexPath:indexPath];
    
    WeiboModel *model = [self.data objectAtIndex:indexPath.row];
    cell.weiboModel = model;
    [self updateCellContentView:cell withWeiboModel:model];
    
    return cell;
}


//填充数据
-(void)updateCellContentView:(KYCell *)cell withWeiboModel:(WeiboModel *)model{

    //----------微博内容--------------
    cell.cellView.weiboView.weiboText.text = model.text;
        
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
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"25",@"count",self.topWeiboId,@"since_id",nil];
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

        
        [self.tableView reloadData];
        [self backToTop];
        
        
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:updateCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }
}

#pragma mark - NSCoding
//- (void)encodeWithCoder:(NSCoder *)aCoder{
//      [aCoder encodeObject:self.data forKey:@"WEIBOS"];
//}
//- (id)initWithCoder:(NSCoder *)aDecoder{
//    
//}



@end
