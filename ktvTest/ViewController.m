//
//  ViewController.m
//  ktvTest
//
//  Created by Carl Ji on 2018/6/1.
//  Copyright © 2018年 Carl Ji. All rights reserved.
//

#import "ViewController.h"
#import "DKKVideoCourseAudioPlayer.h"

@interface ViewController () <DKKVideoCourseAudioPlayerDelegate>

@property (nonatomic, strong) DKKVideoCourseAudioPlayer *player;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)play:(id)sender {
    
    
    DKKVideoCourseAudioModel *audio = [DKKVideoCourseAudioModel new];
//    audio.url = @"http://audio.xmcdn.com/group31/M07/32/4A/wKgJX1mCul7T69biALK310nYu_I069.m4a";
    audio.url = @"http://audio.xmcdn.com/group30/M0A/60/70/wKgJXlmCujqBAezhAc87fnhPZXg357.mp3";
    audio.duration = 3794;
    self.player = [DKKVideoCourseAudioPlayer prepareWithVideoCourseAudio:audio Delegate:self];
    
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(logCurrentTime) userInfo:nil repeats:true];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    self.timer = timer;
//    [timer fire];
}

//- (void)logCurrentTime {
//    NSLog(@"timer:%.2f", [self.player currentTime]);
//}


- (IBAction)pauseAction:(id)sender {
    [self.player pause];
}

- (IBAction)resumeAction:(id)sender {
    [self.player resume];
}

- (IBAction)speedAction1X:(id)sender {
    [self.player changeSpeed:1.0f];
}

- (IBAction)speedAction2X:(id)sender {
    [self.player changeSpeed:2.0f];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)slider:(UISlider *)sender {
    NSLog(@"sender %@", @(sender.value));
    [self.player seekToProgress:sender.value];
}


- (void)playerStateChanged:(DKKVideoCourseAudioPlayerState)state {
    NSLog(@"XXXXXXXXXX   %@", @(state));
    
    if (state == DKKVideoCourseAudioPlayerStatePrepareDone) {
//        [self.player seekToProgress:0.5];
//        [self.player changeSpeed:3];
    }
}

- (void)playerTimerInvoked:(CGFloat)currentTime Progress:(CGFloat)progress{
    NSLog(@"Timer invoked:%.2f", currentTime);
    NSLog(@"Timer Progress:%.2f", progress);
//    self.slider.value = progress;
}


@end
