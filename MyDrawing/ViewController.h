//
//  ViewController.h
//  MyDrawing
//
//  Created by 林台益 on 2016/6/10.
//  Copyright © 2016年 finalproject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat brushTemp;
    CGFloat opacity;
    NSInteger mode;
    
    CGFloat lastRed;
    CGFloat lastGreen;
    CGFloat lastBlue;
    CGFloat lastOpacity;
    
    BOOL mouseSwiped;
    BOOL isChoose;
}
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;

@property (weak, nonatomic) IBOutlet UIView *sizeView;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIView *pencilView;
@property (weak, nonatomic) IBOutlet UIView *toolView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeViewSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pencilViewSpace;

- (IBAction)modePressed:(id)sender;

- (IBAction)sizePressed:(id)sender;

- (IBAction)pencilPressed:(id)sender;

- (IBAction)eraserPressed:(id)sender;

- (IBAction)colorChoosePressed:(id)sender;

- (IBAction)sizeChoosePressed:(id)sender;

- (IBAction)pencilChoosePressed:(id)sender;

- (IBAction)reset:(id)sender;




@end

