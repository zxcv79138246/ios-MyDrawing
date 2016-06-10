//
//  ViewController.m
//  MyDrawing
//
//  Created by 林台益 on 2016/6/10.
//  Copyright © 2016年 finalproject. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    mode = 1;   //mode 0 鉛筆  1 毛筆
    
    isChoose = false;
    self.colorView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.5];
    self.sizeView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.5];
    self.pencilView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.5];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    //毛筆筆觸
    if (mode == 2) {
        double pointLength = pow(pow((lastPoint.x - currentPoint.x), 2) + pow((lastPoint.y - currentPoint.y), 2), 0.5);
        if (pointLength>10){
            brush = brush*0.9;
            if (brush < 5) {
                brush = 5;
            }
            
        }else if (pointLength<5) {
            brush = brush*1.03;
            if (brush > 50) {
                brush = 50;
            }
        }
    }
    //
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    brush = brushTemp;
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}




- (IBAction)modePressed:(id)sender {
    UIButton * modeButton = (UIButton*)sender;
    
    switch(modeButton.tag)
    {
        case 1:
            //選擇鉛筆做的事情
            mode = 1;
            brush = 10.0f;
            brushTemp = brush;
            break;
        case 2:
            //選擇毛筆做的事情
            mode = 2;
            break;
    }

}

- (IBAction)sizePressed:(id)sender {
    UIButton * sizeButton = (UIButton*)sender;
    
    switch(sizeButton.tag)
    {
        case 1:
            brush = 10.0f;
            brushTemp = brush;
            break;
        case 2:
            brush = 30.0f;
            brushTemp = brush;
            break;
        case 3:
            brush = 50.0f;
            brushTemp = brush;
            break;
    }
}

- (IBAction)pencilPressed:(id)sender {
    UIButton * PressedButton = (UIButton*)sender;
    
    switch(PressedButton.tag)
    {
        case 1:
            red = 255.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            break;
        case 2:
            red = 255.0/255.0;
            green = 128.0/255.0;
            blue = 0.0/255.0;
            break;
        case 3:
            red = 255.0/255.0;
            green = 255.0/255.0;
            blue = 0.0/255.0;
            break;
        case 4:
            red = 0.0/255.0;
            green = 255.0/255.0;
            blue = 0.0/255.0;
            break;
        case 5:
            red = 128.0/255.0;
            green = 255.0/255.0;
            blue = 255.0/255.0;
            break;
        case 6:
            red = 0.0/255.0;
            green = 0.0/255.0;
            blue = 255.0/255.0;
            break;
        case 7:
            red = 128.0/255.0;
            green = 0.0/255.0;
            blue = 128.0/255.0;
            break;
        case 8:
            red = 0.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            break;
            
    }
    

    
    self.colorView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.5];
    self.sizeView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.5];
    self.pencilView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.5];

}

- (IBAction)eraserPressed:(id)sender {
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    opacity = 1.0;
}

- (IBAction)colorChoosePressed:(id)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.colorViewSpace.constant = 90.0f*(self.view.frame.size.width/375);
        self.sizeViewSpace.constant = 0.0f;
        self.pencilViewSpace.constant = 0.0f;
        [self.colorView layoutIfNeeded];
        [self.sizeView layoutIfNeeded];
        [self.pencilView layoutIfNeeded];
    }];

}

- (IBAction)sizeChoosePressed:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.colorViewSpace.constant = 0.0f;
        self.sizeViewSpace.constant = 90.0f*(self.view.frame.size.width/375);
        self.pencilViewSpace.constant = 0.0f;
        [self.colorView layoutIfNeeded];
        [self.sizeView layoutIfNeeded];
        [self.pencilView layoutIfNeeded];
    }];
}

- (IBAction)pencilChoosePressed:(id)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.colorViewSpace.constant = 0.0f;
        self.sizeViewSpace.constant = 0.0f;
        self.pencilViewSpace.constant = 90.0f*(self.view.frame.size.width/375);
        [self.colorView layoutIfNeeded];
        [self.sizeView layoutIfNeeded];
        [self.pencilView layoutIfNeeded];
    }];
}

- (IBAction)reset:(id)sender {
    self.mainImage.image = nil;
    brushTemp = brush;
}


@end
