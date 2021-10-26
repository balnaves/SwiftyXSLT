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

@class XSLTResult;

@interface SwiftyXSLT : NSObject

+ (SwiftyXSLT *)shared;
- (XSLTResult * _Nullable)transformXMLData:(NSData *)xmlData withStyleSheetData:(NSData *)styleData error:(NSError **)error;
- (XSLTResult * _Nullable)transformXML:(xmlDocPtr)xmlPtr withStyleSheetData:(NSData *)styleData error:(NSError **)error;

@end

@interface XSLTResult : NSObject

@property (nonatomic, readonly) xmlDocPtr doc;
@property (nonatomic, readonly) xsltStylesheetPtr stylesheet;

@property (nonatomic, readonly) BOOL freeWhenDone; // default YES;

- (NSData *)data;

@end

NS_ASSUME_NONNULL_END

#endif /* SwiftyXSLT_h */
