//
//  ICAdministration+StandAlone.h
//  PCL Library
//
//  Created by Christophe Fontaine on 23/02/2011.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ICISMPDevice.h"
#import "ICAdministration.h"

#pragma mark ICAdministration Constants & Structures

typedef struct {
	unsigned short	posNumber;                              /**< The POS number (should be within the range [0 - 255]) */
	char			amount[8];                              /**< The amount for the transaction (left completed with '0'). If the ISO2 track needs to be read, amount should be '0' */
	unsigned char	specificField;                          /**< Do not used */
	unsigned char	accountType;                            /**< The kind of payment the POS wishes to use :
                                                             <table>
                                                             <tr> <td>AllKinds</td> <td>'0'</td> </tr>
                                                             <tr> <td>Bancaire</td> <td>'1'</td> </tr>
                                                             <tr> <td>AmericanExpress</td> <td>'2'</td> </tr>
                                                             <tr> <td>Aurore</td> <td>'3'</td> </tr>
                                                             <tr> <td>Cetelem</td> <td>'4'</td> </tr>
                                                             <tr> <td>Cofinoga</td> <td>'5'</td> </tr>
                                                             <tr> <td>DinerClub</td> <td>'6'</td> </tr>
                                                             <tr> <td>Pass</td> <td>'7'</td> </tr>
                                                             <tr> <td>Franfinance</td> <td>'8'</td> </tr>
                                                             <tr> <td>JCB</td> <td>'9'</td> </tr>
                                                             <tr> <td>Accord</td> <td>'A'</td> </tr>
                                                             <tr> <td>Cheque</td> <td>'C'</td> </tr>
                                                             <tr> <td>Finaref</td> <td>'F'</td> </tr>
                                                             <tr> <td>Modeus</td> <td>'M'</td> </tr>
                                                             <tr> <td>Moneo</td> <td>'O'</td> </tr>
                                                             <tr> <td>PinaultPrintempsRedoute</td> <td>'P'</td> </tr>
                                                             <tr> <td>Mondex</td> <td>'X'</td> </tr>
                                                             </table>*/
	unsigned char	transactionType;                        /**< The type of transaction:
                                                             <table>
                                                             <tr> <td>Debit</td> <td>'0'</td> </tr>
                                                             <tr> <td>Credit</td> <td>'1'</td> </tr>
                                                             <tr> <td>Annulation</td> <td>'2'</td> </tr>
                                                             <tr> <td>Duplicata</td> <td>'3'</td> </tr>
                                                             <tr> <td>ISO2</td> <td>'A'</td> </tr>
                                                             <tr> <td>Specific</td> <td>'B'</td> </tr>
                                                             </table>*/
	char			currency[3];                            /**< The currency code in ISO4217 format */
	char			privateData[10];                        /**< Application specific data to be passed to payment application */
	unsigned char	delay;                                  /**< Indicates if the Companion should answer immediately or at the end of the transaction ('0' for immediate answer and '1' for a reported answer) */
	unsigned char	authorization;                          /**< The authorization that the POS asks the Companion for
                                                             <table>
                                                             <tr> <td>Authorization Type 0</td> <td>'0'</td> </tr>
                                                             <tr> <td>Authorization Type 1</td> <td>'1'</td> </tr>
                                                             <tr> <td>Authorization Type 2</td> <td>'2'</td> </tr>
                                                             </table>*/
} ICTransactionRequest;

typedef struct {
	unsigned short	posNumber;                              /**< The POS number (should be within the range [0 - 255]) */
	unsigned char	operationStatus;                        /**< The status of the payment process */
	char			amount[8];                              /**< The real amount used for the transaction */
	unsigned char	accountType;                            /**< The account type used for the transaction. Should be one of the enumerations defined within ICTransactionAccountType */
	char			currency[3];                            /**< The currency code in ISO4217 format (the same as in the transaction request) */
	char			privateData[10];                        /**< Application specific data to be passed to POS application */
	char			PAN[19];                                /**< No longer to be used */
	char			cardValidity[4];                        /**< No longer to be used */
	char			authorizationNumber[9];                 /**< The authorization number */
	char			CMC7[35];                               /**< No longer to be used*/
	char			ISO2[38];                               /**< No longer to be used*/
	char			FNCI[10];                               /**< No longer to be used */
	char			guarantor[10];                          /**< No longer to be used */
    char            zoneRep[55];                            /**< Response of the cash register connection */
    char            zonePriv[10];                           /**< Private area */
} ICTransactionReply;

typedef struct {
	NSUInteger		screenX;                                /**< The X position of the screen */
	NSUInteger		screenY;                                /**< The Y position of the screen */
	NSUInteger		screenWidth;                            /**< The Width of the capture screen */
	NSUInteger		screenHeight;                           /**< The Height of the capture screen */
	NSUInteger		userSignTimeout;                        /**< The timeout for the signature to be captured and sent to the Companion */
} ICSignatureData;

#pragma mark -
@protocol ICAdministrationDelegate;

@interface ICAdministration (StandAlone)

-(void)doTransaction:(ICTransactionRequest)request;

-(void)doTransaction:(ICTransactionRequest)request withData:(NSData *)extendedData andApplicationNumber:(NSUInteger)appNum;

-(void)setDoTransactionTimeout:(NSUInteger)timeout;

-(NSUInteger)getDoTransactionTimeout;

-(BOOL)submitSignatureWithImage:(UIImage *)image;

-(BOOL)sendMessage:(NSData *)data;

@end

#pragma mark ICAdministrationDelegateStandAlone

@protocol ICAdministrationStandAloneDelegate <ICAdministrationDelegate>
@optional

-(void)transactionDidEndWithTimeoutFlag:(BOOL)replyReceived result:(ICTransactionReply)transactionReply andData:(NSData *)extendedData;

-(void)shouldDoSignatureCapture:(ICSignatureData)signatureData;

-(void)signatureTimeoutExceeded;

-(void)messageReceivedWithData:(NSData *)data;

-(void)shouldPrintText:(NSString *)text withFont:(UIFont *)font andAlignment:(UITextAlignment)alignment;

-(void)shouldPrintText:(NSString *)text withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline;

-(void)shouldPrintText:(NSString *)text withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline bold:(BOOL)bold;

-(void)shouldPrintRawText:(char *)text withCharset:(NSInteger)charset withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline bold:(BOOL)bold;

-(void)shouldPrintImage:(UIImage *)image;

-(void)shouldFeedPaperWithLines:(NSUInteger)lines;

-(void)shouldCutPaper;

-(NSInteger)shouldStartReceipt:(NSInteger)type;

-(NSInteger)shouldEndReceipt;

-(NSInteger)shouldAddSignature;

-(void)shouldSendPclAddonInfos;

@end

#pragma mark -
