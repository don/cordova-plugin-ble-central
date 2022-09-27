//
//  GMEllipticCurveCrypto+hash.m
//
//  BSD 2-Clause License
//
//  Copyright (c) 2014 Richard Moore.
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//


#import "GMEllipticCurveCrypto+hash.h"

#import <CommonCrypto/CommonDigest.h>

NSData *derEncodeInteger(NSData *value) {
    int length = (int)[value length];
    const unsigned char *data = [value bytes];

    int outputIndex = 0;
    unsigned char output[[value length] + 3];

    output[outputIndex++] = 0x02;

    // Find the first non-zero entry in value
    int start = 0;
    while (start < length && data[start] == 0){ start++; }

    // Add the length and zero padding to preserve sign
    if (start == length || data[start] >= 0x80) {
        output[outputIndex++] = length - start + 1;
        output[outputIndex++] = 0x00;
    } else {
        output[outputIndex++] = length - start;
    }

    [value getBytes:&output[outputIndex] range:NSMakeRange(start, length - start)];
    outputIndex += length - start;

    return [NSData dataWithBytes:output length:outputIndex];
}

NSData *derEncodeSignature(NSData *signature) {

    int length = (int)[signature length];
    if (length % 2) { return nil; }

    NSData *rValue = derEncodeInteger([signature subdataWithRange:NSMakeRange(0, length / 2)]);
    NSData *sValue = derEncodeInteger([signature subdataWithRange:NSMakeRange(length / 2, length / 2)]);

    // Begin with the sequence tag and sequence length
    unsigned char header[2];
    header[0] = 0x30;
    header[1] = [rValue length] + [sValue length];

    // This requires a long definite octet stream (signatures aren't this long)
    if (header[1] >= 0x80) { return nil; }

    NSMutableData *encoded = [NSMutableData dataWithBytes:header length:2];
    [encoded appendData:rValue];
    [encoded appendData:sValue];

    return [encoded copy];
}


NSRange derDecodeSequence(const unsigned char *bytes, int length, int index) {
    NSRange result;
    result.location = NSNotFound;

    // Make sure we are long enough and have a sequence
    if (length - index > 2 && bytes[index] == 0x30) {

        // Make sure the input buffer is large enough
        int sequenceLength = bytes[index + 1];
        if (index + 2 + sequenceLength <= length) {
            result.location = index + 2;
            result.length = sequenceLength;
        }
    }

    return result;
}

NSRange derDecodeInteger(const unsigned char *bytes, int length, int index) {
    NSRange result;
    result.location = NSNotFound;

    // Make sure we are long enough and have an integer
    if (length - index > 3 && bytes[index] == 0x02) {

        // Make sure the input buffer is large enough
        int integerLength = bytes[index + 1];
        if (index + 2 + integerLength <= length) {

            // Strip any leading zero, used to preserve sign
            if (bytes[index + 2] == 0x00) {
                result.location = index + 3;
                result.length = integerLength - 1;

            } else {
                result.location = index + 2;
                result.length = integerLength;
            }
        }
    }

    return result;
}

NSData *derDecodeSignature(NSData *der, int keySize) {
    int length = (int)[der length];
    const unsigned char *data = [der bytes];

    // Make sure we have a sequence
    NSRange sequence = derDecodeSequence(data, length, 0);
    if (sequence.location == NSNotFound) { return nil; }

    // Extract the r value (first item)
    NSRange rValue = derDecodeInteger(data, length, (int)sequence.location);
    if (rValue.location == NSNotFound || rValue.length > keySize) { return nil; }

    // Extract the s value (second item)
    int sStart = (int)rValue.location + (int)rValue.length;
    NSRange sValue = derDecodeInteger(data, length, sStart);
    if (sValue.location == NSNotFound || sValue.length > keySize) { return nil; }

    // Create an empty array with 0's
    unsigned char output[2 * keySize];
    bzero(output, 2 * keySize);

    // Copy the r and s value in, right aligned to zero adding
    [der getBytes:&output[keySize - rValue.length] range:NSMakeRange(rValue.location, rValue.length)];
    [der getBytes:&output[2 * keySize - sValue.length] range:NSMakeRange(sValue.location, sValue.length)];

    return [NSData dataWithBytes:output length:2 * keySize];
}


@implementation GMEllipticCurveCrypto (hash)

- (BOOL)hashSHA256AndVerifySignature:(NSData *)signature forData:(NSData *)data {
    int bytes = self.bits / 8;

    if (bytes > CC_SHA256_DIGEST_LENGTH) {
      NSLog(@"ERROR: SHA256 hash is too short for curve");
      return NO;
    }

    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (int)[data length], hash);
    return [self verifySignature:signature forHash:[NSData dataWithBytes:hash length:bytes]];
}


- (NSData*)hashSHA256AndSignData:(NSData *)data {
    int bytes = self.bits / 8;

    if (bytes > CC_SHA256_DIGEST_LENGTH) {
      NSLog(@"ERROR: SHA256 hash is too short for curve");
      return nil;
    }

    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (int)[data length], hash);
    return [self signatureForHash:[NSData dataWithBytes:hash length:bytes]];
}


- (BOOL)hashSHA384AndVerifySignature:(NSData *)signature forData:(NSData *)data {
    int bytes = self.bits / 8;

    unsigned char hash[CC_SHA384_DIGEST_LENGTH];
    CC_SHA384([data bytes], (int)[data length], hash);
    return [self verifySignature:signature forHash:[NSData dataWithBytes:hash length:bytes]];
}


- (NSData*)hashSHA384AndSignData:(NSData *)data {
    int bytes = self.bits / 8;

    unsigned char hash[CC_SHA384_DIGEST_LENGTH];
    CC_SHA384([data bytes], (int)[data length], hash);
    return [self signatureForHash:[NSData dataWithBytes:hash length:bytes]];
}


- (NSData*)encodedSignatureForHash: (NSData*)hash {
    NSData *signature = [self signatureForHash:hash];
    return derEncodeSignature(signature);
}

- (NSData*)hashSHA256AndSignDataEncoded: (NSData*)data {
    NSData *signature = [self hashSHA256AndSignData:data];
    return derEncodeSignature(signature);
}

- (NSData*)hashSHA384AndSignDataEncoded: (NSData*)data {
    NSData *signature = [self hashSHA384AndSignData:data];
    return derEncodeSignature(signature);
}


- (BOOL)verifyEncodedSignature: (NSData*)encodedSignature forHash: (NSData*)hash {
    NSData *signature = derDecodeSignature(encodedSignature, self.bits / 8);
    return [self verifySignature:signature forHash:hash];
}

- (BOOL)hashSHA256AndVerifyEncodedSignature: (NSData*)encodedSignature forData: (NSData*)data {
    NSData *signature = derDecodeSignature(encodedSignature, self.bits / 8);
    return [self hashSHA256AndVerifySignature:signature forData:data];
}

- (BOOL)hashSHA384AndVerifyEncodedSignature: (NSData*)encodedSignature forData: (NSData*)data {
    NSData *signature = derDecodeSignature(encodedSignature, self.bits / 8);
    return [self hashSHA384AndVerifySignature:signature forData:data];
}


@end
