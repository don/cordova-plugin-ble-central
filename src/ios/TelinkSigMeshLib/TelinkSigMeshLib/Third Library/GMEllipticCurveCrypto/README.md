Elliptic Curve Crypto
=====================

An Objective-C library for Elliptic Curve Digital Signing Algorithm (ECDSA) and for Elliptic Curve Diffie-Hellman (ECDH).

ECDSA allows signatures to be generated using a private key and validated using a public key.

ECDH allows two identities to use their own private keys and each other's public key to generate a shared secret, which can then be used for encryption.

This library is largely based on the easy-ecc library (https://github.com/kmackay/easy-ecc).

# Features

* Supports: secp128r1, secp192r1, secp256r1, secp384r1
* Automatically detects curve based on private or public key
* Supports keys as raw bytes or as base64 encoded strings
* BSD 2-clause license

# API

### Generate a new ECC key pair

```objective-c
GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto generateKeyPairForCurve:
                                                         GMEllipticCurveSecp192r1];
NSLog(@"Public Key: %@", crypto.publicKeyBase64);
NSLog(@"Private Key: %@", crypto.privateKeyBase64);
```

### Using keys

Keys can be accessed and set interchangably in either raw bytes or as base64 encoded strings.

```objective-c
crypto.publicKeyBase64 = @"AtF8hCxh9h1zlExuOZutuw+tRzmk3zVdfA==";
NSLog(@"Public Key: base64=%@, rawBinary=%@", crypto.publicKeyBase64, crypto.publicKey);

char bytes[] = { 2, 209, 124, 132, 44, 97, 246, 29, 115, 148, 76, 110, 57, 155, 173, 
                 187, 15, 173, 71, 57, 164, 223, 53, 93, 124 };
crypto.publicKey = [NSData dataWithBytes:bytes length:25];
NSLog(@"Public Key: base64=%@, rawBinary=%@", crypto.publicKeyBase64, crypto.publicKey);
```


### Generate a signature for a message

The signing operations require a message the same length as the curve; so generally, a hash algorithm is used to fix the original message's length.

Signatures using ECDSA will be twice the curve size. So, the 192 bit curve will produce a signature that is 48 bytes (384 bits) long.

Also note that the signature is intentionally different each time because ECDSA uses a random _k_ value.

```objective-c
// The first 24 bytes of the SHA-256 hash for "Hack the Planet!"
char bytes[] = { 56, 164, 34, 250, 121, 21, 2, 18, 65, 4, 161, 90, 126, 145, 111, 204, 
                 151, 65, 181, 4, 231, 177, 117, 154 };
NSData *messageHash = [NSData dataWithBytes:bytes length:24];
        
GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto cryptoForCurve:
                                                GMEllipticCurveSecp192r1];
crypto.privateKeyBase64 = @"ENxb+5pCLAGT88vGmE6XLQRH1e8i/0rz";
NSData *signature = [crypto signatureForHash:messageHash];
NSLog(@"Signature: %@", signature);
```

### Verify a signature

```objective-c
// messageHash and signature from above

crypto = [GMEllipticCurveCrypto cryptoForCurve:GMEllipticCurveSecp192r1];
crypto.publicKeyBase64 = @"AtF8hCxh9h1zlExuOZutuw+tRzmk3zVdfA==";;
BOOL valid = [crypto verifySignature:signature forHash:messageHash];
NSLog(@"Valid Signature: %@", (valid ? @"YES": @"NO"));
```

### Shared secret

Shared secrets using ECDH are the same length as the curve. So, the 192 bit curve will produce a shared secret that is 24 bytes (192 bits) long.

```objective-c
NSString *alicePublicKey = @"A9N+XWIjLCYAwa8Hb7T6Rohttqo91CF8HQ==";
NSString *alicePrivateKey = @"frs4puAKipcbevvwJb7l77xACgB/FyBv";

NSString *bobPublicKey = @"A35aoteno4wnAdJgV8AXKKl1AfPVRrSZQA==";
NSString *bobPrivateKey = @"LP83qv81MsXVyPOFV7V5jKVOoU4DKPUS";


// Alice performs...
GMEllipticCurveCrypto *alice = [GMEllipticCurveCrypto cryptoForCurve:
                                               GMEllipticCurveSecp192r1];
alice.privateKeyBase64 = alicePrivateKey;
NSData *aliceSharedSecret = [alice sharedSecretForPublicKeyBase64:bobPublicKey];
NSLog(@"Shared Secret Alice: %@", aliceSharedSecret);

// Bob performs...
GMEllipticCurveCrypto *bob = [GMEllipticCurveCrypto cryptoForCurve:
                                             GMEllipticCurveSecp192r1];
bob.privateKeyBase64 = bobPrivateKey;
NSData *bobSharedSecret = [bob sharedSecretForPublicKeyBase64:alicePublicKey];
NSLog(@"Shared Secret Bob: %@", bobSharedSecret);

// And now both parties have the same secret!
NSLog(@"Shared secrets equal? %d", [aliceSharedSecret isEqualToData:bobSharedSecret]);

```

# Convenience functions

### Automatically detects curve and sets up the private or public key

```objective-c
+ (GMEllipticCurveCrypto*)cryptoForKey: (NSData*)privateOrPublicKey;
+ (GMEllipticCurveCrypto*)cryptoForKeyBase64: (NSString*)privateOrPublicKey;
```


### Automatically hash and compute the signature for a message

Include the `GMEllipticCurveCrypto+hash.h` category to hash data automatically before signing and verifying. The hash algorithm used must be at least the length of the curve. The hash will have the right-most bytes truncated, if necessary.

```objective-c
- (NSData*)hashSHA256AndSignData: (NSData*)data;
- (BOOL)hashSHA256AndVerifySignature: (NSData*)signature forData: (NSData*)data;

- (NSData*)hashSHA384AndSignData: (NSData*)data;
- (BOOL)hashSHA384AndVerifySignature: (NSData*)signature forData: (NSData*)data;
```

Why?
----

Kenneth MacKay's easy-ecc is an awesome, simple-to-use implementation of essential Elliptic Curve Cryptographic functions, however, the curve used is specified as a compile-time constant, so it cannot be changed at runtime.

This library allows any and as many different curves to be used at once.


Donations?
----------

Sure! :-)

_Bitcoin_  - `1LNdGsYtZXWeiKjGba7T997qvzrWqLXLma` 

