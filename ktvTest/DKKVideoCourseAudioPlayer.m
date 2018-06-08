//
//  DKKVideoCourseAudioPlayer.m
//  ktvTest
//
//  Created by Carl Ji on 2018/6/1.
//  Copyright © 2018年 Carl Ji. All rights reserved.
//

#import "DKKVideoCourseAudioPlayer.h"

@interface DKKVideoCourseAudioPlayer ()
//pause Flag
@property (nonatomic, assign) BOOL isUserPauseAction;
@property (nonatomic, assign) BOOL isUserStopAction;

@property (nonatomic, assign) BOOL hasPreparedDone;

@property (nonatomic, assign) BOOL isCaching;

@property (nonatomic, assign) BOOL enableTimer;

@property (nonatomic, strong) DKKVideoCourseAudioModel *currentItem;
@property (nonatomic, weak) id <DKKVideoCourseAudioPlayerDelegate> delegate;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, assign) CGFloat currentPlayRate;
@property (nonatomic, assign) CGFloat playerChangingRate;

@property (nonatomic, strong) id timeObserverToken;
@end

@implementation DKKVideoCourseAudioPlayer

- (instancetype)initWithModel:(DKKVideoCourseAudioModel *)item Delegate:(id)delegate{
    if (self = [super init]) {
        if (item.url && item.url.length > 0) {
            _player = [AVPlayer playerWithURL:[NSURL URLWithString:item.url]];
            [_player play];
            _currentPlayRate = 1.0;
            
            _currentItem = item;
            _delegate = delegate;
            
            if ([_delegate respondsToSelector:@selector(playerTimerInvoked:Progress:)]) {
                _enableTimer = true;
            }
            [self addObserver];
            
            self.isCaching = true;
        }
    }
    return self;
}

- (void)setIsCaching:(BOOL)isCaching {
    if (isCaching == false && _isCaching == true) {
        if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
            [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStateEndLoading];
        }
    }else if (isCaching == true && _isCaching == false) {
        if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
            [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStateBeginLoading];
        }
    }
    _isCaching = isCaching;
}

+ (instancetype)prepareWithVideoCourseAudio:(DKKVideoCourseAudioModel *)audioModel Delegate:(id <DKKVideoCourseAudioPlayerDelegate>)delegate{
    DKKVideoCourseAudioPlayer *player = [[DKKVideoCourseAudioPlayer alloc] initWithModel:audioModel Delegate:delegate];
    return player;
}

