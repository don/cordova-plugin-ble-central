/********************************************************************************************************
 * @file     SigAuthenticationModel.m
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

#import "SigAuthenticationModel.h"

@interface SigAuthenticationModel ()
@property (nonatomic,copy) provideStaticKeyCallback provideStaticKeyBlock;
@property (nonatomic,copy) provideAlphanumericCallback provideAlphanumericBlock;
@property (nonatomic,copy) provideNumericCallback provideNumericBlock;
@property (nonatomic,copy) displayAlphanumericCallback displayAlphanumericBlock;
@property (nonatomic,copy) displayNumberCallback displayNumberBlock;

@end

@implementation SigAuthenticationModel

///For No OOB
- (instancetype)initWithNoOob{
    if (self = [super init]) {
        _authenticationMethod = AuthenticationMethod_noOob;
    }
    return self;
}

///For Static OOB
- (instancetype)initWithStaticOobCallback:(provideStaticKeyCallback)callback{
    if (self = [super init]) {
        _authenticationMethod = AuthenticationMethod_staticOob;
        _provideStaticKeyBlock = callback;
    }
    return self;
}

///For Output OOB, OutputAction is OutputAction_outputAlphanumeric.
- (instancetype)initWithOutputAlphanumericOfOutputOobCallback:(provideAlphanumericCallback)callback{
    if (self = [super init]) {
        _authenticationMethod = AuthenticationMethod_outputOob;
        _outputAction = OutputAction_outputAlphanumeric;
        _provideAlphanumericBlock = callback;
    }
    return self;
}

///For Output OOB, OutputAction is not OutputAction_outputAlphanumeric.
- (instancetype)initWithOutputAction:(OutputAction)outputAction outputOobCallback:(provideNumericCallback)callback{
    if (self = [super init]) {
        _authenticationMethod = AuthenticationMethod_outputOob;
        _outputAction = outputAction;
        _provideNumericBlock = callback;
    }
    return self;
}

///For Input OOB, InputAction is InputAction_inputAlphanumeric.
- (instancetype)initWithInputAlphanumericOfInputOobCallback:(displayAlphanumericCallback)callback{
    if (self = [super init]) {
        _authenticationMethod = AuthenticationMethod_inputOob;
        _inputAction = InputAction_inputAlphanumeric;
        _displayAlphanumericBlock = callback;
    }
    return self;
}

///For Input OOB, InputAction is not InputAction_inputAlphanumeric.
- (instancetype)initWithInputAction:(InputAction)inputAction inputOobCallback:(displayNumberCallback)callback{
    if (self = [super init]) {
        _authenticationMethod = AuthenticationMethod_inputOob;
        _inputAction = inputAction;
        _displayNumberBlock = callback;
    }
    return self;
}

- (void)handelAuthentication:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION {
//    switch (self.authenticationMethod) {
//        case AuthenticationMethod_staticOob:
//            if (self.provideStaticKeyBlock) {
//                self.provideStaticKeyBlock();
//            }
//            break;
//        case AuthenticationMethod_outputOob:
//            if (self.outputAction == OutputAction_outputAlphanumeric) {
//                if (self.provideAlphanumericBlock) {
//                    self.provideAlphanumericBlock((UInt8)firstArg);
//                }
//            } else {
//                if (self.provideNumericBlock) {
//                    // 定义一个指向个数可变的参数列表指针；
//                    va_list args;
////                    // 用于存放取出的参数
////                    id arg;
//                    // 初始化变量刚定义的va_list变量，这个宏的第二个参数是第一个可变参数的前一个参数，是一个固定的参数
//                    va_start(args, firstArg);
////                    OutputAction secondArg;
////                    // 遍历全部参数 va_arg返回可变的参数(a_arg的第二个参数是你要返回的参数的类型)
////                    while ((arg = va_arg(args, id))) {
////                        NSLog(@"%@", arg);
////                        secondArg = (OutputAction)arg;
////                        break;
////                    }
//                    OutputAction secondArg = (OutputAction)va_arg(args, id);
//                    self.provideNumericBlock((UInt8)firstArg,secondArg);
//                    // 清空参数列表，并置参数指针args无效
//                    va_end(args);
//                }
//            }
//            break;
//        case AuthenticationMethod_inputOob:
//            if (self.inputAction == InputAction_inputAlphanumeric) {
//                if (self.displayAlphanumericBlock) {
//                    self.displayAlphanumericBlock((NSString *)firstArg);
//                }
//            } else {
//                if (self.displayNumberBlock) {
//                    va_list args;
//                    va_start(args, firstArg);
//                    InputAction secondArg = (InputAction)va_arg(args, id);
//
//                    self.displayNumberBlock([(NSNumber *)firstArg intValue],secondArg);
//                }
//            }
//            break;
//        default:
//            break;
//    }
}

@end
