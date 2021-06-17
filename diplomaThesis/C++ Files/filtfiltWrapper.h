//
//  filtfiltWrapper.h
//  SwiftCPPTest
//
//  Created by Apostolou Orestis on 23/2/21.
//
//  This file is necessary for using C++ files on a Swift project.

#ifndef filtfiltWrapper_h
#define filtfiltWrapper_h

#import <Foundation/Foundation.h>

@interface filtfiltWrapper : NSObject

- (int) printNumber;
- (double *) filterfilter:(double *)input n:(int)n aCoeffs:(double *)aCoeffs na:(int)na bCoeffs:(double *)bCoeffs nb:(int)nb normalize:(int)normalize;

@end


#endif /* filtfiltWrapper_h */
