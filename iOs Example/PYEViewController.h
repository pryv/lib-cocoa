//
//  PYEViewController.h
//  iOs Example
//
//  Created by Pierre-Mikael Legris on 06.02.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYEViewController : UIViewController {
    IBOutlet UIButton *signinButton;
}


@property (nonatomic, retain) IBOutlet UIButton *signinButton;

/**
 *called by Button on the UINavBar
 *This is a shortcut to a pushMenu static call
 **/
- (IBAction)siginButtonPressed:(id)sender;

@end
