/*
 *                            COPYRIGHT
 *
 *  bwbp - Butterworth bandpass filter coefficient calculator
 *  Copyright (C) 2003, 2004, 2005, 2006 Exstrom Laboratories LLC
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  A copy of the GNU General Public License is available on the internet at:
 *
 *  http://www.gnu.org/copyleft/gpl.html
 *
 *  or you can write to:
 *
 *  The Free Software Foundation, Inc.
 *  675 Mass Ave
 *  Cambridge, MA 02139, USA
 *
 *  You can contact Exstrom Laboratories LLC via Email at:
 *
 *  info(AT)exstrom.com
 *
 *  or you can write to:
 *
 *  Exstrom Laboratories LLC
 *  P.O. Box 7651
 *  Longmont, CO 80501, USA
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "liir.h"
#include "bwbp.h"

double *bwbpCoeffs(int n, int sff, double f1f, double f2f)
{
    int i;            // loop variables
    double sf;        // scaling factor
    double *dcof;     // d coefficients
    int *ccof;        // c coefficients
    double *result;   // returns the result. first the c coeffs, and then the d
    result = (double*) malloc((4*n+2) * sizeof(double));

//    if( argc < 6 )
//    {
//    printf("\nbwbp calculates Butterworth bandpass filter coefficients\n");
//    printf("\nUsage: bwbp n fc1 fc2 sf outfile\n");
//    printf("  n = order of the filter\n");
//    printf("  fc1 = lower cutoff frequency as a fraction of Pi [0,1]\n");
//    printf("  fc2 = upper cutoff frequency as a fraction of Pi [0,1]\n");
//        printf("  sf = 1 to scale c coefficients for normalized response\n");
//        printf("  sf = 0 to not scale c coefficients\n");
//    printf("  outfile = output file name\n");
//    return(-1);
//    }

//    n = atoi( argv[1] );
//    f1f = atof( argv[2] );
//    f2f = atof( argv[3] );
//    sff = atoi( argv[4] );

    /* calculate the d coefficients */
    dcof = dcof_bwbp( n, f1f, f2f );
    if( dcof == NULL )
    {
        perror( "Unable to calculate d coefficients" );
    }

    /* calculate the c coefficients */
    ccof = ccof_bwbp( n );
    if( ccof == NULL )
    {
        perror( "Unable to calculate c coefficients" );
    }

    sf = sf_bwbp( n, f1f, f2f ); /* scaling factor for the c coefficients */

    /* create the filter coefficient file */

    /* Output the file header */
    printf("# Butterworth bandpass filter coefficients.\n" );
    printf("# Produced by bwbp.\n" );
    printf("# Filter order: %d\n", n );
    printf("# Lower cutoff freq.: %1.15lf\n", f1f );
    printf("# Upper cutoff freq.: %1.15lf\n", f2f );
    printf("# Scaling factor: %1.15lf\n", sf );

    /* Output the c coefficients */
    printf("%d\n", 2*n+1 );    // number of c coefficients
    if( sff == 0 )
        for( i = 0; i <= 2*n; ++i) {
            result[i] = (double)ccof[i];
        }
        
    else
        for( i = 0; i <= 2*n; ++i) {
            result[i] = (double)ccof[i]*sf;
        }

    /* Output the d coefficients */
//    printf("%d\n", 2*n+1 );  /* number of d coefficients */
    for( i = 0; i <= 2*n; ++i ){
        result[i + 2*n + 1] = dcof[i];
    }
    
    return result;
//
//    fclose( fp );
//    free( dcof );
//    free( ccof );
}
