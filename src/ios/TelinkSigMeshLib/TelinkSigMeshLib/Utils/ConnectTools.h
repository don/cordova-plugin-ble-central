/********************************************************************************************************
 * @file     ConnectTools.h
 *
 * @brief    A concise description.
 *
 * @author   Telink, 梁家誌
 * @date     2021/4/19
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectTools : NSObject

+ (ConnectTools *)share;


/// demo 自定义连接工具类，用于开始连接指定的节点（逻辑：扫描5秒->扫描到则连接setFilter返回成功，扫描不到则连接已经扫描到的任意设备->setFilter->是则返回成功，不是则setNodeIdentity(多个设备则调用多次)->重复扫描5秒流程。）
/// @param nodeList 需要连接的节点，需要是SigDataSource里面的节点。
/// @param timeout 超时时间
/// @param complete 连接结果回调
- (void)startConnectToolsWithNodeList:(NSArray <SigNodeModel *>*)nodeList timeout:(NSInteger)timeout Complete:(nullable startMeshConnectResultBlock)complete;

/// demo 自定义连接工具类，用于停止连接指定的节点流程并断开当前的连接。
- (void)stopConnectToolsWithComplete:(nullable stopMeshConnectResultBlock)complete;

/// demo 自定义连接工具类，用于停止连接指定的节点流程保持当前的连接。
- (void)endConnectTools;

@end

NS_ASSUME_NONNULL_END
