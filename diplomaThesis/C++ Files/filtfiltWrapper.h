//
//  filtfiltWrapper.h
//  SwiftCPPTest
//
//  Created by User on 23/2/21.
//

#ifndef filtfiltWrapper_h
#define filtfiltWrapper_h

#import <Foundation/Foundation.h>

@interface filtfiltWrapper : NSObject

- (int) printNumber;
- (double *) filterfilter:(double *)input n:(int)n aCoeffs:(double *)aCoeffs na:(int)na bCoeffs:(double *)bCoeffs nb:(int)nb;

@end


#endif /* filtfiltWrapper_h */
