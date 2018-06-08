//
//  DKKVideoCourseAudioPlayer.h
//  ktvTest
//
//  Created by Carl Ji on 2018/6/1.
//  Copyright © 2018年 Carl Ji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DKKVideoCourseAudioModel.h"


typedef NS_ENUM(NSInteger, DKKVideoCourseAudioPlayerState) {
    DKKVideoCourseAudioPlayerStateUnknown = 0, 
    DKKVideoCourseAudioPlayerStatePrepareDone = 1,  //finish
    DKKVideoCourseAudioPlayerStatePlay = 2,         //finish
    DKKVideoCourseAudioPlayerStatePause = 3,        //finish
    DKKVideoCourseAudioPlayerStateStop = 4,         //finish
    DKKVideoCourseAudioPlayerStateFinish = 5,       //finish
    DKKVideoCourseAudioPlayerStateBeginLoading = 6, //finish
    DKKVideoCourseAudioPlayerStateEndLoading = 7,   //finish
    DKKVideoCourseAudioPlayerStateSeekDone = 8,
};

@protocol DKKVideoCourseAudioPlayerDelegate <NSObject>
@required
- (void)playerStateChanged:(DKKVideoCourseAudioPlayerState)state;
- (void)playerError:(NSError *)error;
//- (void)playerChangeRate
@optional
- (void)playerTimerInvoked:(CGFloat)currentTime Progress:(CGFloat)progress;

@end

@interface DKKVideoCourseAudioPlayer : NSObject



+ (instancetype)prepareWithVideoCourseAudio:(DKKVideoCourseAudioModel *)audioModel Delegate:(id <DKKVideoCourseAudioPlayerDelegate>)delegate;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)changeSpeed:(CGFloat)speedRate;

// progress: 0~1
- (void)seekToProgress:(CGFloat)progress;
- (CGFloat)currentTime;
@end
