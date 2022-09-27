/********************************************************************************************************
 * @file     SigHelper.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/15
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

@interface SigHelper : NSObject


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigHelper *)share;

- (BOOL)isValidAddress:(UInt16)address;
- (BOOL)isUnassignedAddress:(UInt16)address;
- (BOOL)isUnicastAddress:(UInt16)address;
- (BOOL)isVirtualAddress:(UInt16)address;
- (BOOL)isGroupAddress:(UInt16)address;

- (int)getPeriodFromSteps:(SigStepResolution)steps;

- (NSString *)getNodeAddressString:(UInt16)address;
- (NSString *)getUint16String:(UInt16)address;
- (NSString *)getUint32String:(UInt32)address;
- (NSString *)getUint64String:(UInt64)address;

- (float)getRandomfromA:(float)a toB:(float)b;

/// The TTL field is a 7-bit field. The following values are defined:
/// • 0 = has not been relayed and will not be relayed
/// • 1 = may have been relayed, but will not be relayed
/// • 2 to 126 = may have been relayed and can be relayed
/// • 127 = has not been relayed and can be relayed
///
/// @param ttl TTL (Time To Live)
- (BOOL)isValidTTL:(UInt8)ttl;
- (BOOL)isRelayedTTL:(UInt8)ttl;

- (UInt16)getUint16LightnessFromUInt8Lum:(UInt8)lum;
- (UInt8)getUInt8LumFromUint16Lightness:(UInt16)lightness;
- (SInt16)getSInt16LevelFromUInt8Lum:(UInt8)lum;
- (UInt8)getUInt8LumFromSInt16Level:(SInt16)level;
- (UInt16)getUint16TemperatureFromUInt8Temperature100:(UInt8)temperature100;
/// use for driver pwm, 0--100 is absolute value, not related to temp range
- (UInt8)getUInt8Temperature100HWFromUint16Temperature:(UInt16)temperature;
- (UInt8)getUInt8Temperature100FromUint16Temperature:(UInt16)temperature;
- (UInt32)getDivisionRoundWithValue:(UInt32)value dividend:(UInt32)dividend;
- (UInt16)getUInt16FromSInt16:(SInt16)s16;
- (SInt16)getSInt16FromUInt16:(UInt16)u16;
- (UInt8)getOnOffFromeSInt16Level:(SInt16)level;
- (UInt16)getUInt16LightnessFromSInt16Level:(SInt16)level;
- (SInt16)getSInt16LevelFromUInt16Lightness:(UInt16)lightness;

/// response opcode, eg://SigOpCode_configAppKeyGet:0x8001->SigOpCode_configAppKeyList:0x8002
/// @param sendOpcode opcode of send command.
- (int)getResponseOpcodeWithSendOpcode:(int)sendOpcode;

- (Class)getMeshMessageWithOpCode:(SigOpCode)opCode;
- (SigOpCodeType)getOpCodeTypeWithOpcode:(UInt8)opCode;
/// get UInt8 OpCode Type
/// @param opCode 1-octet Opcodes,eg:0x00; 2-octet Opcodes,eg:0x8201; 3-octet Opcodes,eg:0xC11102
- (SigOpCodeType)getOpCodeTypeWithUInt32Opcode:(UInt32)opCode;
/// get OpCode Data
/// @param opCode 1-octet Opcodes,eg:0x00; 2-octet Opcodes,eg:0x8201; 3-octet Opcodes,eg:0xC11102
- (NSData *)getOpCodeDataWithUInt32Opcode:(UInt32)opCode;

/// opcode is encryption with deviceKey.
/// @param opCode 1-octet Opcodes,eg:0x00; 2-octet Opcodes,eg:0x8201; 3-octet Opcodes,eg:0xC11102
- (BOOL)isDeviceKeyOpCode:(UInt32)opCode;

/// Yes means message need response, No means needn't response.
/// @param message message
- (BOOL)isAcknowledgedMessage:(SigMeshMessage *)message;

- (NSString *)getDetailOfSigFirmwareUpdatePhaseType:(SigFirmwareUpdatePhaseType)phaseType;
- (NSString *)getDetailOfSigFirmwareUpdateServerAndClientModelStatusType:(SigFirmwareUpdateServerAndClientModelStatusType)statusType;
- (NSString *)getDetailOfSigBLOBTransferStatusType:(SigBLOBTransferStatusType)statusType;
- (NSString *)getDetailOfSigDirectionsFieldValues:(SigDirectionsFieldValues)directions;
- (NSString *)getDetailOfSigNodeFeaturesState:(SigNodeFeaturesState)state;
- (NSString *)getDetailOfKeyRefreshPhase:(KeyRefreshPhase)phase;
- (NSString *)getDetailOfSigNodeIdentityState:(SigNodeIdentityState)state;

@end

NS_ASSUME_NONNULL_END
