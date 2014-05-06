//
//  BRWViewController.m
//  Brew
//
//  Created by Katie Porter on 4/30/14.
//  Copyright (c) 2014 Tivona & Porter. All rights reserved.
//

#import "BRWViewController.h"
#import "BLE.h"

typedef enum {
    BRWBrewControllerStateDisconnected,
    BRWBrewControllerStateWaiting,
    BRWBrewControllerStateArmed,
    BRWBrewControllerStateBrewing,
} BRWViewControllerState;

@interface BRWViewController () <BLEDelegate>

@property (strong, nonatomic) UIButton *coffeeButton;
@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) UIButton *connectButton;
@property (assign, nonatomic) BRWViewControllerState state;

@end

@implementation BRWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ble = [[BLE alloc] init];
    [self.ble controlSetup];
    self.ble.delegate = self;
    
    self.connectButton = [[UIButton alloc] init];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.view addSubview:self.connectButton];
    
    [self.connectButton addTarget:self action:@selector(connectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.connectButton makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    self.coffeeButton = [[UIButton alloc] init];
    self.coffeeButton.hidden = YES;
    [self.view addSubview:self.coffeeButton];
    
    [self.coffeeButton addTarget:self action:@selector(coffeeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.coffeeButton makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(153));
        make.height.equalTo(@(196));
    }];
    
    [self setState:BRWBrewControllerStateDisconnected];
}

- (void)connectButtonTapped
{
    [self scanForPeripherals];
}

- (void)coffeeButtonTapped
{
    NSString *string;
    if (self.state == BRWBrewControllerStateWaiting) {
        string = @"a";
    } else {
        string = @"b";
    }
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
    [self.ble write:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


# pragma mark - BRWViewController

- (IBAction)scanForPeripherals
{
    if (self.ble.activePeripheral)
        if(self.ble.activePeripheral.state == CBPeripheralStateConnected) {
            [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
            return;
        }
    
    if (self.ble.peripherals) {
        self.ble.peripherals = nil;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [self.ble findBLEPeripherals:2];
    [SVProgressHUD show];
}

- (void)connectionTimer:(NSTimer *)timer
{
    [SVProgressHUD dismiss];
    if (self.ble.peripherals.count > 0) {
        [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];
    }
}

- (void)setState:(BRWViewControllerState)state
{
    _state = state;
    
    switch (self.state) {
        case BRWBrewControllerStateWaiting:
            self.coffeeButton.hidden = NO;
            self.connectButton.hidden = YES;
            [self.coffeeButton setBackgroundImage:[UIImage imageNamed:@"Sleepy"] forState:UIControlStateNormal];
            break;
        case BRWBrewControllerStateBrewing:
            self.coffeeButton.hidden = NO;
            self.connectButton.hidden = YES;
            [self.coffeeButton setBackgroundImage:[UIImage imageNamed:@"Excited"] forState:UIControlStateNormal];
            break;
        case BRWBrewControllerStateArmed:
            self.coffeeButton.hidden = NO;
            self.connectButton.hidden = YES;
            [self.coffeeButton setBackgroundImage:[UIImage imageNamed:@"Surprised"] forState:UIControlStateNormal];
            break;
        case BRWBrewControllerStateDisconnected:
            self.coffeeButton.hidden = YES;
            self.connectButton.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - BLEDelegate


- (void)bleDidDisconnect
{
    NSLog(@"-> Disconnected");
    [self setState:BRWBrewControllerStateDisconnected];
}


-(void) bleDidConnect
{
    NSLog(@"-> Connected");
}

- (void)bleDidReceiveData:(unsigned char *)data length:(int)length
{
    BOOL brewing = NO;
    BOOL armed = NO;
    
    for (int i = 0; i < length; i+=3) {
        if (data[i] == 0x0A) {
            if (data[i+1] == 0x01) {
                armed = YES;
            }
        } else if (data[i] == 0x0B) {
            UInt16 value;
            value = data[i+2] | data[i+1] << 8;
        } else if (data[i] == 0x0C) {
            if (data[i+1] == 0x01) {
                brewing = YES;
            }
        }
    }
    
    if (brewing) {
        [self setState:BRWBrewControllerStateBrewing];
    } else if (armed) {
        [self setState:BRWBrewControllerStateArmed];
    } else {
        [self setState:BRWBrewControllerStateWaiting];
    }
}

@end
