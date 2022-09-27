/********************************************************************************************************
 * @file     SigStruct.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/16
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

#ifndef SigStruct_h
#define SigStruct_h

/// A set of algorithms supported by the Unprovisioned Device.
struct Algorithms {
    union{
        UInt16 value;//大端数据
        struct{
            /// FIPS P-256 Elliptic Curve algorithm is supported.
            UInt16 heightUint8      :8;//value的大端数据的高8个bit
            /// BTM_ECDH_P256_CMAC_AES128_AES_CCM
            UInt16 fipsP256EllipticCurve             :1;//value的大端数据的低位第1个bit
            /// BTM_ECDH_P256_HMAC_SHA256_AES_CCM
            UInt16 fipsP256EllipticCurve_HMAC_SHA256 :1;//value的大端数据的低位第2个bit
        };
    };
};

/// A set of supported Static Out-of-band types.
struct StaticOobType {
    union{
        UInt8 value;
        struct{
            /// Static OOB Information is available.
            UInt8 staticOobInformationAvailable      :1;//value的低1个bit
        };
    };
};

/// Information that points to out-of-band (OOB) information needed for provisioning.
/// Table 3.65: OOB Information field.
/// - seeAlso: MshPRFd1.1r11_clean.pdf  (page.197)
struct OobInformation {
    union{
        UInt16 value;
        struct{
            UInt8 other      :1;//value的低1个bit
            UInt8 electronicOrURI :1;//val的低位第2个bit
            UInt8 qrCode :1;//val的低位第3个bit
            UInt8 barCode :1;//val的低位第4个bit
            UInt8 nfc :1;//val的低位第5个bit
            UInt8 number :1;//val的低位第6个bit
            UInt8 string :1;//val的低位第7个bit
            UInt8 supportForCertificateBasedProvisioning :1;//val的低位第8个bit
            UInt8 supportForProvisioningRecords :1;//val的低位第9个bit
            UInt8 reservedForFutureUse1 :1;//val的低位第10个bit
            UInt8 reservedForFutureUse2 :1;//val的低位第11个bit
            UInt8 onBox :1;//val的低位第12个bit
            UInt8 insideBox :1;//val的低位第13个bit
            UInt8 onPieceOfPaper :1;//val的低位第14个bit
            UInt8 insideManual :1;//val的低位第15个bit
            UInt8 onDevice :1;//val的低位第16个bit
        };
    };
};

/// A set of supported Output Out-of-band actions.
struct OutputOobActions {
    union{
        UInt16 value;
        struct{
            UInt8 blink      :1;//value的低1个bit
            UInt8 beep :1;//val的低位第2个bit
            UInt8 vibrate :1;//val的低位第3个bit
            UInt8 outputNumeric :1;//val的低位第4个bit
            UInt8 outputAlphanumeric :1;//val的低位第5个bit
            UInt8 reservedForFutureUse6 :1;//val的低位第6个bit
            UInt8 reservedForFutureUse7 :1;//val的低位第7个bit
            UInt8 reservedForFutureUse8 :1;//val的低位第8个bit
            UInt8 reservedForFutureUse9 :1;//val的低位第9个bit
            UInt8 reservedForFutureUse10 :1;//val的低位第10个bit
            UInt8 reservedForFutureUse11 :1;//val的低位第11个bit
            UInt8 reservedForFutureUse12 :1;//val的低位第12个bit
            UInt8 reservedForFutureUse13 :1;//val的低位第13个bit
            UInt8 reservedForFutureUse14 :1;//val的低位第14个bit
            UInt8 reservedForFutureUse15 :1;//val的低位第15个bit
            UInt8 reservedForFutureUse16 :1;//val的低位第16个bit
        };
    };
};

/// A set of supported Input Out-of-band actions.
struct InputOobActions {
    union{
        UInt16 value;
        struct{
            UInt8 push      :1;//value的低1个bit
            UInt8 twist :1;//val的低位第2个bit
            UInt8 inputNumeric :1;//val的低位第3个bit
            UInt8 inputAlphanumeric :1;//val的低位第4个bit
            UInt8 reservedForFutureUse5 :1;//val的低位第5个bit
            UInt8 reservedForFutureUse6 :1;//val的低位第6个bit
            UInt8 reservedForFutureUse7 :1;//val的低位第7个bit
            UInt8 reservedForFutureUse8 :1;//val的低位第8个bit
            UInt8 reservedForFutureUse9 :1;//val的低位第9个bit
            UInt8 reservedForFutureUse10 :1;//val的低位第10个bit
            UInt8 reservedForFutureUse11 :1;//val的低位第11个bit
            UInt8 reservedForFutureUse12 :1;//val的低位第12个bit
            UInt8 reservedForFutureUse13 :1;//val的低位第13个bit
            UInt8 reservedForFutureUse14 :1;//val的低位第14个bit
            UInt8 reservedForFutureUse15 :1;//val的低位第15个bit
            UInt8 reservedForFutureUse16 :1;//val的低位第16个bit
        };
    };
};

struct ProvisioningCapabilities {
    union{
        UInt8 value[12];
        struct{
            ///this struct is invalid when pduType is not equal SigProvisioningPduType_capabilities
            SigProvisioningPduType pduType;//1byte
            /// Number of elements supported by the device.
            UInt8 numberOfElements;//1byte
            /// Supported algorithms and other capabilities.
            struct Algorithms algorithms;//2bytes
            /// Supported public key types.
            PublicKeyType publicKeyType;//1byte
            /// Supported static OOB Types.
            struct StaticOobType staticOobType;//1byte
            /// Maximum size of Output OOB supported.
            UInt8 outputOobSize;//1byte
            /// Supported Output OOB Actions.
            struct OutputOobActions outputOobActions;//2bytes
            /// Maximum size of Input OOB supported.
            UInt8 inputOobSize;//1byte
            /// Supported Input OOB Actions.
            struct InputOobActions inputOobActions;//2bytes
        };
    };
    
};

struct Flags {
    union{
        UInt8 value;
        struct{
            /// Static OOB Information is available.
            UInt8 keyRefreshFinalizing  :1;//value的低1个bit
            UInt8 ivUpdateActive  :1;//val的低位第2个bit
        };
    };
};

typedef struct {
    union{
        UInt16 value;
        struct{
            UInt8 SigFeatures_relay      :1;//value的低1个bit
            UInt8 SigFeatures_proxy :1;//val的低位第2个bit
            UInt8 SigFeatures_friend :1;//val的低位第3个bit
            UInt8 SigFeatures_lowPower :1;//val的低位第4个bit
        };
    };
}SigFeatures;

/// The Additional Information bitfield
/// - seeAlso: Mesh_Firmware_update_20180228_d05r05.pdf  (page.28)
typedef struct {
    union{
        UInt8 value;
        struct{
            /// When set to 1 the device be in unprovisioned state after the new FW is applied (possibly due to new models added).
            UInt8 ProvisioningNeeded  :1;//value的低1个bit
        };
    };
}SigAdditionalInformation;


/// 7.2.2.7.7 Supported Transfer Mode
/// - seeAlso: MshMDL_DFU_MBT_CR_R06.pdf  (page.25)
struct SigSupportedTransferMode {
    union{
        UInt8 value;
        struct{
            /// Static OOB Information is available.
            UInt8 PushBLOBTransferModeBit      :1;//value的低1个bit
            UInt8 PullBLOBTransferModeBit      :1;//value的低位第2个bit
            // 2-7 Reserved For Future Use
        };
    };
};

#endif /* SigStruct_h */
