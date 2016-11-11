/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1995, 1996  Robert Gentleman and Ross Ihaka
 *  Copyright (C) 1998-2016   The R Core Team
 *  Copyright (C) 2002, 2004  The R Foundation
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
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 *
 *  This script is a modification of r-source/src/library/stats/src/distance.c
 *  from https://github.com/wch/r-source by Thomas Guillerme (guillert@tcd.ie)
 */

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <float.h>

#include <R.h>
#include <Rmath.h>
#ifdef _OPENMP
# include <R_ext/MathThreads.h>
#endif

#define both_FINITE(a,b) (R_FINITE(a) && R_FINITE(b))
#ifdef R_160_and_older
#define both_non_NA both_FINITE
#else
#define both_non_NA(a,b) (!ISNAN(a) && !ISNAN(b))
#endif

// Calculating the Gower character distance
static double R_Gower(double *x, int nr, int nc, int i1, int i2)
{
    double diff, dist;
    int count, j;
    
    //Initialise the values
    count= 0;
    dist = 0;
    //Loop through the differences
    printf("Count differences:\n");

    // Normalise character here?

    for(j = 0 ; j < nc ; j++) {
        if(both_non_NA(x[i1], x[i2])) {
            printf("i1 = %f - i2 = %f\n", x[i1], x[i2]);
            //Count the absolute difference
            diff = fabs(x[i1] - x[i2]);
            //Normalise the difference (Fitch like)
            if(diff > 1) {
                diff = 1;
            }
            //Cumulate the differences
            if(!ISNAN(diff)) {
                dist += diff;
            }
            //Increment the counter
            count++;
        }
        i1 += nr;
        i2 += nr;
    }
    if(count == 0) {
        return NA_REAL;
    } else {
        dist = dist/count;
        printf("Distance = %f\n", dist);
        return dist;
    }
}


// Convert character into number
double character_to_numeric(char c)
{
    double n = -1;
    static const char * const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    char *p = strchr(alphabet, (unsigned char)c);

    if (p) {
        n = p - alphabet;
    }

    return n;
}


