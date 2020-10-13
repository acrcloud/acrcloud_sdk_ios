//
//  ViewController.h
//  ACRCloudiOSDemo
//
//  Created by olym.yin on 2020/9/28.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UITextView *resultView;
- (IBAction)startRecognition:(id)sender;
- (IBAction)stopRecognition:(id)sender;
@end

