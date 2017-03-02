//
//  IDSManualEditController.h
//  IDSCameraController
//
//  Created by David Okun on 14/09/2016.
//  Copyright © 2016 IDScan Biometrics Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IDSManualEditController;

/**
 *  Delegate used to return information from controller that manually edits image
 */
@protocol IDSManualEditControllerDelegate <NSObject>

@required
/**
 *  Method that allows for the user to cancel the action of manually editing the rotation of an image
 *
 *  @param controller IDSManualEditController that is currently active
 *
 */
- (void)controllerDidCancel:(nonnull IDSManualEditController *)controller;

@required
/**
 *  Method that allows for the user to finish manually editing an image, and to get back the rotated image
 *
 *  @param controller IDSManualEditController that is currently active
 *  @param image      UIImage as edited by the controller
 *
 */
- (void)controller:(nonnull IDSManualEditController *)controller didConfirmEditedImage:(nonnull UIImage *)image;

@end

/**
 *  Manual editing controller that takes any image, and can return it rotated by any factor of 90 degrees
 */
@interface IDSManualEditController : UIViewController

/**
 *  Delegate that must be set to interact with editing controller
 */
@property (nonatomic, nonnull) id<IDSManualEditControllerDelegate> delegate;

/**
 *  Method that creates instance of editing controller for manipulating image manually
 *
 *  @param image        UIImage representing original image that will be rotated
 *  @param helpMessage  NSString representing message to show from optional help button
 *
 *  @warning if the help message passed in is nil, the help button will be invisible on the controller
 *
 */
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image helpMessage:(nullable NSString *)helpMessage;

@end
