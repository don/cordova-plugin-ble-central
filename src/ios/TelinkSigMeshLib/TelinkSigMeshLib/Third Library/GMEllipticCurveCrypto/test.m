#import <Foundation/Foundation.h>

#import "GMEllipticCurveCrypto.h"

#import "GMEllipticCurveCrypto+hash.h"

NSData *derEncodeSignature(NSData* signature);
NSData *derDecodeSignature(NSData *der, int keySize);

int main(int argc, const char* argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  // An array to use as a mock hash
  char bytes[] = { 'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd', 'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd', 'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd', 'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd', 'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r' };

  // Known correct signatures
  char testSignatureBytes128[] = { 214, 138, 215, 43, 250, 68, 103, 223, 115, 61, 241, 123, 47, 6, 196, 189, 113, 246, 160, 32, 144, 117, 138, 22, 215, 25, 203, 17, 3, 151, 200, 203 };
  char testSignatureBytes192[] = { 199, 223, 65, 13, 185, 52, 137, 221, 84, 112, 88, 136, 162, 140, 50, 234, 89, 22, 85, 44, 126, 42, 222, 78, 226, 144, 207, 160, 158, 121, 189, 128, 33, 46, 94, 206, 178, 61, 243, 82, 50, 18, 193, 230, 250, 225, 175, 142};
  char testSignatureBytes256[] = { 215, 198, 74, 39, 103, 114, 174, 147, 90, 50, 12, 211, 62, 113, 40, 150, 16, 22, 66, 52, 189, 149, 201, 170, 170, 215, 75, 204, 151, 140, 113, 0, 229, 145, 205, 8, 94, 242, 104, 127, 118, 222, 96, 53, 135, 213, 199, 51, 41, 18, 247, 85, 23, 83, 77, 88, 68, 247, 150, 183, 50, 240, 227, 222};
  char testSignatureBytes384[] = { 20, 190, 42, 149, 241, 82, 180, 63, 226, 17, 190, 209, 35, 4, 110, 33, 18, 66, 231, 124, 178, 49, 236, 12, 83, 213, 36, 112, 176, 199, 164, 172, 12, 87, 196, 29, 199, 73, 79, 87, 68, 201, 89, 166, 40, 126, 3, 13, 197, 45, 27, 238, 121, 118, 80, 42, 50, 187, 239, 131, 71, 209, 37, 209, 247, 78, 61, 134, 18, 188, 164, 231, 136, 155, 241, 210, 68, 77, 169, 203, 96, 18, 202, 249, 53, 214, 83, 253, 45, 148, 166, 137, 28, 73, 22, 141 };

  // Test each curve
  for (int i = 0; i < 4; i++) {

    // Select the curve to test and some known correct test data
    GMEllipticCurve curve = GMEllipticCurveNone;
    NSString *curveName = nil;
    NSString *alicePublicKey, *aliceUncompressedPublicKey, *alicePrivateKey, *bobPublicKey, *bobPrivateKey;

    // Known correct signatures
    char *testSignatureBytes;

    // Variables we use
    GMEllipticCurveCrypto *crypto;
    NSData *messageHash, *signature;
    BOOL valid;

    switch (i) {
      case 0:
        curve = GMEllipticCurveSecp128r1;
        curveName = @"GMEllipticCurveSecp128r1";

        alicePublicKey = @"A/DSn7VEbavr9BNXdkc9YaM=";
        aliceUncompressedPublicKey = @"BPDSn7VEbavr9BNXdkc9YaO5G8Z+WQrkPDsfAuEMN2Bj";
        alicePrivateKey = @"LRtdqpOXEmdZuG+kHdl7iw==";
        bobPublicKey = @"Atogpx1pGlak5vVpOP6pwYw=";
        bobPrivateKey = @"B3rloJxb2h1uX+Cin/0Big==";

        testSignatureBytes = testSignatureBytes128;

        break;

      case 1:
        curve = GMEllipticCurveSecp192r1;
        curveName = @"GMEllipticCurveSecp192r1";

        alicePublicKey = @"AjKrRgg7c5t3JduLDuLL3n9Eap/JHo+32g==";
        aliceUncompressedPublicKey = @"BDKrRgg7c5t3JduLDuLL3n9Eap/JHo+32i0q7Dr9+yeILhMirgHnqQIRAKC2j1gBqA==";
        alicePrivateKey = @"bOr7KLf1mrqh3ZW1Zmu2rTwmv8GtjzOs";
        bobPublicKey = @"A5WjHAPDpwdMn0CuCqW03gksQ29nO9OuTw==";
        bobPrivateKey = @"3zA52Irsxvm549QMeHaJ1K6arJz4XGrn";

        testSignatureBytes = testSignatureBytes192;

        break;

      case 2:
        curve = GMEllipticCurveSecp256r1;
        curveName = @"GMEllipticCurveSecp256r1";

        alicePublicKey = @"Aq4Qk0tQwU3zSfStH0ZTMKzC6ZfF3PBEqoGLWwJMYQVz";
        aliceUncompressedPublicKey = @"BK4Qk0tQwU3zSfStH0ZTMKzC6ZfF3PBEqoGLWwJMYQVzvncvr8fv+S6POJ96oLZn0l4YS/OpqB19Of+l1qxwO9Q=";
        alicePrivateKey = @"UhCeQEsqYcby7UfjKWLxGePlag/RUTIAwYypF0K3ERU=";
        bobPublicKey = @"ApneAMFPGDIS6bXR7qOca7huHsiQD5grT1X+CBB1UX82";
        bobPrivateKey = @"7mKV1nAZ6m61UMuGAeJ+eBYuAY4jfrnDEOf9K1aQixk=";

        testSignatureBytes = testSignatureBytes256;

        break;

      case 3:
        curve = GMEllipticCurveSecp384r1;
        curveName = @"GMEllipticCurveSecp384r1";

        alicePublicKey = @"Amp3NAD5A3Eyg2TB5xF6GnKKFN1mreXkEGBNW+BO9jCx/rPgho7cwgTqZOE950TDeg==";
        aliceUncompressedPublicKey = @"BGp3NAD5A3Eyg2TB5xF6GnKKFN1mreXkEGBNW+BO9jCx/rPgho7cwgTqZOE950TDemKqgjvi5Ozs6CHq/+1VLBm9lt+XKRfeeUJpoSxQmINYv1yFcBmWHPeNU2b2dGW2IA==";
        alicePrivateKey = @"238XF1UdIU+UATgDvhlhYmTZKTrdtCXEkfSGscowTCHNjRWY7QPOJxW1CzpxJcqM";
        bobPublicKey = @"AnpyZJlvppMp9JazUxONY83RIsn+sv/XqWPCcfRb1XJYYoUYGhU/udPhvwjJvkDnLA==";
        bobPrivateKey = @"42ly4+r5t9cmUHxN6mK0cM2IlsNZePumSO/1G4W8UOYsnExiUoIAM33gkPBZGXcJ";

        testSignatureBytes = testSignatureBytes384;

        break;
    }

    NSLog(@"Testing: %@", curveName);

    // Generate a key pair
    NSLog(@"  Generate Key Pair");

    crypto = [GMEllipticCurveCrypto generateKeyPairForCurve:curve];
    NSLog(@"    Public Key:  %@", crypto.publicKeyBase64);
    NSLog(@"    Private Key: %@", crypto.privateKeyBase64);



    NSLog(@"  Test ECDSA signing and verification with generated keys");

    // We just use an array of "helloworld" repeated to be the length required for testing
    messageHash = [NSData dataWithBytes:bytes length:crypto.bits / 8];

    // Calculate the signature
    signature = [crypto signatureForHash:messageHash];
    NSLog(@"    Signature: %@", signature);

    // Validate the signature
    valid = [crypto verifySignature:signature forHash:messageHash];
    NSLog(@"    Verified: %@", valid ? @"YES": @"NO");
    NSCAssert(valid, @"signatureForHash: or verifySignature:forHash: failed; Signature did not validate");



    NSLog(@"  Test ECC decompressing public keys");

    // Test with Alice's keys
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePublicKey];
    NSCAssert(crypto.compressedPublicKey, @"compressed key was not identified as compressed");
    NSLog(@"    Compressed: %@", crypto.publicKeyBase64);
    crypto.compressedPublicKey = NO;
    NSLog(@"    Uncompressed: %@", crypto.publicKeyBase64);
    NSCAssert([crypto.publicKeyBase64 isEqual:aliceUncompressedPublicKey], @"compressed key was not correctly decompressed");



    NSLog(@"  Test ECC compressing public keys");

    // Test with Alice's keys
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:aliceUncompressedPublicKey];
    NSCAssert(!crypto.compressedPublicKey, @"decompressed key was not identified as decompressed");
    NSLog(@"    Decompressed: %@", crypto.publicKeyBase64);
    crypto.compressedPublicKey = YES;
    NSLog(@"    Compressed: %@", crypto.publicKeyBase64);
    NSCAssert([crypto.publicKeyBase64 isEqual:alicePublicKey], @"uncompressed key was not correctly compressed");



    NSLog(@"  Test ECDSA signature and verification for known keys");

    // Test with Alice's keys
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePrivateKey];
    signature = [crypto signatureForHash:messageHash];
    NSLog(@"    Signature: %@", signature);

    // Validate the signature
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePublicKey];
    valid = [crypto verifySignature:signature forHash:messageHash];
    NSLog(@"    Verified: %@", valid ? @"YES": @"NO");
    NSCAssert(valid, @"signatureForHash: or verifySignature:forHash: failed; Signature did not validate");



    NSLog(@"  Test ECDSA verification for known keys and signature");

    // A correct signature
    NSData *correctSignature = [NSData dataWithBytes:testSignatureBytes length:2 * crypto.bits / 8];

    // Validate the signature
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePublicKey];
    valid = [crypto verifySignature:correctSignature forHash:messageHash];
    NSLog(@"    Verified: %@", valid ? @"YES": @"NO");
    NSCAssert(valid, @"verifySignature:forHash: failed; Signature did not validate");



    NSLog(@"  Test ECDSA DER signature and verification for known keys");

    // Test with Alice's keys
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePrivateKey];
    signature = [crypto encodedSignatureForHash:messageHash];
    NSLog(@"    Encoded Signature: %@", signature);

    // Validate the signature
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePublicKey];
    valid = [crypto verifyEncodedSignature:signature forHash:messageHash];
    NSLog(@"    Verified: %@", valid ? @"YES": @"NO");
    NSCAssert(valid, @"signatureForHash: or verifySignature:forHash: failed; Signature did not validate");



    NSLog(@"  Test ECDSA DER verification for known keys and signature");

    // A correct signature
    NSData *encodedCorrectSignature = derEncodeSignature([NSData dataWithBytes:testSignatureBytes length:2 * crypto.bits / 8]);

    // Validate the signature
    crypto = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePublicKey];
    valid = [crypto verifyEncodedSignature:encodedCorrectSignature forHash:messageHash];
    NSLog(@"    Verified: %@", valid ? @"YES": @"NO");
    NSCAssert(valid, @"verifySignature:forHash: failed; Signature did not validate");



    NSLog(@"  Test ECDH shared secret");

    // Alice's shared secret
    GMEllipticCurveCrypto *alice = [GMEllipticCurveCrypto cryptoForKeyBase64:alicePrivateKey];
    NSData *aliceSharedSecret = [alice sharedSecretForPublicKeyBase64:bobPublicKey];
    NSLog(@"    Shared Secret Alice: %@", aliceSharedSecret);

    // Bob's shared secret
    GMEllipticCurveCrypto *bob = [GMEllipticCurveCrypto cryptoForKeyBase64:bobPrivateKey];
    NSData *bobSharedSecret = [bob sharedSecretForPublicKeyBase64:alicePublicKey];
    NSLog(@"    Shared Secret Bob:   %@", bobSharedSecret);

    // Compare secrets
    NSLog(@"    Shared secrets equal? %@", [aliceSharedSecret isEqualToData:bobSharedSecret] ? @"YES": @"NO");
    NSCAssert([aliceSharedSecret isEqualToData:bobSharedSecret], @"sharedSecretForPublicKey: failed; Alice's secret not equal to Bob's secret");



    NSLog(@"  Test ECDSA signature and verification with hash category");

    NSData *message = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];

    // Set up a crypto using Alice's keys
    crypto = [GMEllipticCurveCrypto cryptoForCurve:curve];
    crypto.publicKeyBase64 = alicePublicKey;
    crypto.privateKeyBase64 = alicePrivateKey;

    // Try out the functions
    if (crypto.bits <= 256) {
      signature = [crypto hashSHA256AndSignData:message];
      valid = [crypto hashSHA256AndVerifySignature:signature forData:message];
      NSLog(@"    Verified: %@", valid ? @"YES": @"NO");
      NSCAssert(valid, @"hashSHA256AndSignData: or hashSHA256AndVerifySignature:forData: failed; Signature did not validate");

    } else {
      signature = [crypto hashSHA384AndSignData:message];
      valid = [crypto hashSHA384AndVerifySignature:signature forData:message];
      NSLog(@"    Verified: %@", valid ? @"YES": @"NO");
      NSCAssert(valid, @"hashSHA384AndSignData: or hashSHA384AndVerifySignature:forData: failed; Signature did not validate");
    }

  }

  // Test passing in a key of the wrong length
  GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto cryptoForCurve:GMEllipticCurveSecp256r1];

  @try {
      crypto.publicKeyBase64 = @"Aua4DjC1U8HFSHNAsXt5FgQ=";
      NSCAssert(YES, @"Invalid public key length did not throw an exception");
  } @catch (NSException *exception) {
      NSLog(@"  Invalid public key ignored");
  }

  @try {
      crypto.privateKeyBase64 = @"L2zVnuI3hVKXg0AvAFcjEA==";
      NSCAssert(YES, @"Invalid private key length did not throw an exception");
  } @catch (NSException *exception) {
      NSLog(@"  Invalid private key ignored");
  }

  [pool drain];

  return 0;
}