// Calculating the Gower character distance
static double Normalise_characters(double *x, int nr, int nc, int i1, int i2)
{
    double diff, dist, vector1[nc], vector2[nc], normalised_char[nc*2];
    int count, i, j, k, element;
    char vector_char1[nc], vector_char2[nc], element_char;
    char alphabet[] = { 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','\0'};

    //Initialise the values
    count= 0;
    dist = 0;

    //Isolating the two comparable characters
    printf("\n");
    for(j = 0 ; j < nc ; j++) {
        if(both_non_NA(x[i1], x[i2])) {
            printf("c1 = %f - c2 = %f\n", x[i1], x[i2]);
            
            // Create the vectors
            vector1[count] = x[i1];
            vector2[count] = x[i2];

            //Increment the counter
            count++;
        }
        i1 += nr;
        i2 += nr;
    }

    // Getting each unique element of the vector and translating them into standardised characters
    element = 0;

    for (i = 0; i < count; ++i) {
        for (j = 0; j < i; ++j) {
            if (vector1[i] == vector1[j])
               break;
        }

        if (i == j) {
            // If encountering unique characters, attribute the first letter of the alphabet and so on
            element_char = alphabet[element];
            printf("Converting the value %f into %c;\n", vector1[i], element_char);
            for(k = 0; k < count; k++) {
                if(vector1[k] == vector1[i]) {
                    vector_char1[k] = element_char;
                    printf("Position %i (value %f) -> %c.\n", k, vector1[k], element_char);
                }
            }
            element ++;
        }
    }

    printf("Resulting in vector:\n");
    for(k = 0; k < count ; k++) {
        printf("%c ", vector_char1[k]);
    }

    // Transforming the character back to numeric (double)
    printf("Reconverting to numeric:\n");
    for(k = 0; k < count ; k++) {
        vector1[k] = character_to_numeric(vector_char1[k]);
    }

    printf("Resulting in vector:\n");
    for(k = 0; k < count ; k++) {
        printf("%f ", vector1[k]);
    }


    printf("\n");


    // Logic for combining the two vectors (and handle a single output)

    // //Combine the vectors
    // printf("Making a single vector");
    // for(k = 0; k < count; k++) {
    //     normalised_char[k] = vector1[k]; // Creating a single vector
    // }
    // printf(" of %i elements", k);
    // for(k = count; k < count*2; k++) {
    //     normalised_char[k] = vector2[k-count]; // Adding the next vector to it
    // }

    // Logic for differentiating the two vectors

    // // Printing the two vectors
    // printf("\nThe two vectors are:\n");
    // for(k = 0; k < count ; k++) {
    //     printf("%f ", normalised_char[k]);
    // }
    // printf("\nAnd \n");
    // for(k = count; k < count*2 ; k++) {
    //     printf("%f ", normalised_char[k]);
    // }
    // printf("\n");

    return dist;
}


enum { GOWER=1};
/* == 1,2,..., defined by order in the R function dist */

void R_distance(double *x, int *nr, int *nc, double *d, int *diag, int *method)
{
    int dc, i, j;
    size_t  ij;  /* can exceed 2^31 - 1 */
    double (*distfun)(double*, int, int, int, int) = NULL;

    //Open MPI
#ifdef _OPENMP
    int nthreads;
#endif
    distfun = Normalise_characters;

    dc = (*diag) ? 0 : 1; /* diag=1:  we do the diagonal */

#ifdef _OPENMP
    if (R_num_math_threads > 0)
    nthreads = R_num_math_threads;
    else
    nthreads = 1; /* for now */
    if (nthreads == 1) {
    /* do the nthreads == 1 case without any OMP overhead to see
       if it matters on some platforms */
    ij = 0;
    for(j = 0 ; j <= *nr ; j++)
        for(i = j+dc ; i < *nr ; i++)
        d[ij++] = distfun(x, *nr, *nc, i, j);
    }
    else
    /* This produces uneven thread workloads since the outer loop
       is over the subdiagonal portions of columns.  An
       alternative would be to use a loop on ij and to compute the
       i and j values from ij. */
#pragma omp parallel for num_threads(nthreads) default(none)    \
    private(i, j, ij)                       \
    firstprivate(nr, dc, d, method, distfun, nc, x)
    for(j = 0 ; j <= *nr ; j++) {
        ij = j * (*nr - dc) + j - ((1 + j) * j) / 2;
        for(i = j+dc ; i < *nr ; i++)
        d[ij++] = distfun(x, *nr, *nc, i, j);
    }
#else
    ij = 0;
    for(j = 0 ; j <= *nr ; j++)
    for(i = j+dc ; i < *nr ; i++)
        d[ij++] = distfun(x, *nr, *nc, i, j);
#endif
}

#include <Rinternals.h>

SEXP CharDiff(SEXP x, SEXP smethod, SEXP attrs)
{
    SEXP ans;
    int nr = nrows(x), nc = ncols(x), method = asInteger(smethod);
    int diag = 0;
    R_xlen_t N;
    N = (R_xlen_t)nr * (nr-1)/2; /* avoid int overflow for N ~ 50,000 */
    PROTECT(ans = allocVector(REALSXP, N));
    if(TYPEOF(x) != REALSXP) x = coerceVector(x, REALSXP);
    PROTECT(x);
    R_distance(REAL(x), &nr, &nc, REAL(ans), &diag, &method);
    /* tack on attributes */
    SEXP names = getAttrib(attrs, R_NamesSymbol);
    for (int i = 0; i < LENGTH(attrs); i++)
    setAttrib(ans, install(translateChar(STRING_ELT(names, i))),
          VECTOR_ELT(attrs, i));
    UNPROTECT(2);
    return ans;
}
