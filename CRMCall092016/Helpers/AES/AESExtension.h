//
//  AESExtension.h
//  MobileMessenger
//
//  Created by Nhan Nguyen Trong on 2/6/12.
//  Copyright (c) 2012 Hanbiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface AESExtension : NSObject
- (NSString*) aesEncryptString:(NSString*)textString;
- (NSString*) aesDecryptString:(NSString*)textString;
- (NSData *)AES128EncryptWithKey:(NSString *)key theData:(NSData *)Data;
- (NSData *)AES128DecryptWithKey:(NSString *)key theData:(NSData *)Data;
- (NSString *)hexEncode:(NSData *)data;
- (NSData*) decodeHexString : (NSString *)hexString;
@end
