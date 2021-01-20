# ACRCloud iOS SDK

## Identify Music or TV with iOS SDK
This demo shows how to identify music ( songs ) or detect live TV channels by recorded sound with ACRCloud iOS SDK. Contact us if you have any question or special requirement about the SDK: support@acrcloud.com

## Preparation
* The newest ACRCloud iOS SDK which contains both ObjectC and Swift demo projects.
* If you want to recognize music, you need an Audio Recognition project. ( See [How to Recognize Music](https://docs.acrcloud.com/tutorials/recognize-music) )
* If you want to detect tv channels, you need a Live Channel Detection project. ( See [How to Detect Live TV Channels](https://docs.acrcloud.com/tutorials/detect-live-and-timeshift-tv-channels) )
* Save the information of “host”, “access_key”, “access_secret” of your project.
* Make sure you have Xcode installed.

## Test the demo
* Download the ACRCloud iOS SDK package and unzip it.
* Open either ACRCloudDemo or ACRCloudDemo_Swift
* Update accessKey, host and accessSecret in ViewController with the information of your project.
* Run the demo project to test recognizing contents in the buckets of your project.

## How to use the iOS SDK
1, Init recognition configure
```
    _config = [[ACRCloudConfig alloc] init];
    _config.accessKey = @"your project access key";
    _config.accessSecret = @"your project secret key";
    _config.host = @"your project host";
    _config.protocol = @"https";
    //if you want to identify your offline db, set the recMode to "rec_mode_local"
    _config.recMode = rec_mode_remote;
    if (_config.recMode == rec_mode_local || _config.recMode == rec_mode_both)
        _config.homedir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"acrcloud_local_db"];
        
    //if you use One-time Recording Session Recognition, please set these block.
    __weak typeof(self) weakSelf = self;
    _config.stateBlock = ^(NSString *state) {
        [weakSelf handleState:state];
    };
    _config.volumeBlock = ^(float volume) {
        //do some animations with volume
        [weakSelf handleVolume:volume];
    };
    //result callback. when the sdk gets a result or error, it will call this block.
    _config.resultBlock = ^(NSString *result, ACRCloudResultType resType) {
        [weakSelf handleResult:result resultType:resType];
    };
```
#### recMode is depending on the type of your project,
* rec_mode_remote is for Audio & Video Recognition, Live Channel Detection, Hybrid Recognition, it’s online recognition
* rec_mode_local  is for Offline Recognition, please put the offline database ( such as “acrcloud_local_db” ) into your app project’s workspace.

2, Create a recognition client
```
  _client = [[ACRCloudRecognition alloc] initWithConfig:_config];
```

3, Recognition

### One-time  Recording Session Recognition
Click the “Start” Button and the App Demo will begin to record and recognize. When it detects a result, the "config.resultBlock" will be called, the app demo will stop and display the result. 
In the progress of recording and detecting, you can stop (click the “Stop” Button”) this recognition at any time.
```
-(void)startRecordRec;
-(void)stopRecordRec;
```

#### Open Prerecording Recognition
Open prerecording will make the recognition much more faster.
If you want open this feature, call "-(void)startPreRecord:(NSInteger)recordTime" before "startRecordRec"
The parameter recordTime is the prerecording time. The recommend value is 3000-4000
```
  [_client startPreRecord:3000]
```

### Low-Level Function
#### File/PCM/Fingerprint Recognition
if you recongize audio data, the audio format shoud be  RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 8000 Hz,  you also can use the resample function to convert the audio data to what we need.
```
-(NSString*)recognize:(char*)buffer len:(int)len;
-(NSString*)recognize:(NSData*)pcm_data;
-(NSString*)recognize_fp:(NSData*)fingerprint;
```
#### Humming Recognition
if you recongize humming data, the audio format shoud be  RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16
bit, mono 8000 Hz,  you also can use the resample function to convert the audio data to what we need.
```
//Get humming fingerprint.
+(NSData*)get_hum_fingerprint:(NSData*)pcm;
//recognize humming fingerprint
-(NSString*)recognize_hum_fp:(NSData*)fingerprint;
```
#### Resample Function
Convert your audio format to RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 8000 Hz
```
+(NSData*) resample:(char*)pcm
                len:(unsigned)len
         sampleRate:(unsigned)sampleRate
           nChannel:(short)nChannel;
+(NSData*) resample_bit32:(char*)pcm
                      len:(unsigned)bytes
               sampleRate:(unsigned)sampleRate
                 nChannel:(short)nChannel
                  isFloat:(bool)isFloat;
```
