//
//  AESExtension.m
//  MobileMessenger
//
//  Created by Nhan Nguyen Trong on 2/6/12.
//  Copyright (c) 2012 Hanbiro. All rights reserved.
//

#import "AESExtension.h"

#define HANBIRO_AES_PASSWORD @"KesoiaZa$Honbiry"

@implementation AESExtension
- (NSString*) aesEncryptString:(NSString*)textString{
    @autoreleasepool {
        NSData *d = [textString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *t = [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding];
        
        NSMutableString *s = [[NSMutableString alloc] initWithString:textString];
        if(t.length %16 != 0 ){
            NSInteger nMod = (16 - (t.length % 16));
            while(nMod>0){
                [s appendString:@"\0"];
                nMod = nMod - 1;
            }
        }
        
        t = nil;
        
        NSString *key = HANBIRO_AES_PASSWORD;
        
        NSData *data = [[NSData alloc] initWithData:[s dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *ret = [self AES128EncryptWithKey:key theData:data];
        
        NSString *result = [self hexEncode:ret];
        if(result.length % 16 == 0) {
            result = [result stringByReplacingOccurrencesOfString:@"BFF0100AAB74EB64B9BBF880FA38EA96"
                                                       withString:@""];
        }

        
        
        data = nil;
        
        return result;
    }
}

- (NSString*) aesDecryptString:(NSString*)textString{
    @autoreleasepool {
        
        
        NSString *key = HANBIRO_AES_PASSWORD;
        if(textString.length % 16 == 0) {
            textString = [NSString stringWithFormat:@"%@BFF0100AAB74EB64B9BBF880FA38EA96",textString];
        }
        NSData *ret = [self decodeHexString:textString];
        NSData *ret2 = [self AES128DecryptWithKey:key theData:ret];
        //NSString* newStr = [NSString stringWithUTF8String:[ret2 bytes]];
        NSString *st2 = [[NSString alloc] initWithData:ret2 encoding:NSUTF8StringEncoding];
        return st2;
    }
}

- (NSData *)AES128EncryptWithKey:(NSString *)key theData:(NSData *)Data {
    
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused) // oorspronkelijk 256
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [Data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    //    // Initialization vector; dummy in this case 0's.
    //    uint8_t iv[kCCBlockSizeAES128];
    //    memset((void *) iv, 0x20, (size_t) sizeof(iv));
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode + kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCKeySizeAES128, // oorspronkelijk 256
                                          nil, /* initialization vector (optional) */
                                          [Data bytes],
                                          dataLength, /* input */
                                          buffer,
                                          bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES128DecryptWithKey:(NSString *)key theData:(NSData *)Data
{
    
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused) // oorspronkelijk 256
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [Data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode +kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128, // oorspronkelijk 256
                                          NULL /* initialization vector (optional) */,
                                          [Data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

-(NSString *)hexEncode:(NSData *)data{
    static const char hexdigits[] = "0123456789ABCDEF";
	const size_t numBytes = [data length];
	const unsigned char* bytes = [data bytes];
	char *strbuf = (char *)malloc(numBytes * 2 + 1);
	char *hex = strbuf;
	NSString *hexBytes = nil;
    
	for (int i = 0; i<numBytes; ++i) {
		const unsigned char c = *bytes++;
		*hex++ = hexdigits[(c >> 4) & 0xF];
		*hex++ = hexdigits[(c ) & 0xF];
	}
	*hex = 0;
	hexBytes = [NSString stringWithUTF8String:strbuf];
	free(strbuf);
	return hexBytes;
}

- (NSData*) decodeHexString : (NSString *)hexString
{
    const char * bytes = [hexString cStringUsingEncoding: NSUTF8StringEncoding];
    NSUInteger length = strlen(bytes);
    unsigned char * r = (unsigned char *) malloc(length / 2 + 1);
    unsigned char * index = r;
    
    while ((*bytes) && (*(bytes +1))) {
        char encoder[3] = {'\0','\0','\0'};
        encoder[0] = *bytes;
        encoder[1] = *(bytes +1);
        *index = (char) strtol(encoder,NULL,16);
        index++;
        bytes+=2;
    }
    *index = '\0';
    
    NSData * result = [NSData dataWithBytes: r length: length / 2];
    free(r);
    
    return result;
}

@end
