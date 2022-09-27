/********************************************************************************************************
 * @file     SigLogger.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/16
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

#import "SigLogger.h"
#import <sys/time.h>
#import <CommonCrypto/CommonCryptor.h>

#define kTelinkSDKDebugLogData @"TelinkSDKDebugLogData"
#define kTelinkSDKMeshJsonData @"TelinkSDKMeshJsonData"
#if DEBUG
#define kTelinkSDKDebugLogDataSize ((double)1024*1024*100) //DEBUG默认日志最大存储大小为100M。每10*60秒检查一次日志文件大小。
#else
#define kTelinkSDKDebugLogDataSize ((double)1024*1024*20) //RELEASE默认日志最大存储大小为20M。每10*60秒检查一次日志文件大小。
#endif

@interface SigLogger ()
@property (nonatomic, strong) BackgroundTimer *timer;
@end

@implementation SigLogger

+ (SigLogger *)share{
    static SigLogger *shareLogger = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareLogger = [[SigLogger alloc] init];
    });
    return shareLogger;
}

- (void)initLogFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:self.logFilePath]) {
        BOOL ret = [manager createFileAtPath:self.logFilePath contents:nil attributes:nil];
        if (ret) {
            NSLog(@"%@",@"creat success");
        } else {
            NSLog(@"%@",@"creat failure");
        }
    }
    if (![manager fileExistsAtPath:self.meshJsonFilePath]) {
        BOOL ret = [manager createFileAtPath:self.meshJsonFilePath contents:nil attributes:nil];
        if (ret) {
            NSLog(@"%@",@"creat TelinkSDKMeshJsonData success");
        } else {
            NSLog(@"%@",@"creat TelinkSDKMeshJsonData failure");
        }
    }
}

- (NSString *)logFilePath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:kTelinkSDKDebugLogData];
}

- (NSString *)meshJsonFilePath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:kTelinkSDKMeshJsonData];
}

- (void)setSDKLogLevel:(SigLogLevel)logLevel{
    _logLevel = logLevel;
    if (logLevel != SigLogLevelOff) {
        [self initLogFile];
        __weak typeof(self) weakSelf = self;
        _timer = [BackgroundTimer scheduledTimerWithTimeInterval:10 * 60 repeats:YES block:^(BackgroundTimer * _Nonnull t) {
            [weakSelf checkSDKLogFileSize];
        }];
        [self checkSDKLogFileSize];
        [self enableLogger];
    } else {
        //OFF状态则删除TelinkSDKDebugLogData和加密的TelinkSDKMeshJsonData。
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:self.logFilePath]) {
            [manager removeItemAtPath:self.logFilePath error:nil];
        }
        if ([manager fileExistsAtPath:self.meshJsonFilePath]) {
            [manager removeItemAtPath:self.meshJsonFilePath error:nil];
        }
    }
}

- (void)enableLogger{
    TelinkLogWithFile(YES,[NSString stringWithFormat:@"\n\n\n\n\t打开APP，初始化TelinkSigMesh %@日志模块\n\n\n",kTelinkSigMeshLibVersion]);
}

/// 监测缓存本地的日志文件大小，大于阈值则砍掉多余部分，只保留阈值的80%。
- (void)checkSDKLogFileSize {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:SigLogger.share.logFilePath];
    NSData *data = [handle readDataToEndOfFile];
    [handle closeFile];
    NSInteger length = data.length;
    if (length > kTelinkSDKDebugLogDataSize) {
        NSInteger saveLength = ceil(kTelinkSDKDebugLogDataSize * 0.8);
        //该写法是解决直接裁剪NSData导致部分字符串被裁剪了一般导致NSData转NSString异常，从而出现log文件很大但log的字符串却很短的bug。
        NSData *saveData = [NSData data];
        do {
            if (saveData.length > 0) {
                data = saveData;
            }
            NSString *oldStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *subStr = [oldStr substringFromIndex:ceil(oldStr.length * 0.2)];
            saveData = [subStr dataUsingEncoding:NSUTF8StringEncoding];
        } while (saveData.length > saveLength);
        NSData *tem = [@"[replace some log]\n" dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *mData = [NSMutableData dataWithData:tem];
        [mData appendData:saveData];
        handle = [NSFileHandle fileHandleForWritingAtPath:SigLogger.share.logFilePath];
        [handle truncateFileAtOffset:0];
        [handle writeData:mData];
        [handle closeFile];
    }
}

static NSFileHandle *fileHandle = nil;
static NSFileHandle *TelinkLogFileHandle()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:SigLogger.share.logFilePath]) {
            BOOL ret = [manager createFileAtPath:SigLogger.share.logFilePath contents:nil attributes:nil];
            if (ret) {
                NSLog(@"%@",@"creat success");
            } else {
                NSLog(@"%@",@"creat failure");
            }
        }
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:SigLogger.share.logFilePath];
        [fileHandle seekToEndOfFile];
    });
    return fileHandle;
}

extern void TelinkLogWithFile(BOOL show,NSString *format, ...) {
    va_list L;
    va_start(L, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:L];
    if (show) {
        NSLog(@"%@", message);
    }
    // 开启异步子线程，将打印写入文件
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileHandle *output = TelinkLogFileHandle();
        if (output != nil) {
            time_t rawtime;
            struct tm timeinfo;
            char buffer[64];
            time(&rawtime);
            localtime_r(&rawtime, &timeinfo);
            struct timeval curTime;
            gettimeofday(&curTime, NULL);
            int milliseconds = curTime.tv_usec / 1000;
            strftime(buffer, 64, "%Y-%m-%d %H:%M", &timeinfo);
            char fullBuffer[128] = { 0 };
            snprintf(fullBuffer, 128, "%s:%2d.%.3d ", buffer, timeinfo.tm_sec, milliseconds);
            [output writeData:[[[NSString alloc] initWithCString:fullBuffer encoding:NSASCIIStringEncoding] dataUsingEncoding:NSUTF8StringEncoding]];
            [output writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
            static NSData *returnData = nil;
            if (returnData == nil)
                returnData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
            [output writeData:returnData];
        }
    });
    va_end(L);
}

- (void)clearAllLog {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:self.logFilePath]) {
        [fileManage removeItemAtPath:self.logFilePath error:nil];
    }
    [self initLogFile];
    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:SigLogger.share.logFilePath];
    [fileHandle seekToEndOfFile];
}

- (NSString *)getLogStringWithLength:(NSInteger)length {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:SigLogger.share.logFilePath];
    NSData *data = [handle readDataToEndOfFile];
    NSString *str = @"";
    if (data.length > length) {
        str = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(data.length - length, length)] encoding:NSUTF8StringEncoding];
    } else {
        str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    [handle closeFile];
    return str;
}

void saveMeshJsonData(id data){
    if (SigLogger.share.logLevel > 0) {
        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:SigLogger.share.meshJsonFilePath];
        [handle truncateFileAtOffset:0];
        if ([data isKindOfClass:[NSData class]]) {
            [handle writeData:(NSData *)data];
        }else{
            NSString *tempString = [[NSString alloc] initWithFormat:@"%@",data];
            //对缓存于iTunes共享文件夹的json文件进行加密，再保存。解密调用接口textFromBase64String.
            tempString = [SigLogger.share base64StringFromText:tempString];
            NSData *tempData = [tempString dataUsingEncoding:NSUTF8StringEncoding];
            [handle writeData:tempData];
        }
        [handle closeFile];
    }
}

/// 用于解密客户上传的加密后的TelinkSDKMeshJsonData文件
- (NSString *)getDecryptTelinkSDKMeshJsonData {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:SigLogger.share.meshJsonFilePath];
    NSData *data = [handle readDataToEndOfFile];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //对缓存于iTunes共享文件夹的json文件进行解密。加密调用接口base64StringFromText.
    str = [SigLogger.share textFromBase64String:str];
    [handle closeFile];
    return str;
}

/// 用于解密客户上传的加密后的TelinkSDKMeshJsonData文件
- (NSString *)getDecryptTelinkSDKMeshJsonDataWithPassword:(NSString *)password {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:SigLogger.share.meshJsonFilePath];
    NSData *data = [handle readDataToEndOfFile];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    str = [SigLogger.share textFromBase64String:str password:password];
    [handle closeFile];
    return str;
}

#pragma mark - base64加解密相关

#define     LocalStr_None           @""

/******************************************************************************
 函数名称 : - (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 ******************************************************************************/
- (NSString *)base64StringFromText:(NSString *)text {
    if (text && ![text isEqualToString:LocalStr_None]) {
        NSString *key = @"com.telink.TelinkSDKMeshJsonData";
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin  改动了此处
        data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64EncodedStringFrom:data];
    }
    else {
        return LocalStr_None;
    }
}

/******************************************************************************
 函数名称 : - (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 ******************************************************************************/
- (NSString *)textFromBase64String:(NSString *)base64 {
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        NSString *key = @"com.telink.TelinkSDKMeshJsonData";
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin    改动了此处
        data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return LocalStr_None;
    }
}

- (NSString *)textFromBase64String:(NSString *)base64 password:(NSString *)password {
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin    改动了此处
        data = [self DESDecrypt:data WithKey:password];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return LocalStr_None;
    }
}

/******************************************************************************
 函数名称 : - (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
- (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : - (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
- (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/******************************************************************************
 函数名称 : - (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 ******************************************************************************/
- (NSData *)dataWithBase64EncodedString:(NSString *)string {
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:@""];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/******************************************************************************
 函数名称 : - (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
- (NSString *)base64EncodedStringFrom:(NSData *)data {
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end
