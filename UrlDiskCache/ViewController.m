//
//  ViewController.m
//  UrlDiskCache
//
//  Created by hpking　 on 15/10/7.
//  Copyright © 2015年 hpking　. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UIWebView *webView;
}

@end

@implementation ViewController

// 定义尺寸
#define LCDSIZE [[UIScreen mainScreen] bounds]

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSURLCache  sharedURLCache ]removeAllCachedResponses];
    
//    NSString * baseUrl = @"http://widgets.ign.com/tools/maps/interactivemap/the-elder-scrolls-5-skyrim/skyrim.html?title=false&fullscreen=false&slidingview=true&search=false&filters=false&editable=false&moderator=false&filter=false&externalLink=false&width=100%%&height=100%%&unloadInvisibleTiles=true&retina=false&disableClusteringAtZoom=4&clusterRadius=100";
    
    NSString* originalPath = @"http://7xix44.com1.z0.glb.clouddn.com/c2fdfc039245d688dd5e45f3a7c27d1ed21b240c.jpg?imageMogr/v2/thumbnail/80x80";
    if([originalPath rangeOfString:@".jpg?"].location != NSNotFound)
    {
        NSLog(@"not exit .jpg?");
    }
    else
    {
        NSLog(@"exit .jpg?");
    }
    
    NSString* baseUrl =@"http://jonoon.iuact.com/app/";//newslist.html
    
    NSString *encodedString = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 创建webview窗口
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, LCDSIZE.size.width, LCDSIZE.size.height)];
    webView.scalesPageToFit = YES;
    
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
