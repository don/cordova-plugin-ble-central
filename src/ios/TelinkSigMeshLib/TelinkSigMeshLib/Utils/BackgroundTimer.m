/********************************************************************************************************
 * @file     BackgroundTimer.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/11/27
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

#import "BackgroundTimer.h"

@interface BackgroundTimer ()
@property (nonatomic,strong) dispatch_source_t timer;
@property (nonatomic,assign) BOOL repeats;
@end

@implementation BackgroundTimer

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^ _Nonnull)(BackgroundTimer * _Nonnull))block {
    if (self = [super init]) {
        _interval = interval;
        _repeats = repeats;
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0));
        if (_timer) {
            __weak typeof(self) weakSelf = self;
            if (repeats) {
                dispatch_source_set_timer(_timer, dispatch_walltime(NULL, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
            } else {
                dispatch_source_set_timer(_timer, dispatch_walltime(NULL, interval * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
            }
            dispatch_source_set_event_handler(_timer, ^{
                if (block) {
                    block(weakSelf);
                }
                if (!repeats) {
                    [weakSelf invalidate];
                }
            });
            dispatch_resume(_timer);
        }
    }
    return self;
}

/// Chedules a timer that can be started from a background DispatchQueue.
+ (BackgroundTimer * _Nonnull)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^ _Nonnull)(BackgroundTimer * _Nonnull t))block {
    return [[self alloc] initWithTimeInterval:interval repeats:repeats block:block];
}

/// Asynchronously cancels the dispatch source, preventing any further invocation of its event handler block.
- (void)invalidate {
    if (_timer) {
        dispatch_source_set_event_handler(_timer, nil);
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)dealloc {
    [self invalidate];
}

@end
