#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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


int main(int argc, char *argv[]) {

	if ( argc > 1 ) {
		showMessage( argv[1] );
	}
	else {

		char buf[BUFSIZ*2];

		int counter;

		int firstRow, firstColumn, secondRow, secondColumn;

		while ( fgets(buf, sizeof buf, stdin) != NULL ) {

			//parse first line
			double *firstValues = parseLine( buf, &firstRow, &firstColumn, &counter );

			if (!haveCorrectNumberOfElements( firstRow * firstColumn, counter)) {
				fprintf( stderr, "ERROR: invalid number of elements in the line. %dx%d must contains %d elements\n",
						firstRow, firstColumn, (firstRow) * (firstColumn) );
				return ERROR_NOT_MATCHING_ELEMENTS;
			}

			if ( fgets(buf, sizeof buf, stdin) == NULL ){
			    fprintf(stderr, "ERROR: input file with invalid number of matrices.\n");
			    return ERROR_ODD_NUM_MATRICES;

			} else {

				//read second line
				double *secondValues = parseLine( buf, &secondRow, &secondColumn, &counter );

				if (!haveCorrectNumberOfElements( secondRow * secondColumn, counter )) {
					fprintf( stderr, "ERROR: invalid number of elements in the line. %dx%d must contains %d elements\n",
							secondRow, secondColumn, (secondRow) * (secondColumn) );
					return ERROR_NOT_MATCHING_ELEMENTS;
				}


				//validate if matrices are compatible for multiplication
				if ( !areCompatible(firstColumn, secondRow) ) {
					free( firstValues );
					return ERROR_NOT_MATCHING_ROWCOL;
				}

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

				free( firstValues );
				free( secondValues );
			}
		}
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

	//printf( "\n" );
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

