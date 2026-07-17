#import <UIKit/UIKit.h>

@interface AWEVideoModel : NSObject
@property (nonatomic, copy) NSString *shareURL; 
@end

@interface AWEVideoPlayerController : UIViewController
- (AWEVideoModel *)currentVideoModel;
@property (nonatomic, strong) UIButton *customDownloadButton;
@end

%hook AWEVideoPlayerController

- (void)viewDidLoad {
    %orig;
    self.customDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.customDownloadButton.frame = CGRectMake(screenWidth - 60, 60, 40, 40);
    self.customDownloadButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.customDownloadButton.layer.cornerRadius = 20;
    self.customDownloadButton.clipsToBounds = YES;
    [self.customDownloadButton setTitle:@"📥" forState:UIControlStateNormal];
    self.customDownloadButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.customDownloadButton addTarget:self action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.customDownloadButton];
    [self.view bringSubviewToFront:self.customDownloadButton];
}

%new
- (void)downloadButtonPressed {
    AWEVideoModel *currentVideo = [self currentVideoModel];
    if (currentVideo && currentVideo.shareURL) {
        [self downloadViaTikWM:currentVideo.shareURL];
    }
}

%new
- (void)downloadViaTikWM:(NSString *)tiktokURL {
    NSString *apiUrl = @"https://www.tikwm.com/api/";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiUrl]];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"url=%@&hd=1", [tiktokURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json[@"code"] intValue] == 0) {
                NSString *downloadURLString = json[@"data"][@"play"] ?: json[@"data"][@"wmplay"];
                if (downloadURLString) {
                    if ([downloadURLString hasPrefix:@"/"]) {
                        downloadURLString = [NSString stringWithFormat:@"https://www.tikwm.com%@", downloadURLString];
                    }
                    [self saveVideoToPhotos:[NSURL URLWithString:downloadURLString]];
                }
            }
        }
    }];
    [task resume];
}

%new
- (void)saveVideoToPhotos:(NSURL *)videoURL {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        if (videoData) {
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tikwm_video.mp4"];
            [videoData writeToFile:tempPath atomically:YES];
            UISaveVideoAtPathToSavedPhotosAlbum(tempPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    });
}

%new
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    // تم الحفظ بنجاح
}

%end
