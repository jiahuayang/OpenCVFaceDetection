//
//  ViewController.m
//  OpenCVFaceDetection
//
//  Created by yangjiahua on 2018/2/22.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/highgui/ios.h>

using namespace cv;

@interface ViewController ()<CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, retain) CvVideoCamera* videoCamera;

@end

@implementation ViewController


/**
 *  Start to detection faces.
 *
 */
- (IBAction)startBtn:(id)sender {
    // Start to handle the video frame. 
    [self.videoCamera start];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;  // set smaller to run fluency
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;  // output 32 bit BGRA
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#ifdef __cplusplus

// Cascade Classifier
static cv::CascadeClassifier faceDetector;

/**
 *  Func to detecte the face.
 *  
 *  @param image: source video frame.
 *  @param sideFace: false - detection the front face; true - or side face.
 */
static std::vector<cv::Rect> facesDetectionMode(cv::Mat& image, bool sideFace){
    
    NSString* cascadePath;
    
    if(!sideFace){
        // front face detection
        // Load cascade classifier from the XML file
        // XML file:https://github.com/opencv/opencv/blob/master/data/haarcascades/haarcascade_frontalface_alt2.xml
        cascadePath = [[NSBundle mainBundle]
                       pathForResource:@"haarcascade_frontalface_alt"
                       ofType:@"xml"];
        
    }else{
       
        // side face detection
        cascadePath = [[NSBundle mainBundle]
                       pathForResource:@"haarcascade_profileface"
                       ofType:@"xml"];
    }
    
    // To load parameters, we need to convert the NSString object to std::string.
    // In order to do it, we use the UTF8String method returns a null-terminated UTF-8 representation of the NSString object.
    faceDetector.load([cascadePath UTF8String]);
    
    // Convert to grayscale
    cv::Mat gray;
    cvtColor(image, gray, CV_BGR2GRAY);
    
    std::vector<cv::Rect> faces;
    faceDetector.detectMultiScale(gray, faces, 1.1,
                                  2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    
    return faces;
}


#pragma mark - Protocol CvVideoCameraDelegate

// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image{
    
    // Detect faces
    std::vector<cv::Rect> faces = facesDetectionMode(image, false);
    if(0 == (int)faces.size()){
        faces = facesDetectionMode(image, true);
    }
    
    XLog(@"%d", (int)faces.size());
    
    // Draw all detected faces
    for(unsigned int i = 0; i < faces.size(); i++)
    {
        const cv::Rect& face = faces[i];
        // Get top-left and bottom-right corner points
        cv::Point tl(face.x, face.y);
        cv::Point br = tl + cv::Point(face.width, face.height);
        
        // Draw rectangle around the face
        cv::Scalar magenta = cv::Scalar(255, 0, 255);
        cv::rectangle(image, tl, br, magenta, 4, 8, 0);
    }
    
    // Show resulting image
    _imageView.image = MatToUIImage(image);

}
#endif


@end
