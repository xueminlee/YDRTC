//
//  YDRoomsViewController.m
//  QNRTCKitDemo
//
//  Created by lixuemin on 2021/2/4.
//  Copyright © 2021 PILI. All rights reserved.
//

#import "YDRoomsViewController.h"
#import "Masonry.h"
#import "QRDNetworkUtil.h"
#import "QRDRTCViewController.h"
#import "QRDPlayerViewController.h"
#import "QRDLoginViewController.h"

@interface YDRoomTabelViewCell ()

@property (nonatomic, strong) UILabel *roomLabel;
@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, strong) UIButton *liveButton;

@end

@implementation YDRoomTabelViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.roomLabel];
        [self.contentView addSubview:self.joinButton];
        [self.contentView addSubview:self.liveButton];
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self p_updateConstraints];
}

- (void)p_updateConstraints {
    [self.roomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(@(24));
    }];

    [self.joinButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@80);
        make.height.mas_equalTo(@(30));
    }];
    
    [self.liveButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.joinButton.mas_left).offset(-50);
        make.width.mas_equalTo(@(80));
        make.height.mas_equalTo(@(30));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
}

- (void)setItem:(NSString *)name {
    self.name = name;
    self.roomLabel.text = name;
    [self p_updateConstraints];
}

- (void) joinButtonClicked {
    if (self.joinClickedBlock) {
        self.joinClickedBlock();
    }
}

- (void) liveButtonClicked {
    if (self.liveClickedBlock) {
        self.liveClickedBlock();
    }
}

- (UIButton *)liveButton {
    if (!_liveButton) {
        _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_liveButton setTitle:@"观看" forState:UIControlStateNormal];
        _liveButton.layer.cornerRadius = 5;
        _liveButton.layer.masksToBounds = YES;
        [_liveButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_liveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_liveButton setBackgroundColor:[UIColor whiteColor]];
        [_liveButton addTarget:self action:@selector(liveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _liveButton;
}

-(UIButton *)joinButton {
    if (!_joinButton) {
        _joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton setTitle:@"连麦" forState:UIControlStateNormal];
        _joinButton.layer.cornerRadius = 5;
        _joinButton.layer.masksToBounds = YES;
        [_joinButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_joinButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_joinButton setBackgroundColor:[UIColor whiteColor]];
        [_joinButton addTarget:self action:@selector(joinButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinButton;
}

-(UILabel *)roomLabel {
    if (!_roomLabel) {
        _roomLabel = [[UILabel alloc] init];
        _roomLabel.textColor = [UIColor whiteColor];
        _roomLabel.font = [UIFont systemFontOfSize:14];
    }
    return _roomLabel;
}
@end

@interface YDRoomsViewController () <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, strong) UILabel *roomLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *newButton;
@property (nonatomic, copy) NSArray<NSString*> *roomList;
@property (nonatomic, copy) NSString *currentRoomName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *appId;

@end

@implementation YDRoomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.title = @"房间列表";
    
    NSString *appId = [[NSUserDefaults standardUserDefaults] stringForKey:QN_APP_ID_KEY];
    if (0 == appId.length) {
        appId = QN_RTC_DEMO_APPID;
        [[NSUserDefaults standardUserDefaults] setObject:appId forKey:QN_APP_ID_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.appId = appId;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.roomLabel];
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.newButton];
    [self.view addSubview:self.tableView];
    
    [self.roomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@44);
        make.height.equalTo(@30);
    }];
    
    [self.newButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@44);
        make.right.equalTo(@-20);
        make.height.equalTo(@30);
        make.width.equalTo(@100);
    }];
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@44);
        make.right.equalTo(self.newButton.mas_left).offset(-20);
        make.height.equalTo(@30);
        make.width.equalTo(@100);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.refreshButton.mas_bottom).offset(20);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self refreshRoomList];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDRoomTabelViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YDRoomTabelViewCell" forIndexPath:indexPath];
    [cell setItem:self.roomList[indexPath.row]];
    cell.joinClickedBlock = ^{
        self.currentRoomName = self.roomList[indexPath.row];
        // 连麦 会议
        NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:QN_SET_CONFIG_KEY];
        if (!configDic) {
            configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@15, @"Bitrate":@(400*1000)};
        } else if (![configDic objectForKey:@"Bitrate"]) {
            // 如果不存在 Bitrate key，做一下兼容处理
            configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@15, @"Bitrate":@(400*1000)};
            [[NSUserDefaults standardUserDefaults] setObject:configDic forKey:QN_SET_CONFIG_KEY];
        }

        [[NSUserDefaults standardUserDefaults] setObject:self.currentRoomName forKey:QN_ROOM_NAME_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        QRDRTCViewController *rtcVC = [[QRDRTCViewController alloc] init];
        rtcVC.configDic = configDic;
        rtcVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:rtcVC animated:YES completion:nil];
    };
    
    cell.liveClickedBlock = ^{
        self.currentRoomName = self.roomList[indexPath.row];
        // 观看 直播
        [[NSUserDefaults standardUserDefaults] setObject:self.currentRoomName forKey:QN_ROOM_NAME_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];

        QRDPlayerViewController *playerViewController = [[QRDPlayerViewController alloc] init];
        playerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:playerViewController animated:YES completion:nil];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshRoomList {
    // request the roomlist
    // 获取直播房间列表
    [QRDNetworkUtil requestRoomListWithAppId:self.appId completionHandler:^(NSError *error,  NSArray<NSString*> *roomlist) {
                
        if (error) {
            ;
        } else {
            self.roomList = roomlist;
            [self.tableView reloadData];
        }
    }];
}

- (void)newRoom {
    QRDLoginViewController *vc = [[QRDLoginViewController alloc] init];
    vc.currentRoomName = self.currentRoomName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [_tableView registerClass:[YDRoomTabelViewCell class] forCellReuseIdentifier:@"YDRoomTabelViewCell"];
    }
    return _tableView;
}

- (UIButton *)newButton {
    if (!_newButton) {
        _newButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newButton setTitle:@"新建房间" forState:UIControlStateNormal];
        _newButton.layer.cornerRadius = 5;
        _newButton.layer.masksToBounds = YES;
        [_newButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_newButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_newButton setBackgroundColor:[UIColor whiteColor]];
        [_newButton addTarget:self action:@selector(newRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _newButton;

}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setTitle:@"刷新列表" forState:UIControlStateNormal];
        _refreshButton.layer.cornerRadius = 5;
        _refreshButton.layer.masksToBounds = YES;
        [_refreshButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_refreshButton setBackgroundColor:[UIColor whiteColor]];
        [_refreshButton addTarget:self action:@selector(refreshRoomList) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

-(UILabel *)roomLabel {
    if (!_roomLabel) {
        _roomLabel = [[UILabel alloc] init];
        _roomLabel.text = @"直播房间列表";
        _roomLabel.textColor = [UIColor whiteColor];
        _roomLabel.font = [UIFont systemFontOfSize:14];
        [_roomLabel sizeToFit];
    }
    return _roomLabel;
}

@end
