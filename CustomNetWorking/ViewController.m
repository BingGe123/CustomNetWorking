//
//  ViewController.m
//  CustomNetWorking
//
//  Created by 李雪阳 on 2020/6/26.
//  Copyright © 2020 XueYangLee. All rights reserved.
//

#import "ViewController.h"
#import "CustomNetWork.h"
#import <YYModel.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *NetStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *judgeNetStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *normalDownLoadProgress;
@property (weak, nonatomic) IBOutlet UILabel *normalDownloadLabel;
@property (nonatomic,copy) NSString *normalDownloadPath;

@property (weak, nonatomic) IBOutlet UIProgressView *resumeDownloadProgress;
@property (weak, nonatomic) IBOutlet UILabel *resumeDownloadLabel;
@property (nonatomic,copy) NSString *resumeDownloadPath;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [CustomNetWork netWorkStatusWithBlock:^(CustomNetWorkNetStatus netWorkStatus) {
        switch (netWorkStatus) {
            case NetWorkStatusUnknow:
                self.NetStatusLabel.text = @"未知网络";
                break;
            case NetWorkStatusNotReachable:
                self.NetStatusLabel.text = @"无网络";
                break;
            case NetWorkStatusReachableViaWWAN:
                self.NetStatusLabel.text = @"手机网络";
                break;
            case NetWorkStatusReachableViaWiFi:
                self.NetStatusLabel.text = @"WiFi网络";
                break;
            
            default:
                break;
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.judgeNetStatusLabel.text = [NSString stringWithFormat:@"是否有网络-%@/手机网络-%@/WiFi网络-%@",([CustomNetWork isNetwork]?@"YES":@"NO"),([CustomNetWork isWWANNetwork]?@"YES":@"NO"),([CustomNetWork isWiFiNetwork]?@"YES":@"NO")];
    });
    
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"当前缓存大小：%@",[CustomNetWork cacheSize]];
    
}


- (IBAction)btnClick:(UIButton *)sender {
    
    
    if (sender.tag == 10) {//无缓存请求
        [CustomNetWork GET:@"http://apis.juhe.cn/simpleWeather/query" parameters:@{@"city":@"北京"} completion:^(CustomNetWorkResponseObject * _Nullable respObj) {
            DLog(@"%@*****GET请求结果*",respObj.result)
        }];
    }else if (sender.tag == 11) {//缓存请求  分开返回
        [CustomNetWork requestWithMethod:RequestMethodGET URL:@"http://apis.juhe.cn/simpleWeather/query" parameters:@{@"city":@"上海"} cachePolicy:CachePolicyOnlyCacheOnceRequest cacheValidTime:10 cacheComp:^(CustomNetWorkResponseObject * _Nullable respObj) {
            DLog(@"%@*****缓存结果*",respObj.result)
        } respComp:^(CustomNetWorkResponseObject * _Nullable respObj) {
            DLog(@"%@*****请求结果*",respObj.result)
        }];
    }else if (sender.tag == 12) {//缓存请求  集合返回
        [CustomNetWork requestWithMethod:RequestMethodGET URL:@"http://apis.juhe.cn/simpleWeather/query" parameters:@{@"city":@"广州"} cachePolicy:CachePolicyOnlyCacheOnceRequest cacheValidTime:CacheValidTimeForever completion:^(CustomNetWorkResponseObject * _Nullable respObj) {
            DLog(@"%@*****数据结果（缓存）*",respObj.result)
        }];
    }else if (sender.tag == 13) {//缓存请求  集合返回
        [CustomNetWork GET:@"http://apis.juhe.cn/simpleWeather/query" parameters:@{@"city":@"深圳"} cachePolicy:CachePolicyOnlyCacheOnceRequest cacheValidTime:CacheValidTimeDay completion:^(CustomNetWorkResponseObject * _Nullable respObj) {
            DLog(@"%@*****GET数据结果（缓存）*",respObj.result)
        }];
    }
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"当前缓存大小：%@",[CustomNetWork cacheSize]];
}


- (IBAction)removeCache:(UIButton *)sender {
    [CustomNetWork removeAllCache];
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"当前缓存大小：%@",[CustomNetWorkCache cacheSize]];
}

//@"https://file.wchoosemall.com/platform/manager/pic/20190325/7448903938448587.jpg"  @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4"
- (IBAction)normalDownload:(UIButton *)sender {
    NSURLSessionDownloadTask *task=nil;
    if (!sender.selected) {
        task=[CustomNetWork downloadWithURL:@"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4" folderName:nil progress:^(NSProgress * _Nonnull progress, double progressRate) {
            self.normalDownLoadProgress.progress=progressRate;
            self.normalDownloadLabel.text=[NSString stringWithFormat:@"%.f%%",progressRate*100];
        } completion:^(BOOL success, NSString * _Nullable filePath, NSURLResponse * _Nullable response) {
            DLog(@"%@*****下载文件路径*",filePath);
            
            self.normalDownloadPath=filePath;
            
        }];
    }else{
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            DLog(@"续传的data = %@",resumeData)
        }];
        self.normalDownLoadProgress.progress=0;
        self.normalDownloadLabel.text=@"0%";
    }
    sender.selected = !sender.selected;
}


- (IBAction)resumeDownload:(UIButton *)sender {
    sender.selected = !sender.selected;
}



- (IBAction)removeNormalDownloadFile:(UIButton *)sender {
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:self.normalDownloadPath] error:nil];
}

- (IBAction)removeResumeDownloadFile:(UIButton *)sender {
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:self.resumeDownloadPath] error:nil];
}

@end
