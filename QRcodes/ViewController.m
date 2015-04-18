//
//  ViewController.m
//  QRcodes
//
//  Created by Pablo Parejo Camacho on 17/4/15.
//  Copyright (c) 2015 Pablo Parejo Camacho. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeReaderViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
@interface ViewController () <QRCodeReaderDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) QRCodeReaderViewController *reader;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanAction:(id)sender
{
    
    _reader = [QRCodeReaderViewController new];
    
    // Set the presentation style
    _reader.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Using delegate methods
    _reader.delegate = self;
    
    [self presentViewController:_reader animated:YES completion:NULL];
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@", result);
        [weakSelf loadImageFromUrl:[NSURL URLWithString:result]];
    }];
}
- (IBAction)downloadImage:(id)sender {
    [self loadImageFromUrl:[NSURL URLWithString:@"http://pili.la/1125"]];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Utils

-(void)loadImageFromUrl:(NSURL *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (self.hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.hud hide:YES];
        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
        self.hud.labelText = @"Loading image...";
    }
    
    AFHTTPRequestOperation *requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOp.responseSerializer = [AFImageResponseSerializer serializer];
    __weak typeof(self) weakSelf = self;
    [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        weakSelf.imageView.image = responseObject;
        [weakSelf.hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [requestOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
        weakSelf.hud.progress = progress;
        NSLog(@"%f", progress);
    }];
    
    [requestOp start];
}

@end
