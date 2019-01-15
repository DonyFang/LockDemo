//
//  ViewController.m
//  LockDemo
//
//  Created by 方冬冬 on 2019/1/15.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,assign) NSInteger total;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _total = 0;
    [self threadNotSafe3];
}
- (void)threadNotSafe {
    NSLock *lock = [NSLock new];
    for (NSInteger index = 0; index < 3; index++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [lock lock];//使用线程锁 保证线程安全
            _total += 1;
            NSLog(@"total: %ld", _total);
            _total -= 1;
            NSLog(@"total: %ld", _total);
            [lock unlock];
        });
    }
}
/*
 这个代码块可简称为“同步代码块”，obj就是锁对象，，锁对象就实现了对多线程的监控，保证同一时刻只有一个线程执行，当同步代码块执行完成后，锁对象就会释放对同步监视器的锁定。
         需要注意的是，虽然Object-C允许使用任何对象作为同步锁，但是考虑到同步锁存在的意义是组织多个线程对同一个共享资源的并发访问，因此同步锁只要一个就可以了。并且同步锁要监听所有线程的整个运行状态，考虑到同步锁的生命周期，通常推荐使用当前的线程所在的控制器作为同步锁。
 */
- (void)threadNotSafe2{
    for (NSInteger index = 0; index < 3; index++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @synchronized(self){//同步线程锁
                _total += 1;
                NSLog(@"total: %ld", _total);
                _total -= 1;
                NSLog(@"total: %ld", _total);
            };
        });
    }
}


/*
 dispatch_semaphore_t signal = dispatch_semaphore_create(1);
 dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 dispatch_semaphore_wait(signal, overTime);
 NSLog(@"需要线程同步的操作1 开始");
 sleep(2);
 NSLog(@"需要线程同步的操作1 结束");
 dispatch_semaphore_signal(signal);
 });

 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 sleep(1);
 dispatch_semaphore_wait(signal, overTime);
 NSLog(@"需要线程同步的操作2");
 dispatch_semaphore_signal(signal);
 });
 */
//信号量加锁
- (void)threadNotSafe3{
    dispatch_semaphore_t signal = dispatch_semaphore_create(1);
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    for (NSInteger index = 0; index < 3; index++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_wait(signal, overTime);
                _total += 1;
                NSLog(@"total: %ld", _total);
                _total -= 1;
                NSLog(@"total: %ld", _total);
            dispatch_semaphore_signal(signal);
        });
    }
}


@end
