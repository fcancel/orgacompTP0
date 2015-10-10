#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

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
void showMessage( char *arg );

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

void multiplyMatrices(int firstRow, int firstColumn, int secondRow, int secondColumn, double * firstValues, double * secondValues);

int main(int argc, char *argv[]) {

	if ( argc > 1 ) {
		showMessage( argv[1] );
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

				multiplyMatrices(firstRow, firstColumn, secondRow, secondColumn, firstValues, secondValues);

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


void showMessage( char *arg ){

	if ( (strcmp(arg, VERSION_OPTION_ONE) == 0) || (strcmp(arg, VERSION_OPTION_TWO) == 0) ){

		printf ( "Current version: %s\n", CURRENT_VERSION );

	} else {

		printf( "Usage: \n" );
		printf( "tp0 -h \ntp0 -V \ntp0 < in_file > out_file\n" );
		printf( "Options: \n" );
		printf( "-V, --version \n-h, --help\n" );
		printf( "Examples: \n" );
		printf( "tp0 < in.txt > out.txt\n" );
		printf( "cat in.txt | tp0 > out.txt\n" );

	}

}


bool areCompatible( int firstColumn, int secondRow ) {

	if ( firstColumn == secondRow )
		return true;
	else {
		fprintf( stderr, "ERROR: first column: %d and second row: %d must be equals\n",
				firstColumn, secondRow );
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

void multiplyMatrices (int firstRow, int firstColumn, int secondRow, int secondColumn, double * firstValues, double * secondValues){
		//multiply matrices
	int f = 0;
	int s = 0;
	int totCol = 0;
	int totRow = 0;
	double partialResult = 0.0f;

	printf("%dx%d", firstRow, secondColumn);
	
	for ( totRow = 0; totRow < firstRow * firstColumn; ) {
		for ( totCol = 0; totCol < secondColumn; ) {
			while ( s <= (secondRow * secondColumn - 1) ) {
				partialResult += firstValues[f] * secondValues[s];
				f++;
				s += secondColumn;
			}
			printf( " %.2f", partialResult );
			partialResult = 0.0f;
			totCol++;
			f = totRow;
			s = totCol;
		}
		totRow += firstColumn;
		f = totRow;
		s = 0;
	}
	printf( "\n" );
}