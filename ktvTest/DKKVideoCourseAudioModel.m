//
//  DKKVideoCourseAudioModel.m
//  ktvTest
//
//  Created by Carl Ji on 2018/6/1.
//  Copyright © 2018年 Carl Ji. All rights reserved.
//

#import "DKKVideoCourseAudioModel.h"
#import <KTVHTTPCache.h>

@interface DKKVideoCourseAudioModel ()

@property (nonatomic, copy) NSString *originUrl;

@end

@implementation DKKVideoCourseAudioModel

- (void)setUrl:(NSString *)url {
    _originUrl = url;
//    NSString * URLString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString * proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:url];
    _url = proxyURLString;
}


@end
