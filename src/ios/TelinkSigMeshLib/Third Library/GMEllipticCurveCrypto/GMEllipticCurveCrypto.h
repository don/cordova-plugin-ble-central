//
//  GMEllipticCurveCrypto.h
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

#import <Foundation/Foundation.h>


/**
 *  This is an Objective-C wrapper for easy-ecc by Kenneth MacKay, slightly re-written
 *  to support choosing a curve at runtime.
 *
 *  To generate a new key-pair:
 *    GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto generateKeyPairForCurve:GMEllipticCurveSecp256r1];
 *    NSLog(@"PublicKey=%@, PrivateKey=%@", crypto.publicKeyBase64, crypto.privateKeyBase64);
 *
 *  To sign a message hash:
 *    GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto initWithCurve:GMEllipticCurveSecp256r1];
 *    crypto.privateKeyBase64 = @"PimSbZgj6h+Q7kqRZMn9Bo6qAhoDhEsvXa+uiO4mJD8=";
 *    NSData *signature = [crypto signatureForHash:hash];
 *
 *  To verify a signature:
 *    GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto initWithCurve:GMEllipticCurveSecp256r1];
 *    crypto.publicKeyBase64 = @"A2BKB2Io3hPPuQAGDDDUeGr/juQr9OxdlDFypcyKDm1M"
 *    int valid = [crypto verifySignature:signature forHash:hash];
 *
 */


typedef enum GMEllipticCurve {
    GMEllipticCurveNone      = 0,
    GMEllipticCurveSecp128r1 = 128,
    GMEllipticCurveSecp192r1 = 192,
    GMEllipticCurveSecp256r1 = 256,
    GMEllipticCurveSecp384r1 = 384,
} GMEllipticCurve;



@interface GMEllipticCurveCrypto : NSObject


/**
 *  Create a new instance with new public key and private key pair.
 */
+ (GMEllipticCurveCrypto*)generateKeyPairForCurve: (GMEllipticCurve)curve;


/**
 *  Given a private key or public key, determine which is the appropriate curve
 */
+ (GMEllipticCurve)curveForKey: (NSData*)privateOrPublicKey;
+ (GMEllipticCurve)curveForKeyBase64: (NSString*)privateOrPublicKey;


/**
 *  Given a private key or public key, create an instance with the appropriate curve and key
 */
+ (GMEllipticCurveCrypto*)cryptoForKey: (NSData*)privateOrPublicKey;
+ (GMEllipticCurveCrypto*)cryptoForKeyBase64: (NSString*)privateOrPublicKey;


+ (id)cryptoForCurve: (GMEllipticCurve)curve;
- (id)initWithCurve: (GMEllipticCurve)curve;

/**
 *  The length of the curve in bits.
 */
@property (nonatomic, readonly) int bits;

/**
 *  The common name given to the curve (e.g. secp192r1).
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  Determines whether the public key will be compressed or uncompressed.
 *
 *  It is updated when a public key is assigned and can be changed anytime
 *  to select what the publicKey property emits.
 *
 *  A compressed point stores only the x co-ordinate of the point as well as
 *  a leading byte to indicate the parity of the y co-ordinate, which can then
 *  be computed from x.
 *
 *  By default, keys are compressed.
 */
@property (nonatomic, assign) BOOL compressedPublicKey;

/**
 *  The public key for an elliptic curve.
 *
 *  A compressed public key's length is ((curve_bits / 8) + 1) bytes.
 *  An uncompressed public key's length is (2 * (curve_bits / 8) + 1) bytes.
 */
@property (nonatomic, strong) NSData *publicKey;

/**
 *  The public key encoded in base64
 */
@property (nonatomic, strong) NSString *publicKeyBase64;

/**
 *  The private key for an elliptic curve.
 *
 *  This is also sometimes referred to as the secret exponent.
 *
 *  A private key's length is (crypto_bits / 8) bytes.
 */
@property (nonatomic, strong) NSData *privateKey;

/**
 *  The private key encoded in base64
 */
@property (nonatomic, strong) NSString *privateKeyBase64;


@property (nonatomic, readonly) int sharedSecretLength;
- (NSData*)sharedSecretForPublicKey: (NSData*)otherPublicKey;
- (NSData*)sharedSecretForPublicKeyBase64: (NSString*)otherPublicKeyBase64;

@property (nonatomic, readonly) int hashLength;
- (NSData*)signatureForHash: (NSData*)hash;

@property (nonatomic, readonly) int signatureLength;
- (BOOL)verifySignature: (NSData*)signature forHash: (NSData*)hash;

@end
