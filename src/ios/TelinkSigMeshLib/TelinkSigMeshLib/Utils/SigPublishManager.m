/********************************************************************************************************
 * @file     SigPublishManager.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/12/20
 *
 * @par     Copyright (c) [2021], Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *******************************************************************************************************/

#import "SigPublishManager.h"

@interface SigPublishManager ()
//Dictionary of timer that check node off line.
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,BackgroundTimer *>*checkOfflineTimerDict;
@end

@implementation SigPublishManager

+ (SigPublishManager *)share{
    static SigPublishManager *sharePublish = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        sharePublish = [[SigPublishManager alloc] init];
        [sharePublish initData];
    });
    return sharePublish;
}

- (void)initData{
    _checkOfflineTimerDict = [NSMutableDictionary dictionary];
}

#pragma mark check outline timer
- (void)setDeviceOffline:(NSNumber *)address{
    UInt16 adr = [address intValue];
    
    [self stopCheckOfflineTimerWithAddress:@(adr)];
    
    SigNodeModel *device = [SigMeshLib.share.dataSource getNodeWithAddress:adr];
    if (device) {
        if (device.hasPublishFunction && device.hasOpenPublish) {
            device.state = DeviceStateOutOfLine;
            NSString *str = [NSString stringWithFormat:@"======================device offline:0x%02X======================",adr];
            TeLogInfo(@"%@",str);
            if (self.discoverOutlineNodeCallback) {
                self.discoverOutlineNodeCallback(@(device.address));
            }
        }
    }
}

- (void)startCheckOfflineTimerWithAddress:(NSNumber *)address{
    SigNodeModel *device = [SigMeshLib.share.dataSource getNodeWithAddress:address.intValue];
    if (device && device.hasPublishFunction && device.hasOpenPublish && device.hasPublishPeriod) {
        [self stopCheckOfflineTimerWithAddress:address];
        __weak typeof(self) weakSelf = self;
        BackgroundTimer *timer = [BackgroundTimer scheduledTimerWithTimeInterval:[self getIntervalWithSigPeriodModel:[device getModelIDModelWithModelID:device.publishModelID].publish.period]*3+1 repeats:NO block:^(BackgroundTimer * _Nonnull t) {
            [weakSelf setDeviceOffline:address];
        }];
        _checkOfflineTimerDict[address] = timer;
    }
}

- (void)stopCheckOfflineTimerWithAddress:(NSNumber *)address{
    BackgroundTimer *timer = _checkOfflineTimerDict[address];
    if (timer) {
        [_checkOfflineTimerDict removeObjectForKey:address];
    }
    if (timer) {
        [timer invalidate];
    }
}

/// 通过周期对象SigPeriodModel获取周期时间，单位为秒。
- (double)getIntervalWithSigPeriodModel:(SigPeriodModel *)periodModel {
    double tem = periodModel.resolution * periodModel.numberOfSteps / 1000.0;
    return tem;
}

@end
