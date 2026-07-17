#import <UIKit/UIKit.h>

// هوك على واجهة عرض الفيديوهات والستوري في تيك توك
%hook AWEAwemePlayInteractionViewController

- (void)viewDidLoad {
    %orig; // استدعاء الكود الأصلي للتطبيق أولاً

    // 1. إنشاء الزر وتحديد أبعاده ومكانه (يمكنك تعديل الإحداثيات لاحقاً)
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.frame = CGRectMake(20, 300, 50, 50); 
    
    // 2. تصميم شكل الزر (خلفية سوداء دائرية شفافة)
    downloadButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6]; 
    downloadButton.layer.cornerRadius = 25; 
    downloadButton.clipsToBounds = YES;
    
    // 3. إضافة أيقونة التنزيل للزر
    [downloadButton setTitle:@"📥" forState:UIControlStateNormal];
    downloadButton.titleLabel.font = [UIFont systemFontOfSize:22];
    
    // 4. ربط الزر بوظيفة (أكشن) عند الضغط عليه
    [downloadButton addTarget:self action:@selector(sendToDownloadSite:) forControlEvents:UIControlEventTouchUpInside];
    
    // 5. إضافة الزر فوق واجهة الفيديو
    [self.view addSubview:downloadButton];
}

// الوظيفة التي يتم استدعاؤها عند الضغط على الزر
%new
- (void)sendToDownloadSite:(UIButton *)sender {
    // الحصول على بيانات الفيديو الحالي
    id model = [self valueForKey:@"awemeModel"];
    
    // جلب قائمة الروابط المتاحة للفيديو
    NSArray *urlList = [model valueForKeyPath:@"video.playAddr.urlList"];
    NSString *videoURLString = nil;
    
    // محاولة البحث عن الرابط الأعلى جودة أولاً
    for (NSString *url in urlList) {
        if ([url containsString:@"hd=1"] || [url containsString:@"vr_hd"]) {
            videoURLString = url;
            break;
        }
    }
    
    // إذا لم يجد رابط HD محدد، يأخذ الرابط الأول كاحتياطي
    if (!videoURLString && urlList.count > 0) {
        videoURLString = urlList.firstObject;
    }
    
    if (videoURLString) {
        // الروابط الموجهة لموقع التحميل الخاص بك
        // (استبدل الرابط أدناه برابط موقعك الفعلي)
        NSString *myDownloadSite = @"https://your-download-site.com/api?url=";
        
        // ترميز رابط الفيديو لتفادي المشاكل أثناء الإرسال كمعامل (Query Parameter)
        NSString *encodedVideoURL = [videoURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        // دمج رابط الموقع مع رابط الفيديو
        NSString *finalURLString = [NSString stringWithFormat:@"%@%@", myDownloadSite, encodedVideoURL];
        NSURL *finalURL = [NSURL URLWithString:finalURLString];
        
        // فتح الرابط في متصفح سفاري الخارجي
        if ([[UIApplication sharedApplication] canOpenURL:finalURL]) {
            [[UIApplication sharedApplication] openURL:finalURL options:@{} completionHandler:nil];
        }
    } else {
        // تنبيه للمستخدم في حال لم يتم العثور على أي رابط للفيديو
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطأ" message:@"لم يتم العثور على رابط الفيديو" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"موافق" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

%end
