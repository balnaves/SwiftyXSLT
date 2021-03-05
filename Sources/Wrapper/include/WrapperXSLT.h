//
//  WrapperXSLT.h
//  
//
//  Created by James Balnaves on 3/4/21.
//
#import <Foundation/Foundation.h>

#ifndef Wrapper_h
#define Wrapper_h

@interface WrapperXSLT : NSObject

+(NSString *) transformXML:(NSString *)xmlString withStyleSheet:(NSString *)styleString;

@end


#endif /* Wrapper_h */
