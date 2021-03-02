//
//  convolve.c
//  diplomaThesis
//
//  Created by User on 2/3/21.
//

#include "convolve.h"

// filename convolve.c
#include "convolve.h"

double* convolve(double *h, double *x, int lenH, int lenX, int* lenY)
{
  int nconv = lenH+lenX-1;
  (*lenY) = nconv;
  int i,j,h_start,x_start,x_end;
  double *y = (double*) calloc(nconv, sizeof(double));

  for (i=0; i<nconv; i++)
  {
    x_start = MAX(0,i-lenH+1);
    x_end   = MIN(i+1,lenX);
    h_start = MIN(i,lenH-1);
    for(j=x_start; j<x_end; j++)
    {
      y[i] += h[h_start--]*x[j];
    }
  }
  return y;
}