- (void)addObserver {
    if (self.player) {
        [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        if (@available(iOS 10.0, *)) {
            [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
    
}

- (void)removeObserver {
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.player removeObserver:self forKeyPath:@"rate"];
        if (@available(ios 10.0, *)) {
            [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
        }
    }
}

- (void)pause {
    self.isUserPauseAction = true;
    [self.player pause];
}


- (void)resume {
    [self.player setRate:_currentPlayRate];
}

- (void)stop {
    self.isUserStopAction = true;
    [self.player pause];
    self.player = nil;
}

- (void)changeSpeed:(CGFloat)speedRate {
    self.playerChangingRate = speedRate;
    [self.player setRate:speedRate];
}

- (void)seekToProgress:(CGFloat)progress {
    if (self.hasPreparedDone) {
//        [self.player seekToTime:CMTimeMakeWithSeconds(self.currentItem.duration * progress, NSEC_PER_SEC)];
        [self.player seekToTime:CMTimeMakeWithSeconds(self.currentItem.duration * progress, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            if (finished) {

            }
        }];
    }
}

//- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
//    if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
//        [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStateBeginLoading];
//    }
//    [super seekToTime:time completionHandler:^(BOOL finish){
//        if (finish) {
//            if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
//                [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStateSeekDone];
//            }
//        }
//
//        completionHandler(finish);
//    }];
//}

- (void)itemDidFinished {
    if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
        [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStateFinish];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
//        NSLog(@"Player Status Changed:%@", @(self.player.status));
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            self.hasPreparedDone = true;
            if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
                [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStatePrepareDone];
            }
            if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
                [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStatePlay];
            }
        } else if (self.player.status == AVPlayerStatusFailed) {
            if ([self.delegate respondsToSelector:@selector(playerError:)]) {
                [self.delegate playerError:self.player.error];
            }
        }
    }
    if (@available(iOS 10.0, *)) {
        if ([keyPath isEqualToString:@"timeControlStatus"]) {
            NSLog(@"TimeControlStatus Changes: %@", @(self.player.timeControlStatus));
            
            if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
                [self removePeriodicTimeObserver];
                self.isCaching = false;
                if (_isUserStopAction) { //用户停止
                    if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
                        [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStateStop];
                    }
                    _isUserStopAction = false;
                    return;
                }
                
                if (_isUserPauseAction) { //用户暂停
                    if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
                        [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStatePause];
                    }
                    _isUserPauseAction = false;
                    return;
                }
            } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate) {
                //需要检查原因
                [self removePeriodicTimeObserver];
                if ([self.player.reasonForWaitingToPlay isEqualToString:AVPlayerWaitingToMinimizeStallsReason]) {
                    self.isCaching = true;
                }else if ([self.player.reasonForWaitingToPlay isEqualToString:AVPlayerWaitingWithNoItemToPlayReason]) {
                    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{@"NSLocalizedDescriptionKey":@"音频资源加载失败,请重试"}];
                    if ([self.delegate respondsToSelector:@selector(playerError:)]) {
                        [self.delegate playerError:error];
                    }
                }else if ([self.player.reasonForWaitingToPlay isEqualToString:AVPlayerWaitingWhileEvaluatingBufferingRateReason]) {
                    self.isCaching = true;
                }
            } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                //播放
                [self addPeriodicTimeObserver];
                self.isCaching = false;
            }
        }
    } else {
        if ([keyPath isEqualToString:@"rate"]) {
//            NSLog(@"Player Rate Changed:%@", @(self.player.rate));
            
            if (_playerChangingRate > 0 && self.player.rate == _playerChangingRate) {
                _currentPlayRate = self.player.rate;
                //change rate success;
                _playerChangingRate = -1;
                [self addPeriodicTimeObserver];
                return;
            }
            
            if (self.player.rate == 0 ) {
                [self removePeriodicTimeObserver];
                if (_isUserStopAction) { //用户停止
                    if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
                        [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStateStop];
                    }
                    self.isCaching = false;
                    _isUserStopAction = false;
                    return;
                }
                
                if (_isUserPauseAction) { //用户暂停
                    if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
                        [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStatePause];
                    }
                    self.isCaching = false;
                    _isUserPauseAction = false;
                    return;
                }
                
                self.isCaching = true;
                
            }else if(self.player.rate > 0){
                [self addPeriodicTimeObserver];
                self.isCaching = false;
                if (self.hasPreparedDone) {
                    if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
                        [self.delegate playerStateChanged:DKKVideoCourseAudioPlayerStatePlay];
                    }
                }
            }
        }
    }
    
    
}

- (CGFloat)currentTime {
    return self.player.currentTime.value / self.player.currentTime.timescale;
}

- (void)addPeriodicTimeObserver {
    if (_enableTimer) {
        CGFloat rate = _currentPlayRate;
        if (rate == 0) {
            rate = 1;
        }
        CMTime interval = CMTimeMakeWithSeconds(1/rate, NSEC_PER_SEC);
        // Queue on which to invoke the callback
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        __weak typeof(self) weakSelf = self;
        self.timeObserverToken =
        [self.player addPeriodicTimeObserverForInterval:interval
                                                  queue:mainQueue
                                             usingBlock:^(CMTime time) {
                                                 if ([weakSelf.delegate respondsToSelector:@selector(playerTimerInvoked:Progress:)]) {
                                                     [weakSelf.delegate playerTimerInvoked:time.value/time.timescale Progress:(time.value/time.timescale) * 1.0/self.currentItem.duration];
                                                 }
                                             }];
    }
}

- (void)removePeriodicTimeObserver {
    if (_enableTimer) {
        if (self.timeObserverToken) {
            [self.player removeTimeObserver:self.timeObserverToken];
            self.timeObserverToken = nil;
        }
    }
}

@end
