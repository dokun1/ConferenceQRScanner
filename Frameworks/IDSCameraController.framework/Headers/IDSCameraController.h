//
//  IDSCameraController.h
//  IDESiOS
//
//  Created by Tomas Zemaitis <t.zemaitis@idscan.co.uk>.
//  Modified by David Okun <d.okun@idscan.co.uk>.
//  Modified by Edvardas Maslauskas <e.maslauskas@idscan.com>.
//  Copyright (c) 2014 IDScan Biometrics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class IDSCameraController;

/**
 *  Delegate used in conjunction with camera to handle asynchronous feedback
 */
@protocol IDSCameraCaptureControllerDelegate <NSObject>

@optional
/**
 *  Method that allows for the user to get frames returned from a camera object created for convenience
 *
 *  @param controller IDSCameraController that is currently active
 *  @param frame      UIImage of raw image frame returned from camera
 *
 * 
 */
- (void)captureController:(nonnull IDSCameraController *)controller didReceiveFrame:(nonnull UIImage *)frame;

@optional
/**
 *  Method that reports an error to the consumer of the camera API
 *
 *  @param controller IDSCameraController that is currently active
 *  @param error      NSError describing the issue
 */
- (void)captureController:(nonnull IDSCameraController *)controller didFailWithError:(nonnull NSError *)error;

@optional
/**
 *  Method that tells the user that the camera cancel button has been tapped
 *
 *  @param controller IDSCameraController that is currently active
 */
- (void)captureControllerDidCancel:(nonnull IDSCameraController *)controller;

@optional
/**
 *  Methods that passes still image to the user when
 *
 *  @param camera controller IDSCameraController that is currently active
 *  @param image  UIImage of raw image frame returned from camera

 */
- (void)camera:(nonnull IDSCameraController *)camera didCaptureStillImage:(nonnull UIImage *)image;

@optional
/**
 *  Method that tells the delegate that help button was tapped
 *
 *  @param controller IDSCameraController that is currently active
 */
- (void)captureControllerShouldOpenHelpController:(nonnull IDSCameraController *)controller;

@end

/**
 *  Camera controller object that returns raw frames for processing in the IDESDocumentProcessingService
 */
@interface IDSCameraController : UIViewController <IDSCameraCaptureControllerDelegate>

/**
 *  Delegate that must be set to interact with camera API
 */
@property (nonatomic, weak, nullable) id<IDSCameraCaptureControllerDelegate> delegate;

/**
 *  represents a number after which the trigger button should appear
 *  @discussion
 *  < 0 trigger button won't appear
 *  == 0 trigger button will be visible from the beginning
 *  > 0 trigger button will appear after specified time
 *  @note if it's not set the default value will be 5
 */
@property (nonatomic, assign) CGFloat triggerAppearDelay;

/**
 *  @brief AVCaptureDevicePosition initial camera position on camera controller's startup
 */
@property (nonatomic, assign) AVCaptureDevicePosition initialDevicePosition;

/**
 *  Method that manually allows flash to be toggled if available
 */
- (void)toggleFlash;

/**
 *  Method that manually switches between front and back camera if available
 */
- (void)toggleCamera;

@end
