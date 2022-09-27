/********************************************************************************************************
 * @file     SigAuthenticationModel.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/23
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

/// The user shall provide 16 byte OOB Static Key.
typedef NSData *_Nonnull(^provideStaticKeyCallback)(void);
/// The user shall provide a number.
typedef int (^provideNumericCallback)(UInt8 maximumNumberOfDigits,OutputAction outputAction);
/// The user shall provide an alphanumeric text.
typedef NSString *_Nonnull(^provideAlphanumericCallback)(UInt8 maximumNumberOfCharacters);
/// The application should display this number to the user. User should perform selected action given number of times, or enter the number on the remote device.
typedef void (^displayNumberCallback)(int value,InputAction inputAction);
/// The application should display the text to the user. User should enter the text on the provisioning device.
typedef void (^displayAlphanumericCallback)(NSString *text);

@interface SigAuthenticationModel : NSObject
@property (nonatomic, assign) AuthenticationMethod authenticationMethod;
@property (nonatomic, assign) OutputAction outputAction;
@property (nonatomic, assign) InputAction inputAction;

///For No OOB
- (instancetype)initWithNoOob;

///For Static OOB
- (instancetype)initWithStaticOobCallback:(provideStaticKeyCallback)callback;

///For Output OOB, OutputAction is OutputAction_outputAlphanumeric.
- (instancetype)initWithOutputAlphanumericOfOutputOobCallback:(provideAlphanumericCallback)callback;

///For Output OOB, OutputAction is not OutputAction_outputAlphanumeric.
- (instancetype)initWithOutputAction:(OutputAction)outputAction outputOobCallback:(provideNumericCallback)callback;

///For Input OOB, InputAction is InputAction_inputAlphanumeric.
- (instancetype)initWithInputAlphanumericOfInputOobCallback:(displayAlphanumericCallback)callback;

///For Input OOB, InputAction is not InputAction_inputAlphanumeric.
- (instancetype)initWithInputAction:(InputAction)inputAction inputOobCallback:(displayNumberCallback)callback;

- (void)handelAuthentication:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
