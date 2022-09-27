/********************************************************************************************************
 * @file     TelinkHttpManager.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2020/4/29
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

#import "TelinkHttpManager.h"
#import <CommonCrypto/CommonDigest.h>

#define RequestTypeGet      @"GET"
#define RequestTypePUT      @"PUT"
#define RequestTypePOST     @"POST"
#define RequestTypeDelete   @"DELETE"

//#define BaseUrl @"http://192.168.18.59:8080/"
#define BaseUrl @"http://47.115.40.63:8080/"

#define CustomErrorDomain @"cn.telink.httpRequest"

typedef void (^TelinkHttpBlock) (TelinkHttpRequest * _Nonnull request,id _Nullable result, NSError * _Nullable err);

@interface TelinkHttpRequest : NSObject<NSURLConnectionDataDelegate>
@property (copy, nonatomic) TelinkHttpBlock httpBlock;
@end

@implementation TelinkHttpRequest{
    NSMutableData *_httpReceiveData;
}

- (instancetype)init {
    if (self = [super init]) {
        _httpReceiveData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)requestWithRequestType:(NSString *)requestType withUrl:(NSString *)urlStr withHeader:(NSDictionary *)header withContent:(id)content {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:requestType];
    for (NSString *key in header.allKeys) {
        [request addValue:[header objectForKey:key] forHTTPHeaderField:key];
    }
    NSLog(@"%@", request.URL);
    NSLog(@"%@", request.HTTPMethod);
    NSLog(@"%@", header);
    if (content) {
        NSString *bodyStr = @"";
        for (NSString *key in ((NSDictionary *)content).allKeys) {
            if (bodyStr.length > 0) {
                bodyStr = [NSString stringWithFormat:@"%@&%@=%@",bodyStr,key,[(NSDictionary *)content objectForKey:key]];
            }else{
                bodyStr = [NSString stringWithFormat:@"%@=%@",key,[(NSDictionary *)content objectForKey:key]];
            }
        }
        [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (weakSelf.httpBlock) weakSelf.httpBlock(weakSelf, nil, error);
        }else{
            NSHTTPURLResponse *r = (NSHTTPURLResponse*)response;
            NSLog(@"%ld %@", (long)[r statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[r statusCode]]);
            NSInteger statusCode = [r statusCode];
            if (statusCode != 200) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (result.count>0) {
                    NSError *err = [NSError errorWithDomain:BaseUrl code:[[result objectForKey:@"status"] integerValue] userInfo:@{NSLocalizedDescriptionKey : [result objectForKey:@"message"]}];
                    if (weakSelf.httpBlock) {
                        weakSelf.httpBlock(weakSelf, nil, err);
                    }
                }else{
                    NSError *err = [NSError errorWithDomain:BaseUrl code:99999 userInfo:@{NSLocalizedDescriptionKey : @"服务器异常，请稍后···"}];
                    if (weakSelf.httpBlock) {
                        weakSelf.httpBlock(weakSelf, nil, err);
                    }
                }
            }else{
                NSError *err;
                NSDictionary *result = nil;
                if (data.length) {
                    result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                }
                if (err) {
                    if (weakSelf.httpBlock) {
                        weakSelf.httpBlock(weakSelf, nil, err);
                    }
                }else{
                    if (weakSelf.httpBlock) {
                        weakSelf.httpBlock(weakSelf, result, nil);
                    }
                }
            }
        }
    }];
    [task resume];
}

/// 1.upload json dictionary
/// @param jsonDict json dictionary
/// @param timeout Upload data effective time
/// @param block result callback
+ (TelinkHttpRequest *)uploadJsonDictionary:(NSDictionary *)jsonDict timeout:(NSInteger)timeout didLoadData:(TelinkHttpBlock)block {
    TelinkHttpRequest *req = [[TelinkHttpRequest alloc] init];
    req.httpBlock = block;
    NSDictionary *header = @{@"Content-Type" : @"application/x-www-form-urlencoded"};
    NSDictionary *content = @{@"data" : [LibTools getJSONStringWithDictionary:jsonDict],@"timeout":@(timeout)};
    [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@upload",BaseUrl] withHeader:header withContent:content];
    return req;
}

/// 2.download json dictionary
/// @param uuid identify of json dictionary
/// @param block result callback
+ (TelinkHttpRequest *)downloadJsonDictionaryWithUUID:(NSString *)uuid didLoadData:(TelinkHttpBlock)block {
    TelinkHttpRequest *req = [[TelinkHttpRequest alloc] init];
    req.httpBlock = block;
    NSDictionary *header = @{@"Content-Type" : @"application/x-www-form-urlencoded"};
    NSDictionary *content = @{@"uuid" : uuid};
    [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@download",BaseUrl] withHeader:header withContent:content];
    return req;
}

/// 3.check firmware
/// @param firewareIDString current firmware id
/// @param updateURI update URI from the response of firmwareUpdateInformationGet
/// @param block result callback
+ (TelinkHttpRequest *)firmwareCheckRequestWithFirewareIDString:(NSString *)firewareIDString updateURI:(NSString *)updateURI didLoadData:(TelinkHttpBlock)block {
    TelinkHttpRequest *req = [[TelinkHttpRequest alloc] init];
    req.httpBlock = block;
    NSDictionary *header = @{@"Content-Type" : @"application/x-www-form-urlencoded"};
    [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/check?cfwid=%@",updateURI,firewareIDString] withHeader:header withContent:nil];
    return req;
}

/// 4.get firmware
/// @param firewareIDString current firmware id
/// @param updateURI update URI from the response of firmwareUpdateInformationGet
/// @param block result callback
+ (TelinkHttpRequest *)firmwareGetRequestWithFirewareIDString:(NSString *)firewareIDString updateURI:(NSString *)updateURI didLoadData:(TelinkHttpBlock)block {
    TelinkHttpRequest *req = [[TelinkHttpRequest alloc] init];
    req.httpBlock = block;
    NSDictionary *header = @{@"Content-Type" : @"application/x-www-form-urlencoded"};
    [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/get?cfwid=%@",updateURI,firewareIDString] withHeader:header withContent:nil];
    return req;
}

@end

@interface TelinkHttpManager ()
@property (nonatomic, strong) NSMutableArray <TelinkHttpRequest *>*telinkHttpRequests;
@end

@implementation TelinkHttpManager

+ (TelinkHttpManager *)share{
    static TelinkHttpManager *shareManager = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareManager = [[TelinkHttpManager alloc] init];
        shareManager.telinkHttpRequests = [NSMutableArray array];
    });
    return shareManager;
}

/// 1.upload json dictionary
/// @param jsonDict json dictionary
/// @param timeout Upload data effective time
/// @param block result callback
- (void)uploadJsonDictionary:(NSDictionary *)jsonDict timeout:(NSInteger)timeout didLoadData:(MyBlock)block {
    __weak typeof(self) weakSelf = self;
    TelinkHttpRequest *request = [TelinkHttpRequest uploadJsonDictionary:jsonDict timeout:timeout didLoadData:^(TelinkHttpRequest * _Nonnull request, id  _Nullable result, NSError * _Nullable err) {
        [weakSelf.telinkHttpRequests removeObject:request];
        if (block) {
            block(result,err);
        }
    }];
    [_telinkHttpRequests addObject:request];
}

/// 2.download json dictionary
/// @param uuid identify of json dictionary
/// @param block result callback
- (void)downloadJsonDictionaryWithUUID:(NSString *)uuid didLoadData:(MyBlock)block {
    __weak typeof(self) weakSelf = self;
    TelinkHttpRequest *request = [TelinkHttpRequest downloadJsonDictionaryWithUUID:uuid didLoadData:^(TelinkHttpRequest * _Nonnull request, id  _Nullable result, NSError * _Nullable err) {
        [weakSelf.telinkHttpRequests removeObject:request];
        if (block) {
            block(result,err);
        }
    }];
    [_telinkHttpRequests addObject:request];
}

/// 3.check firmware
/// @param firewareIDString current firmware id
/// @param updateURI update URI from the response of firmwareUpdateInformationGet
/// @param block result callback
- (void)firmwareCheckRequestWithFirewareIDString:(NSString *)firewareIDString updateURI:(NSString *)updateURI didLoadData:(MyBlock)block {
    __weak typeof(self) weakSelf = self;
    TelinkHttpRequest *request = [TelinkHttpRequest firmwareCheckRequestWithFirewareIDString:firewareIDString updateURI:updateURI didLoadData:^(TelinkHttpRequest * _Nonnull request, id  _Nullable result, NSError * _Nullable err) {
        [weakSelf.telinkHttpRequests removeObject:request];
        if (block) {
            block(result,err);
        }
    }];
    [_telinkHttpRequests addObject:request];
}

/// 4.get firmware
/// @param firewareIDString current firmware id
/// @param updateURI update URI from the response of firmwareUpdateInformationGet
/// @param block result callback
- (void)firmwareGetRequestWithFirewareIDString:(NSString *)firewareIDString updateURI:(NSString *)updateURI didLoadData:(MyBlock)block {
    __weak typeof(self) weakSelf = self;
    TelinkHttpRequest *request = [TelinkHttpRequest firmwareGetRequestWithFirewareIDString:firewareIDString updateURI:updateURI didLoadData:^(TelinkHttpRequest * _Nonnull request, id  _Nullable result, NSError * _Nullable err) {
        [weakSelf.telinkHttpRequests removeObject:request];
        if (block) {
            block(result,err);
        }
    }];
    [_telinkHttpRequests addObject:request];
}

@end
