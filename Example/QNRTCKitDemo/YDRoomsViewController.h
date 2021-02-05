//
//  YDRoomsViewController.h
//  QNRTCKitDemo
//
//  Created by lixuemin on 2021/2/4.
//  Copyright © 2021 PILI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^YDRoomLiveClickedBlock)(void);
typedef void (^YDRoomJoinClickedBlock)(void);


@interface YDRoomTabelViewCell: UITableViewCell
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) YDRoomLiveClickedBlock liveClickedBlock;
@property (nonatomic, copy) YDRoomJoinClickedBlock joinClickedBlock;
@end
@interface YDRoomsViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
