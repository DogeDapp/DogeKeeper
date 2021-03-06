//
//  DogeTransaction.h
//  DogeKeeper
//
//  Created by Andrew on 5/17/14.
//  Copyright (c) 2014 Andrew Arpasi. Licensed under CC BY-NC-ND 4.0
//


#import <Foundation/Foundation.h>

@interface DogeTransaction : NSObject

@property NSString * transactionID;
@property NSNumber * amount;
@property NSString * toAddress;
@property NSDate * dateSent;
@property NSNumber * networkFee;

+(NSMutableArray*)getAllTransactions;
+(void)addTransactionToHistory:(DogeTransaction*)transaction;

@end
