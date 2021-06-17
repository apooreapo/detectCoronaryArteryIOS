//
//  HelloWorldWrapper.m
//  SwiftCPPTest
//
//  Created by Apostolou Orestis on 23/2/21.
//
//  This file is necessary for using C++ files on a Swift project.

#import <Foundation/Foundation.h>
#import "filtfiltWrapper.h"
#import "filtfilt.hpp"

@implementation filtfiltWrapper

- (int)printNumber {
    return 3;
}

- (double *) filterfilter:(double *)input n:(int)n aCoeffs:(double *)aCoeffs na:(int)na bCoeffs:(double *)bCoeffs nb:(int)nb normalize:(int)normalize {
    double *output = (double*) malloc(20 * sizeof(double));
    output = filter_zero_phase(input, n, aCoeffs, na, bCoeffs, nb, normalize);
    return output;
}


@end
