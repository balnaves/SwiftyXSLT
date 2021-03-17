//
//  SwiftyXSLT.h
//  
//
//  Created by James Balnaves on 3/4/21.
//
#import <Foundation/Foundation.h>

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
- (NSString * _Nullable)transformXML:(NSString *)xmlString withStyleSheet:(NSString *)styleString error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif /* SwiftyXSLT_h */
