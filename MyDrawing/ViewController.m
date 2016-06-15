//
//  ViewController.m
//  MyDrawing
//
//  Created by 林台益 on 2016/6/10.
//  Copyright © 2016年 finalproject. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "TransferService.h"

@interface ViewController () <CBPeripheralManagerDelegate, UITextViewDelegate>


@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;


@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

#define NOTIFY_MTU      20


@implementation ViewController

- (void)viewDidLoad {
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    mode = 1;   //mode 0 鉛筆  1 毛筆
    brushTemp = brush;
    
    isChoose = false;
    sizeChoose = 1;
    self.toolView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.5f];
    
    lastRed = red;
    lastGreen = green;
    lastBlue = blue;
    lastOpacity = opacity;
    
    
    [super viewDidLoad];
    // Start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    [self.peripheralManager stopAdvertising];

    [super viewWillDisappear:animated];
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
    
    UIGraphicsBeginImageContextWithOptions(self.mainImage.bounds.size, NO,0.0);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    saveImage = UIGraphicsGetImageFromCurrentImageContext();
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
    red = lastRed;
    green = lastGreen;
    blue = lastBlue;
    opacity = lastOpacity;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.colorViewSpace.constant = 0.0f;
        self.sizeViewSpace.constant = 0.0f;
        self.pencilViewSpace.constant = 0.0f;
        [self.colorView layoutIfNeeded];
        [self.sizeView layoutIfNeeded];
        [self.pencilView layoutIfNeeded];
    }];
}

- (IBAction)sizePressed:(id)sender {
    UIButton * sizeButton = (UIButton*)sender;
    
    switch(sizeButton.tag)
    {
        
        case 1:
            self.sizeButtonS.backgroundColor = [UIColor colorWithRed: 0 green:0 blue:0 alpha:0.5f];
            self.sizeButtonM.backgroundColor = [UIColor colorWithRed: 128 green:128 blue:128 alpha:0.5f];
            self.sizeButtonL.backgroundColor = [UIColor colorWithRed: 128 green:128 blue:128 alpha:0.5f];
            brush = 10.0f;
            brushTemp = brush;
            break;
        case 2:
            self.sizeButtonM.backgroundColor = [UIColor colorWithRed: 0 green:0 blue:0 alpha:0.5f];
            self.sizeButtonS.backgroundColor = [UIColor colorWithRed: 128 green:128 blue:128 alpha:0.5f];
            self.sizeButtonL.backgroundColor = [UIColor colorWithRed: 128 green:128 blue:128 alpha:0.5f];
            brush = 30.0f;
            brushTemp = brush;
            break;
        case 3:
            self.sizeButtonL.backgroundColor = [UIColor colorWithRed: 0 green:0 blue:0 alpha:0.5f];
            self.sizeButtonS.backgroundColor = [UIColor colorWithRed: 128 green:128 blue:128 alpha:0.5f];
            self.sizeButtonM.backgroundColor = [UIColor colorWithRed: 128 green:128 blue:128 alpha:0.5f];
            brush = 50.0f;
            brushTemp = brush;
            break;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.colorViewSpace.constant = 0.0f;
        self.sizeViewSpace.constant = 0.0f;
        self.pencilViewSpace.constant = 0.0f;
        [self.colorView layoutIfNeeded];
        [self.sizeView layoutIfNeeded];
        [self.pencilView layoutIfNeeded];
    }];
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
    
    lastRed = red;
    lastGreen = green;
    lastBlue = blue;
    lastOpacity = opacity;
    self.opacityView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:1.0f];
    self.toolView.backgroundColor = [UIColor colorWithRed: red green:green blue:blue alpha:0.3f];
//    [UIView animateWithDuration:0.25 animations:^{
//        self.colorViewSpace.constant = 0.0f;
//        self.sizeViewSpace.constant = 0.0f;
//        self.pencilViewSpace.constant = 0.0f;
//        [self.colorView layoutIfNeeded];
//        [self.sizeView layoutIfNeeded];
//        [self.pencilView layoutIfNeeded];
//    }];

}


- (IBAction)opacityPressed:(id)sender {
    UIButton * opacityPressedButton = (UIButton*)sender;
    
    switch(opacityPressedButton.tag)
    {
        case 1:
            opacity = 0.2f;
            break;
        case 2:
            opacity = 0.4f;
            break;
        case 3:
            opacity = 0.6f;
            break;
        case 4:
            opacity = 0.8f;
            break;
        case 5:
            opacity = 1.0f;
            break;
    }
    
    lastRed = red;
    lastGreen = green;
    lastBlue = blue;
    lastOpacity = opacity;
    

//    [UIView animateWithDuration:0.25 animations:^{
//        self.colorViewSpace.constant = 0.0f;
//        self.sizeViewSpace.constant = 0.0f;
//        self.pencilViewSpace.constant = 0.0f;
//        [self.colorView layoutIfNeeded];
//        [self.sizeView layoutIfNeeded];
//        [self.pencilView layoutIfNeeded];
//    }];
}

- (IBAction)eraserPressed:(id)sender {
    lastRed = red;
    lastGreen = green;
    lastBlue = blue;
    lastOpacity = opacity;
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    opacity = 1.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.colorViewSpace.constant = 0.0f;
        self.sizeViewSpace.constant = 0.0f;
        self.pencilViewSpace.constant = 0.0f;
        [self.colorView layoutIfNeeded];
        [self.sizeView layoutIfNeeded];
        [self.pencilView layoutIfNeeded];
    }];
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
      [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
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

- (IBAction)save:(id)sender {
    
    UIImageWriteToSavedPhotosAlbum(saveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    self.mainImage.image = saveImage;

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image could not be saved.Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image was successfully saved in photoalbum"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    }
}


#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    // Get the data
    //self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    self.dataToSend = UIImagePNGRepresentation(saveImage);
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}



#pragma mark - TextView Methods



///** This is called when a change happens, so we know to stop advertising
// */
//- (void)textViewDidChange:(UITextView *)textView
//{
//    // If we're already advertising, stop
//    if (self.advertisingSwitch.on) {
//        [self.advertisingSwitch setOn:NO];
//        [self.peripheralManager stopAdvertising];
//    }
//}


/** Adds the 'Done' button to the title bar
 */
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // We need to add this manually so we have a way to dismiss the keyboard
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    self.navigationItem.rightBarButtonItem = rightButton;
}


/** Finishes the editing */
- (void)dismissKeyboard
{
    //[self.textView resignFirstResponder];
    [self.mainImage resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}








@end
