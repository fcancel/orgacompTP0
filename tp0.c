#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>

#define ARGUMENTS_NEEDED 2
#define CURRENT_VERSION "1.0"
#define VERSION_OPTION_ONE "-v"
#define VERSION_OPTION_TWO "--version"
#define HELP_OPTION_ONE "-h"
#define HELP_OPTION_TWO "--help"
#define WHITE_SPACE " "
#define ERROR_ODD_NUM_MATRICES 1
#define ERROR_NOT_MATCHING_ROWCOL 2
#define ERROR_NOT_MATCHING_ELEMENTS 3
#define BLOCKSIZE 1024

/**
 * parses line by tokens
 * return a pointer with all values
 */
double* parseLine( char buf[], int *row, int *column, int *counter );

/**
 * show message with help menu or current version
 */
int showMessage( char *arg );

/**
 * validates that can do the multiplication between matrices
 */
bool areCompatible( int firstColumn, int secondRow);

/**
 * validates if the line have the number of elements expected
 */
bool haveCorrectNumberOfElements(int numberElementsExpected, int counter);

/**
 * used to get an arbitrary line of text
 */
char *getWholeLine(FILE * fp);

/**
 * MIPS function used to multiply matrices passed on firstValues and secondValues
 */
extern void multiplyMatrices(int secondRow, int secondColumn, double * firstValues, double * secondValues, double * multipliedMatrix, int firstRow, int firstColumn);

int main(int argc, char *argv[]) {

	if ( argc > 1 ) {
		if (showMessage( argv[1] ) < 0) return -1;
	}
	else {

		char * buf;

		int counter;

		int firstRow, firstColumn, secondRow, secondColumn;

		while ( (buf = getWholeLine(stdin)) != NULL ) {

			//parse first line
			double *firstValues = parseLine( buf, &firstRow, &firstColumn, &counter );

			if (!haveCorrectNumberOfElements( firstRow * firstColumn, counter)) {
				fprintf( stderr, "ERROR: invalid number of elements in the line. %dx%d must contain %d elements\n",
						firstRow, firstColumn, (firstRow) * (firstColumn) );
				free(firstValues);
				return ERROR_NOT_MATCHING_ELEMENTS;
			}

			if ( (buf = getWholeLine(stdin)) == NULL ){
			    fprintf(stderr, "ERROR: input file with invalid number of matrices.\n");
			    free(buf);
			    free(firstValues);
			    return ERROR_ODD_NUM_MATRICES;

			} else {

				//read second line
				double *secondValues = parseLine( buf, &secondRow, &secondColumn, &counter );

				if (!haveCorrectNumberOfElements( secondRow * secondColumn, counter )) {
					fprintf( stderr, "ERROR: invalid number of elements in the line. %dx%d must contain %d elements\n",
							secondRow, secondColumn, (secondRow) * (secondColumn) );
					free(firstValues);
					free(secondValues);
					free(buf);
					return ERROR_NOT_MATCHING_ELEMENTS;
				}


				//validate if matrices are compatible for multiplication
				if ( !areCompatible(firstColumn, secondRow) ) {
					free( firstValues );
					return ERROR_NOT_MATCHING_ROWCOL;
				}
				
				//Creo aca la matriz con todos los resultados
				double *multipliedMatrix = malloc( firstRow * secondColumn * sizeof(double) );

				//multiply matrices
				multiplyMatrices(secondRow, secondColumn, firstValues, secondValues, multipliedMatrix, firstRow, firstColumn);

				if ( printf("%dx%d", firstRow, secondColumn) < 0 ){
					fprintf(stderr, "Error while printing to output file.\n");
					return -1;
				}

				int contadorMatriz;
				for(contadorMatriz = 0; contadorMatriz < (firstRow * secondColumn); contadorMatriz++){
					if( printf(" %.2f", multipliedMatrix[contadorMatriz]) < 0){
						fprintf(stderr, "Error while printing to output file.\n");
						return -1;						
					}
				}
				if ( printf( "\n" ) < 0 ){
					fprintf(stderr, "Error while printing to output file.\n");
					return -1;
				}
				free( multipliedMatrix );
				free( firstValues );
				free( secondValues );
			}
		}
		free(buf);
	}

	return 0;
}


double* parseLine( char *buf, int *row, int *column, int *counter ) {

	//complete line
	char* token = strtok( buf, "\n" );

	//parsing row
	token = strtok( buf, "x") ;
	*row = atoi( token );

	//parsing column
	token = strtok( NULL, WHITE_SPACE );
	*column = atoi( token );

	double *values = malloc( (*row) * (*column) * sizeof(double) );

	*counter = 0;
	while ( (token = strtok(NULL, WHITE_SPACE)) ) {
		values[*counter] = atof( token );
		(*counter) = (*counter) +1;
	}
	return values;

}


int showMessage( char *arg ){

	if ( (strcmp(arg, VERSION_OPTION_ONE) == 0) || (strcmp(arg, VERSION_OPTION_TWO) == 0) ){

		if (printf ( "Current version: %s\n", CURRENT_VERSION ) < 0 ){
			fprintf(stderr, "Error while printing to output file.\n");
			return -1;		
		}

	} else {

		if ( printf( "Usage: \n"
				"tp1 -h \ntp1 -V \ntp1 < in_file > out_file\n"
				"Options: \n"
				"-V, --version \n-h, --help\n"
				"Examples: \n"
				"tp1 < in.txt > out.txt\n"
				"cat in.txt | tp1 > out.txt\n" ) < 0 ){
					fprintf(stderr, "Error while printing to output file.\n");
					return -1;
				}

	}

	return 0;

}


bool areCompatible( int firstColumn, int secondRow ) {

	if ( firstColumn == secondRow )
		return true;
	else {
		if (fprintf( stderr, "ERROR: first column: %d and second row: %d must be equals\n",
				firstColumn, secondRow ) < 0 ) return -1;
		return false;
	}
}

bool haveCorrectNumberOfElements(int numberElementsExpected, int counter){
	return ( counter == numberElementsExpected );
}

//sacado de http://stackoverflow.com/questions/12167946/how-do-i-read-an-arbitrarily-long-line-in-c

char *getWholeLine(FILE *fp) {
    char    *line = NULL;
    size_t  maxlength = 0;
    assert(fp != NULL);
    for(;;) { // Read the line in BLOCKSIZE -blocks.
        char *crlf, *block;

        maxlength += BLOCKSIZE;
        // This exploits realloc behaviour upon hitting NULL
        if (NULL == (line = realloc(line, maxlength+1))) {
            break; // realloc error returns NULL.
        }
        block = line + maxlength - BLOCKSIZE;
        // BLOCKSIZE+1 to accommodate final zero
        if (NULL == fgets(block, BLOCKSIZE+1, fp)) {
            // TODO: rewind fp in case of error.
            if (block == line) {
                    // Error.
                    free(line); line = NULL;
            }
            break;
        }
        // This was the last block iff we find a CRLF inside.
        if (NULL != (crlf = strchr(block, '\n'))) {
            *crlf = 0x0;
            if (crlf != block) {
                if ('\r' == *(--crlf))
                    *crlf = 0x0;
            }
            break;
        } /* if */
    } /* for */
    return line;
}
