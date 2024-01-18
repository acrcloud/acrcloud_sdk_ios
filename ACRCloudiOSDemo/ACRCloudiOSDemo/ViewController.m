//
//  ViewController.m
//  ACRCloudDemo
//
//  Created by olym on 15/3/29.
//  Copyright (c) 2015 ACRCloud.
//

#import "ViewController.h"

#import <ACRCloudiOSSDK/ACRCloudRecognition.h>
#import <ACRCloudiOSSDK/ACRCloudConfig.h>

@interface ViewController ()

@end

@implementation ViewController
{
    ACRCloudRecognition         *_client;
    ACRCloudConfig          *_config;
    UITextView              *_resultTextView;
    NSTimeInterval          startTime;
    __block BOOL    _start;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _start = NO;
    
    _config = [[ACRCloudConfig alloc] init];
    
    _config.accessKey = @"<your project key>";
    _config.accessSecret = @"<your project secret>";
    _config.host = @"<your project host>";
    _config.protocol = @"https";
    
    //if you want to identify your offline db, set the recMode to "rec_mode_local"
    _config.recMode = rec_mode_remote;
    _config.requestTimeout = 10;
    
    /* used for local model */
    if (_config.recMode == rec_mode_local)
        _config.homedir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"acrcloud_local_db"];
    
    __weak typeof(self) weakSelf = self;
    
    _config.stateBlock = ^(NSString *state) {
        [weakSelf handleState:state];
    };
    
    _config.volumeBlock = ^(float volume) {
        //do some animations with volume
        [weakSelf handleVolume:volume];
    };
    
    _config.resultBlock = ^(NSString *result, ACRCloudResultType resType) {
        [weakSelf handleResult:result resultType:resType];
    };
    
    /*if you want to get the result and fingerprint, uncoment this code, comment the code "resultBlock".*/
    //_config.resultFpBlock = ^(NSString *result, NSData* fingerprint) {
    //    [weakSelf handleResultFp:result fingerprint:fingerprint];
    //};
    
    /*if you want to get the result and pcm data, uncoment this code, comment the code "resultBlock".*/
//    _config.resultDataBlock = ^(NSString *result, NSData* pcm_data) {
//        [weakSelf handleResultData:result data:pcm_data];
//    };
    
    _client = [[ACRCloudRecognition alloc] initWithConfig:_config];

    //start pre-record
    [_client startPreRecord:3000];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (IBAction)startRecognition:(id)sender {
    if (_start) {
        return;
    }
    
    self.resultView.text = @"";
    self.costLabel.text = @"";
    
    [_client startRecordRec];
    _start = YES;
    
    startTime = [[NSDate date] timeIntervalSince1970];
}

- (IBAction)stopRecognition:(id)sender {
    if(_client) {
        [_client stopRecordRec];
    }
    _start = NO;
}

-(void)handleResultFp:(NSString *)result
         fingerprint:(NSData*)fingerprint
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", result);
        
        // the fingerprint is nil when can't generate fingerprint from pcm data.
        if (fingerprint) {
            NSLog(@"fingerprint data length = %ld", fingerprint.length);
        }
        [self->_client stopRecordRec];
        self->_start = NO;
    });
}

-(void)handleResultData:(NSString *)result
                   data:(NSData*)pcm_data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", result);
        
        if (pcm_data) {
            NSLog(@"pcm data length = %ld", pcm_data.length);
        }
        [self->_client stopRecordRec];
        self->_start = NO;
    });
}

-(void)handleResult:(NSString *)result
         resultType:(ACRCloudResultType)resType
{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;

        NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        NSString *r = nil;
        
        NSLog(@"%@", result);

        if ([[jsonObject valueForKeyPath: @"status.code"] integerValue] == 0) {
            if ([jsonObject valueForKeyPath: @"metadata.music"]) {
                NSDictionary *meta = [jsonObject valueForKeyPath: @"metadata.music"][0];
                NSString *title = [meta objectForKey:@"title"];
                NSString *artist = [meta objectForKey:@"artists"][0][@"name"];
                NSString *album = [meta objectForKey:@"album"][@"name"];
                NSString *play_offset_ms = [meta objectForKey:@"play_offset_ms"];
                NSString *duration = [meta objectForKey:@"duration_ms"];

                NSArray *ra = @[[NSString stringWithFormat:@"title:%@", title],
                            [NSString stringWithFormat:@"artist:%@", artist],
                              [NSString stringWithFormat:@"album:%@", album],
                                [NSString stringWithFormat:@"play_offset_ms:%@", play_offset_ms],
                                [NSString stringWithFormat:@"duration_ms:%@", duration]];
                r = [ra componentsJoinedByString:@"\n"];
            }
            if ([jsonObject valueForKeyPath: @"metadata.custom_files"]) {
                NSDictionary *meta = [jsonObject valueForKeyPath: @"metadata.custom_files"][0];
                NSString *title = [meta objectForKey:@"title"];
                NSString *audio_id = [meta objectForKey:@"audio_id"];
                
                r = [NSString stringWithFormat:@"title : %@\naudio_id : %@", title, audio_id];
            }
            if ([jsonObject valueForKeyPath: @"metadata.streams"]) {
                NSDictionary *meta = [jsonObject valueForKeyPath: @"metadata.streams"][0];
                NSString *title = [meta objectForKey:@"title"];
                NSString *title_en = [meta objectForKey:@"title_en"];
                
                r = [NSString stringWithFormat:@"title : %@\ntitle_en : %@", title,title_en];
            }
            if ([jsonObject valueForKeyPath: @"metadata.custom_streams"]) {
                NSDictionary *meta = [jsonObject valueForKeyPath: @"metadata.custom_streams"][0];
                NSString *title = [meta objectForKey:@"title"];
                
                r = [NSString stringWithFormat:@"title : %@", title];
            }
            if ([jsonObject valueForKeyPath: @"metadata.humming"]) {
                NSArray *metas = [jsonObject valueForKeyPath: @"metadata.humming"];
                NSMutableArray *ra = [NSMutableArray arrayWithCapacity:6];
                for (id d in metas) {
                    NSString *title = [d objectForKey:@"title"];
                    NSString *score = [d objectForKey:@"score"];
                    NSString *sh = [NSString stringWithFormat:@"title : %@  score : %@", title, score];
                    
                    [ra addObject:sh];
                }
                r = [ra componentsJoinedByString:@"\n"];
            }
            
            self.resultView.text = r;
        } else {
            self.resultView.text = result;
        }
        
        [self->_client stopRecordRec];
        self->_start = NO;

//        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
//        int cost = nowTime - startTime;
//        self.costLabel.text = [NSString stringWithFormat:@"cost : %ds", cost];

    });
}

-(void)handleVolume:(float)volume
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.volumeLabel.text = [NSString stringWithFormat:@"Volume : %f",volume];
        
    });
}

-(void)handleState:(NSString *)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stateLabel.text = [NSString stringWithFormat:@"State : %@",state];
    });
}

@end
