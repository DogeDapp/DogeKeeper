//
//  SendViewController.m
//  DogeKeeper
//
//  Created by Andrew on 5/17/14.
//  Copyright (c) 2014 Andrew Arpasi. Licensed under CC BY-NC-ND 4.0
//

#import "SendViewController.h"

@interface SendViewController ()

@end

@implementation SendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [sendScroll addSubview:sendView];
    sendView.frame = CGRectMake(sendView.frame.origin.x, sendView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, sendView.frame.size.height);
    ((UIScrollView *)sendScroll).contentSize = sendView.frame.size;
    addressField.inputAccessoryView = keyboardBar;
    amountField.inputAccessoryView = keyboardBar;
    pinField.inputAccessoryView = keyboardBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNotif:) name:@"SendSuccessNotification" object:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(validate)userInfo: nil repeats: YES];
}
-(void)recieveNotif:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"SendSuccessNotification"])
    {
        [self dismissViewControllerAnimated:FALSE completion:nil];
    }
}
-(void)validate
{
    //NEVER EVER SEND A BLANK REQUEST!!!!!
    if([addressField.text isEqual:@""] || [amountField.text isEqual:@""] || [pinField.text isEqual:@""])
    {
        sendBtn.enabled = FALSE;
    }
    else
    {
        sendBtn.enabled = TRUE;
    }
}
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}
-(IBAction)keyboardDone:(id)sender
{
    [addressField resignFirstResponder];
    [amountField resignFirstResponder];
    [pinField resignFirstResponder];
}
-(IBAction)donate:(id)sender
{
    addressField.text = @"DGszZCQdH4tLxu4wZ1nerAL5c9WtS1vmHp";
}
-(IBAction)send:(id)sender
{
    [addressField resignFirstResponder];
    [amountField resignFirstResponder];
    [pinField resignFirstResponder];
    if(amountField.text.doubleValue < 2)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Cannot Send Dogecoins" message:@"Please enter a value 2 or greater." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    BlockIOHandler * api = [[BlockIOHandler alloc] init];
    UIAlertView * loadingAlert = [[UIAlertView alloc] initWithTitle:@"Performing Transaction..." message:@"Please Wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [loadingAlert show];
    __block BOOL tstatus;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        tstatus = [api makeDogeTransaction:[amountField.text doubleValue] toAddress:addressField.text withPin:pinField.text];
        double sendamount = [amountField.text doubleValue];
        NSLog(@"tstatus: %d",tstatus);
        if(tstatus == TRUE)
        {
            DogeTransaction * transaction = [[DogeTransaction alloc] init];
            transaction.toAddress = addressField.text;
            transaction.amount = [[NSNumber alloc] initWithDouble:sendamount];
            NSLog(@"send amount %f",sendamount);
            NSLog(@"transaction amount %f",[transaction.amount doubleValue]);
            transaction.transactionID = [api getTransactionID];
            NSLog(@"transaction netfee: %f",[transaction.networkFee doubleValue]);
            transaction.networkFee = [[NSNumber alloc] initWithDouble:[api getNetworkFee]];
            transactionData = [NSKeyedArchiver archivedDataWithRootObject:transaction];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"transactionSegue" sender:nil];
                [loadingAlert dismissWithClickedButtonIndex:0 animated:TRUE];
            });
            }
            else if(tstatus == FALSE)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [loadingAlert dismissWithClickedButtonIndex:0 animated:TRUE];
                    NSString * apierror = [api getError];
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error Sending Dogecoin" message:apierror delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                });
            }
    });
}
-(double)calculateDisplayedValue:(double)value
{
    return value + 1;
}
-(IBAction)scanAddressQR:(id)sender
{
    if ([BCScannerViewController scannerAvailable]) {
		BCScannerViewController *scanner = [[BCScannerViewController alloc] init];
		scanner.delegate = self;
		scanner.codeTypes = @[ BCScannerQRCode ];
		[self presentViewController:scanner animated:TRUE completion:nil];
    }
}
- (IBAction)editingChanged:(id)sender {
    feeLabel.text = [NSString stringWithFormat:@"%f After 1Ɖ estimated network fee.",[self calculateDisplayedValue:[amountField.text doubleValue]]];
}
- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
}
-(void)keyboardDidAppear:(NSNotification*)notification
{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIWindow *window = [[[UIApplication sharedApplication] windows]objectAtIndex:0];
    CGRect keyboardFrameConverted = [self.view convertRect:keyboardFrame fromView:window];
    int kHeight = keyboardFrameConverted.size.height;
    //NSLog(@"%f",kHeight);
    [self keyboardResize:kHeight];
}
-(void)keyboardResize:(int)height
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [sendScroll setContentInset:UIEdgeInsetsMake(0, 0, height, 0)];
    [UIView commitAnimations];
}
-(void)keyboardWillHide:(NSNotification*)notification
{
    if([[[notification userInfo] valueForKey:@"UIKeyboardFrameChangedByUserInteraction"] intValue] == 0)
    {
        [sendScroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}
-(IBAction)cancel
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - BCScannerViewControllerDelegate

- (void)scanner:(BCScannerViewController *)scanner codesDidEnterFOV:(NSSet *)codes
{
    [scanner dismissViewControllerAnimated:TRUE completion:nil];
    NSString * code = [[codes allObjects] objectAtIndex:0];
    if([code rangeOfString:@"dogecoin:"].location != NSNotFound)
    {
        code = [code stringByReplacingOccurrencesOfString:@"dogecoin:" withString:@""];
    }
    NSLog(@"ehhh: %d",[[code componentsSeparatedByString:@"?"] count]);
    if([[code componentsSeparatedByString:@"?"] count]-1 == 1)
    {
        NSString * params = [[code componentsSeparatedByString:@"?"] objectAtIndex:1];
        NSArray * paramArray = [params componentsSeparatedByString:@"&"];
        for(int i=0;i<[paramArray count];i++)
        {
            if([[paramArray objectAtIndex:i] rangeOfString:@"amount"].location!= NSNotFound)
            {
                NSString * amountStr = [paramArray objectAtIndex:i];
                amountStr = [amountStr stringByReplacingOccurrencesOfString:@"amount=" withString:@""];
                    amountField.text = amountStr;
            }
        }
    }
    addressField.text = [code substringToIndex:34];
    [self editingChanged:nil];
	NSLog(@"Added: [%@]", codes);
}

//- (void)scanner:(BCScannerViewController *)scanner codesDidUpdate:(NSSet *)codes
//{
//	NSLog(@"Updated: [%lu]", (unsigned long)codes.count);
//}

- (void)scanner:(BCScannerViewController *)scanner codesDidLeaveFOV:(NSSet *)codes
{
	NSLog(@"Deleted: [%@]", codes);
}

- (UIImage *)scannerHUDImage:(BCScannerViewController *)scanner
{
	return [UIImage imageNamed:@"HUD"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"transactionSegue"]) {
        TransactionCompleteViewController *complete = [segue destinationViewController];
        complete.transactionData = transactionData;
    }
}


@end
