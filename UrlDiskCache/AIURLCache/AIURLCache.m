//
//  AIURLCache.m
//
//  Created by Alexey Ivlev on 8/2/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "AIURLCache.h"
#import "EGOCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface AIURLCache()

@property (nonatomic, strong) NSMutableArray *cacheURLAndMIMETypes;
@property (nonatomic, strong) NSDictionary *mimeTypes;
@property (nonatomic, strong) NSMutableDictionary *timeoutsForMIMEType;

@end

@implementation AIURLCache

- (void)cacheResourcesForURL:(NSString *)urlString withMIMEType:(MIMETypes)mimeType timeOutInterval:(NSTimeInterval)timeout
{
    // adds url along with mime type, and timeout into array for later use
    
    [self.cacheURLAndMIMETypes addObject:@{@"path":urlString, @"MIMEType":[NSNumber numberWithInt:mimeType]}];
    [self.timeoutsForMIMEType setObject:[NSNumber numberWithDouble:timeout] forKey:[self mimeNumberForPath:[NSNumber numberWithInt:mimeType]]];
}

- (BOOL)doesMIMETypeMatchRequestedType:(NSNumber *)type inURLString:(NSString *)pathString
{
    // only cache requested mime type for specified url
    MIMETypes mime = [type intValue];
    
    switch (mime)
    {
        case js:
            return ([self.mimeTypes[@"js"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case css:
            return ([self.mimeTypes[@"css"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case html:
            return ([self.mimeTypes[@"html"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case png:
            return ([self.mimeTypes[@"png"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case jpeg:
            return ([self.mimeTypes[@"jpeg"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case allImages:
            return (([self.mimeTypes[@"png"] isEqualToString:[self mimeTypeForPath:pathString]]) ||
                    [self.mimeTypes[@"jpeg"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case all:
            return YES;
            break;
    }
    
    return NO;
}

// 主要的检查是否应该缓存的函数 main check for both url and mime type specified by user
- (BOOL) shouldCacheRemoteFileForURL:(NSString *)urlString
{
    BOOL should = NO;
    for (NSDictionary *urlAndMIMEType in self.cacheURLAndMIMETypes)
    {
        if ([urlString hasPrefix:urlAndMIMEType[@"path"]])
        {
            should = [self doesMIMETypeMatchRequestedType: (NSNumber *)urlAndMIMEType[@"MIMEType"] inURLString:urlString];
            if (should) { return should; }
        }
    }
    
    return should;
}

- (NSString *)mimeTypeForPath:(NSString *)originalPath
{
    if ([originalPath hasSuffix:@".png"]) {
        return self.mimeTypes[@"png"];
    } else if ([originalPath hasSuffix:@".jpg"] || [originalPath hasSuffix:@".jpeg"]) {
        return self.mimeTypes[@"jpeg"];
    }
    else if([originalPath rangeOfString:@".png?"].location != NSNotFound)
    {
        return self.mimeTypes[@"png"];
    }
    else if([originalPath rangeOfString:@".jpg?"].location != NSNotFound)
    {
        return self.mimeTypes[@"jpeg"];
    }
    else if ([originalPath hasSuffix:@".css"]) {
        return self.mimeTypes[@"css"];
    }
    else if ([originalPath hasSuffix:@".ttf"]) {
        return self.mimeTypes[@"css"];
    }
    else if([originalPath hasSuffix:@".html"])
    {
        return self.mimeTypes[@"html"];
    }
    else if([originalPath rangeOfString:@".html?"].location != NSNotFound)
    {
        return self.mimeTypes[@"html"];
    }
    else if ([originalPath hasSuffix:@".js"]) {
        return self.mimeTypes[@"js"];
    }
    
    return nil;
}

- (NSString *)mimeNumberForPath:(NSNumber *)type
{
    MIMETypes mime = [type intValue];
    
    switch (mime)
    {
        case js:
            return self.mimeTypes[@"js"];
            break;
        case css:
            return self.mimeTypes[@"css"];
            break;
        case html:
            return self.mimeTypes[@"html"];
            break;
        case png:
            return self.mimeTypes[@"png"];
            break;
        case jpeg:
            return self.mimeTypes[@"jpeg"];
            break;
        case allImages:
            return self.mimeTypes[@"png"];
            break;
        case all:
            return self.mimeTypes[@"png"];
            break;
    }
    
    return nil;
}

- (NSString *)hashString:(NSString *)path
{
    const char *str = [path UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *hashValue = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return hashValue;
}

// 实现接口
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	NSString *pathString = request.URL.absoluteString;
    
    // 如果不是应该缓存的文件，则交给默认的缓存程序处理
	if (![self shouldCacheRemoteFileForURL:pathString])
    {
        NSLog(@"未缓存的url资源 %@", pathString);
		return [super cachedResponseForRequest:request];
	}
    
    // 检查缓存的内容
//    NSString* key = [self hashString:pathString];
//    NSLog(@"file %@ 的 key = %@", pathString, key);
    
    NSData *data = [[EGOCache globalCache] dataForKey:[self hashString:pathString]];
	if (data)
    {
        NSURLResponse *response =
		[[NSURLResponse alloc]
         initWithURL:request.URL
         MIMEType:[self mimeTypeForPath:pathString]
         expectedContentLength:data.length
         textEncodingName:nil];
        
//        NSLog(@"restore %@",pathString);
        
        // delete cached response from default cache to free up memory since we already stored it on disk
        [self removeCachedResponseForRequest:request];
        
		return [[NSCachedURLResponse alloc] initWithResponse:response data:data];
	}
    else
    {
        // 保存文件到disk   save file on disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSLog(@"saving");
            
            NSString *mimeType = [self mimeTypeForPath:pathString];
            if ([mimeType isEqualToString:@"image/jpeg"])
            {
                mimeType = @"image/png";
            }
            
            NSTimeInterval timeout = [((NSNumber *)self.timeoutsForMIMEType[mimeType]) doubleValue];
            NSData *data = [NSData dataWithContentsOfURL:request.URL];
            [[EGOCache globalCache] setData:data forKey:[self hashString:request.URL.absoluteString] withTimeoutInterval:timeout];
        });
        
        return [super cachedResponseForRequest:request];
    }
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    //put deletion on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [super removeCachedResponseForRequest:request];
    });
}

#pragma mark - 辅助函数

- (NSDictionary *)mimeTypes
{
    if (!_mimeTypes)
    {
        _mimeTypes = @{@"js":@"application/javascript", @"css":@"text/css", @"html":@"text/html", @"png":@"image/png", @"jpeg":@"image/jpeg"};
    }
    
    return _mimeTypes;
}

- (NSArray *)cacheURLAndMIMETypes
{
    if (!_cacheURLAndMIMETypes)
    {
        _cacheURLAndMIMETypes = [[NSMutableArray alloc] init];
    }
    
    return _cacheURLAndMIMETypes;
}

- (NSMutableDictionary *)timeoutsForMIMEType
{
    if (!_timeoutsForMIMEType)
    {
        _timeoutsForMIMEType = [[NSMutableDictionary alloc] init];
    }
    
    return _timeoutsForMIMEType;
}

@end
