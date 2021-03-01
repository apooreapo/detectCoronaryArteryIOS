//
//  HelloWorldWrapper.m
//  SwiftCPPTest
//
//  Created by User on 23/2/21.
//

#import <Foundation/Foundation.h>
#import "filtfiltWrapper.h"
#import "filtfilt.hpp"

@implementation filtfiltWrapper

- (int)printNumber {
    return 3;
}

- (double *) filterfilter:(double *)input n:(int)n aCoeffs:(double *)aCoeffs na:(int)na bCoeffs:(double *)bCoeffs nb:(int)nb {
    double *output = (double*) malloc(20 * sizeof(double));
    output = filter_zero_phase(input, n, aCoeffs, na, bCoeffs, nb);
    return output;
}


@end
