//
//  SwiftyXSLT.m
//  
//
//  Created by James Balnaves on 3/4/21.
//

#import <Foundation/Foundation.h>
#import "SwiftyXSLT.h"

@import libxslt;

NSErrorDomain const SwiftyXSLTErrorDomain = @"SwiftyXSLTErrorDomain";

@interface XSLTResult ()

- (instancetype)initWithDoc:(xmlDocPtr)doc stylesheet:(xsltStylesheetPtr)stylesheet;

@end

@implementation SwiftyXSLT

+ (SwiftyXSLT *)shared {
    static SwiftyXSLT *sharedSwiftyXSLT = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSwiftyXSLT = [[self alloc] init];
    });
    return sharedSwiftyXSLT;
}

- (XSLTResult *)transformXMLData:(NSData *)xmlData withStyleSheetData:(NSData *)styleData error:(NSError *__autoreleasing  _Nullable *)error {
    xmlDocPtr xmlPtr = xmlReadMemory(xmlData.bytes, (int)xmlData.length, NULL, NULL, 0);
    
    if (xmlPtr == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to read input" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:missingInputString userInfo:errorDetail];
        return nil;
    }

    XSLTResult *result = [self transformXML:xmlPtr withStyleSheetData:styleData error:error];

    xmlFreeDoc(xmlPtr);

    return result;
}

- (XSLTResult *)transformXML:(xmlDocPtr)xmlPtr withStyleSheetData:(NSData *)styleData error:(NSError *__autoreleasing  _Nullable *)error {
    xmlDocPtr stylePtr = xmlReadMemory(styleData.bytes, (int)styleData.length, NULL, NULL, 0);

    if (stylePtr == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to read input" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:missingInputString userInfo:errorDetail];
        return nil;
    }

    xsltStylesheetPtr stylesheet = xsltParseStylesheetDoc(stylePtr);

    if (stylesheet == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to parse stylesheet" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotParseStylesheet userInfo:errorDetail];

        xmlFreeDoc(stylePtr);

        return nil;
    }

    return [self transformXML:xmlPtr withStyleSheet:stylesheet error:error];
}

- (XSLTResult *)transformXML:(xmlDocPtr)xmlPtr withStyleSheet:(xsltStylesheetPtr)stylesheet error:(NSError *__autoreleasing  _Nullable *)error {
    if (stylesheet->forwards_compatible) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Incompatible XSL version. Only 1.1 features are supported." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotParseStylesheet userInfo:errorDetail];
        return nil;
    }
    
    xmlDocPtr result = xsltApplyStylesheet(stylesheet, xmlPtr, NULL);
    
    if (result == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to apply stylesheet" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotApplyStylesheet userInfo:errorDetail];
        return nil;
    }

    return [[XSLTResult alloc] initWithDoc:result stylesheet:stylesheet];
}

@end

@implementation XSLTResult

- (instancetype)init {
    if ((self = [super init])) {
        _freeWhenDone = YES;
    }
    return self;
}

- (instancetype)initWithDoc:(xmlDocPtr)doc stylesheet:(xsltStylesheetPtr)stylesheet {
    if ((self = [self init])) {
        _doc = doc;
        _stylesheet = stylesheet;
    }
    return self;
}

- (NSData *)data {
    xmlChar *xmlResultBuffer = NULL;
    int length = 0;
    xsltSaveResultToString(&xmlResultBuffer, &length, self.doc, self.stylesheet);

    if (xmlResultBuffer == NULL) {
        return nil;
    }

    return [NSData dataWithBytesNoCopy:xmlResultBuffer length:length freeWhenDone:YES];
}

- (void)dealloc {
    if (self.freeWhenDone) {
        xmlFreeDoc(self.doc);
        xsltFreeStylesheet(self.stylesheet);
    }
}

@end
