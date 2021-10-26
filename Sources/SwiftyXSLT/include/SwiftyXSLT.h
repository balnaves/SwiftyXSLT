//
//  SwiftyXSLT.h
//  
//
//  Created by James Balnaves on 3/4/21.
//

#import <Foundation/Foundation.h>
#import "xsltinternals.h"

#ifndef SwiftyXSLT_h
#define SwiftyXSLT_h

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const SwiftyXSLTErrorDomain;

typedef NS_ERROR_ENUM(SwiftyXSLTErrorDomain, SwiftyXSLTError) {
    missingInputString,
    cannotParseStylesheet,
    cannotApplyStylesheet,
    cannotConvertResultToString
};

@interface SwiftyXSLT : NSObject

+ (SwiftyXSLT *)shared;
- (NSData * _Nullable)transformXMLData:(NSData *)xmlData withStyleSheetData:(NSData *)styleData error:(NSError **)error;
- (NSData * _Nullable)transformXML:(xmlDocPtr)xmlPtr withStyleSheetData:(NSData *)styleData error:(NSError **)error;
- (NSData * _Nullable)transformXML:(xmlDocPtr)xmlPtr withStyleSheet:(xsltStylesheetPtr)stylesheet error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif /* SwiftyXSLT_h */
