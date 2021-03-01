//
//  filtfilt.hpp
//  SwiftCPPTest
//
//  Created by User on 1/3/21.
//

#ifndef filtfilt_hpp
#define filtfilt_hpp

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <list>
#include <err.h>
#include <errno.h>
#include <strings.h>



    typedef std::vector<int> vectori;
    typedef std::vector<double> vectord;

    void add_index_range(vectori &indices, int beg, int end, int inc = 1);
    void add_index_const(vectori &indices, int value, size_t numel);
    void append_vector(vectord &vec, const vectord &tail);
    vectord subvector_reverse(const vectord &vec, int idx_end, int idx_start);
    inline int max_val(const vectori& vec);
    void filter(vectord B, vectord A, const vectord &X, vectord &Y, vectord &Zi);
    void filtfilt(vectord B, vectord A, const vectord &X, vectord &Y);
    double *filter_zero_phase(double *input, int n, double *aCoeffs, int na, double *bCoeffs, int nb);

#endif /* filtfilt_hpp */
