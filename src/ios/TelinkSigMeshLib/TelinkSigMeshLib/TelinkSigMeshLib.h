/********************************************************************************************************
 * @file     TelinkSigMeshLib.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/10/21
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

//! Project version number for TelinkSigMeshLib.
FOUNDATION_EXPORT double TelinkSigMeshLibVersionNumber;

//! Project version string for TelinkSigMeshLib.
FOUNDATION_EXPORT const unsigned char TelinkSigMeshLibVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TelinkSigMeshLib/PublicHeader.h>

#import <CoreBluetooth/CoreBluetooth.h>

/*注意：
 1.注释‘#define kExist’则生成不包含MeshOTA、remote provision代码的库TelinkSigMeshLib.framework，demo需要导入头文件‘#import "TelinkSigMeshLib.h"’
 2.不注释‘#define kExist’则生成包含MeshOTA、remote provision代码的库TelinkSigMeshLibExtensions.framework，demo需要导入头文件‘#import "TelinkSigMeshLib.h"’
 3.default release TelinkSigMeshLib.framework.
 */
//#define kExist
#ifndef kExist

// 1.该部分为不包含MeshOTA、remote provision代码的公开头文件
/*是否存在MeshOTA功能*/
#define kExistMeshOTA   (NO)
/*是否存在remote provision功能*/
#define kExistRemoteProvision   (NO)
/*是否存在CertificateBasedProvision功能*/
#define kExistCertificateBasedProvision   (NO)
#import <TelinkSigMeshLib/SigConst.h>
#import <TelinkSigMeshLib/SigEnumeration.h>
#import <TelinkSigMeshLib/SigStruct.h>
#import <TelinkSigMeshLib/SigLogger.h>
#import <TelinkSigMeshLib/SigModel.h>
#import <TelinkSigMeshLib/BackgroundTimer.h>
#import <TelinkSigMeshLib/SigBearer.h>
#import <TelinkSigMeshLib/SigDataSource.h>
#import <TelinkSigMeshLib/SDKLibCommand.h>
#import <TelinkSigMeshLib/SigConfigMessage.h>
#import <TelinkSigMeshLib/SigMeshMessage.h>
#import <TelinkSigMeshLib/SigMeshLib.h>
#import <TelinkSigMeshLib/SigHelper.h>
#import <TelinkSigMeshLib/SigMessageHandle.h>
#import <TelinkSigMeshLib/SigProxyConfigurationMessage.h>
#import <TelinkSigMeshLib/LibTools.h>
#import <TelinkSigMeshLib/SigGenericMessage.h>
#import <TelinkSigMeshLib/SigHearbeatMessage.h>
#import <TelinkSigMeshLib/OTAManager.h>
#import <TelinkSigMeshLib/SigPublishManager.h>
#import <TelinkSigMeshLib/TelinkHttpManager.h>
#import <TelinkSigMeshLib/SigFastProvisionAddManager.h>
#import <TelinkSigMeshLib/MeshOTAManager.h>
#import <TelinkSigMeshLib/SigRemoteAddManager.h>
#import <TelinkSigMeshLib/SigBluetooth.h>
#import <TelinkSigMeshLib/SigAddDeviceManager.h>
#import <TelinkSigMeshLib/SigPdu.h>
#import <TelinkSigMeshLib/ConnectTools.h>

#else

// 2.该部分为包含MeshOTA、remote provision代码的公开头文件
/*是否存在MeshOTA功能*/
#define kExistMeshOTA   (YES)
/*是否存在remote provision功能*/
#define kExistRemoteProvision   (YES)
/*是否存在CertificateBasedProvision功能*/
#define kExistCertificateBasedProvision   (YES)
#import <TelinkSigMeshLibExtensions/SigConst.h>
#import <TelinkSigMeshLibExtensions/SigEnumeration.h>
#import <TelinkSigMeshLibExtensions/SigStruct.h>
#import <TelinkSigMeshLibExtensions/SigLogger.h>
#import <TelinkSigMeshLibExtensions/SigModel.h>
#import <TelinkSigMeshLibExtensions/BackgroundTimer.h>
#import <TelinkSigMeshLibExtensions/SigBearer.h>
#import <TelinkSigMeshLibExtensions/SigDataSource.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand.h>
#import <TelinkSigMeshLibExtensions/SigConfigMessage.h>
#import <TelinkSigMeshLibExtensions/SigMeshMessage.h>
#import <TelinkSigMeshLibExtensions/SigMeshLib.h>
#import <TelinkSigMeshLibExtensions/SigHelper.h>
#import <TelinkSigMeshLibExtensions/SigMessageHandle.h>
#import <TelinkSigMeshLibExtensions/SigProxyConfigurationMessage.h>
#import <TelinkSigMeshLibExtensions/LibTools.h>
#import <TelinkSigMeshLibExtensions/SigGenericMessage.h>
#import <TelinkSigMeshLibExtensions/SigHearbeatMessage.h>
#import <TelinkSigMeshLibExtensions/OTAManager.h>
#import <TelinkSigMeshLibExtensions/SigPublishManager.h>
#import <TelinkSigMeshLibExtensions/TelinkHttpManager.h>
#import <TelinkSigMeshLibExtensions/SigFastProvisionAddManager.h>
#import <TelinkSigMeshLibExtensions/MeshOTAManager.h>
#import <TelinkSigMeshLibExtensions/SigRemoteAddManager.h>
#import <TelinkSigMeshLibExtensions/SigBluetooth.h>
#import <TelinkSigMeshLibExtensions/SigAddDeviceManager.h>
#import <TelinkSigMeshLibExtensions/SigPdu.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand+subnetBridge.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand+certificate.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand+opcodesAggregatorSequence.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand+privateBeacon.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand+firmwareUpdate.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand+remoteProvision.h>
#import <TelinkSigMeshLibExtensions/ConnectTools.h>
#import <TelinkSigMeshLibExtensions/OTSCommand.h>
#import <TelinkSigMeshLibExtensions/OTSBaseModel.h>
#import <TelinkSigMeshLibExtensions/OTSHandle.h>
#import <TelinkSigMeshLibExtensions/SDKLibCommand+CDTP.h>
#import <TelinkSigMeshLibExtensions/NSData+Compression.h>

#endif
