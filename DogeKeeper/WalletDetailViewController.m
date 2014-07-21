//
//  WalletDetailViewController.m
//  DogeKeeper
//
//  Created by Andrew on 6/14/14.
//  Copyright (c) 2014 Andrew Arpasi. Licensed under CC BY-NC-ND 4.0
//

#import "WalletDetailViewController.h"

@interface WalletDetailViewController ()

@end

@implementation WalletDetailViewController
@synthesize walletData;
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
    [scrollView addSubview:detailView];
    ((UIScrollView *)scrollView).contentSize = detailView.frame.size;
    DogecoinWallet * wallet = [NSKeyedUnarchiver unarchiveObjectWithData:walletData];
    qrView.image = [UIImage mdQRCodeForString:[NSString stringWithFormat:@"dogecoin:%@",wallet.address] size:qrView.bounds.size.width];
    titleLabel.text = wallet.title;
    balanceLabel.text = @"Loading Balance...";
    recievedLabel.text = @"Loading Recieved...";
    addressView.text = wallet.address;
    DogeChainHandler * chain = [[DogeChainHandler alloc] init];
    if(wallet.isApi)
    {
        balanceLabel.hidden = TRUE;
        recievedLabel.hidden = TRUE;
    }
    else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void) {
            NSString * balance = [chain getDogeBalance:wallet.address];
            NSString * recieved = [chain getDogeRecieved:wallet.address];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(balance != nil && ![balance isEqualToString:@"Error."])
                {
                    balanceLabel.text = [NSString stringWithFormat:@"Balance: %@ DOGE",balance];
                }
                else
                {
                    balanceLabel.text = @"Error retrieving total recieved.";
                }
                if(recieved != nil && ![recieved isEqualToString:@"Error."])
                {
                    recievedLabel.text = [NSString stringWithFormat:@"Total Recieved: %@ DOGE",balance];
                }
                else
                {
                    recievedLabel.text = @"Error retrieving total recieved.";
                }
            });
        });
    }
    amountField.inputAccessoryView = keyboardBar;
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
}
-(void)keyboardDidAppear:(NSNotification*)notification
{
    //(@"the thing is up");
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
    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, height, 0)];
    [UIView commitAnimations];
}
-(void)keyboardWillHide:(NSNotification*)notification
{
    if([[[notification userInfo] valueForKey:@"UIKeyboardFrameChangedByUserInteraction"] intValue] == 0)
    {
        [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}
-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}
-(IBAction)keyboardDone:(id)sender
{
    [amountField resignFirstResponder];
}
-(IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}
- (IBAction)amountFieldChanged:(id)sender
{
    DogecoinWallet * wallet = [NSKeyedUnarchiver unarchiveObjectWithData:walletData];
    if(![amountField.text isEqualToString:@""])
    {
        qrView.image = [UIImage mdQRCodeForString:[NSString stringWithFormat:@"dogecoin:%@?amount=%@",wallet.address,amountField.text] size:qrView.bounds.size.width];
    }
    else
    {
        qrView.image = [UIImage mdQRCodeForString:[NSString stringWithFormat:@"dogecoin:%@",wallet.address] size:qrView.bounds.size.width];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
