#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#define ARGUMENTS_NEEDED 2
#define CURRENT_VERSION "0.104"
#define VERSION_OPTION_ONE "-v"
#define VERSION_OPTION_TWO "--version"
#define HELP_OPTION_ONE "-h"
#define HELP_OPTION_TWO "--help"
#define ERROR_ODD_NUM_MATRICES 1
#define ERROR_NOT_MATCHING_ROWCOL 2

//Llamar al programa de la forma:
// cat algun.txt | tp0

float* readLine(char buf[], int *rowFirst, int *columnsFirst);

int main(int argc, char *argv[]) {

	//Primera idea
	//Que sólo funcione con alguna de las siguientes formas
	// ./tp0 -h ó ./tp0 --help para que se le muestre algún tipo de ayuda
	// ./tp0 -v ó ./tp0 --version para que se le muestre la versión del programa, más humo que raider y smoke juntos
	// ./tp0 file para que se le diga donde está ese archivo *.txt para que revise los numeritos que tenga adentro y haga su magia

	//Como sólo le vamos a dejar eso, si argc es distinto de cero ya decimos que está mal y le mostramos como usarlo
	if (argc > 1) {
		if (!strcmp(argv[1], VERSION_OPTION_ONE)
				|| !strcmp(argv[1], VERSION_OPTION_TWO)) {
			printf("Versión "CURRENT_VERSION"\n");
			return 0;
		}
	}

	else {
		//Una vez que se llego acá empiezo a ver las matrices que me vienen del cat con el siguiente formato:
		//2x3 2 3 4 5 6.1 
		//Me van a venir de a pares, así que tendré que verificar

		//Sacado de: http://stackoverflow.com/questions/16163154/read-from-pipe-line-by-line-in-c
		//ACA SI FALLA CUANDO LAS COSAS SON MUY GRANDES CAMBIAR EL VALOR DE BUFSIZ
		char buf[BUFSIZ];

		//TODO delete this line, is only for debug
		FILE *fp = fopen("in.txt", "r");
		int firstRow, firstColumn, secondRow, secondColumn;

		while (fgets(buf, sizeof buf, fp) != NULL) {

			//read first line
			float *valuesFirst = readLine(&buf, &firstRow, &firstColumn);

			if (fgets(buf, sizeof buf, fp) == NULL) {
				//Si pasa esto, es porque no me vienen de a pares las matrices, es un error y lo reporto
				printf("Abortando, txt con cantidad de matrices impares.\n");
				return ERROR_ODD_NUM_MATRICES;
			} else {

				//read second line
				float *valuesSecond = readLine(&buf, &secondRow, &secondColumn);

				//Verifico que las columnas del primero sean iguales a las filas del segundo
				if (firstColumn != secondRow) {
					free(valuesFirst);
					printf("\nColumnas del primero: %d\nFilas del segundo: %d\nIncompatibles, abortando...\n\n",
							firstColumn, secondRow);
					return ERROR_NOT_MATCHING_ROWCOL;
				}
				//Ahora que tengo todo, se viene el momento de mostrar el resultado
//				printf("%dx%d", rowsFirst, columnsSecond);

				int f = 0;
				int s = 0;
				int totCol = 0;
				int totRow = 0;
				float partialResult = 0.0f;

				for (totRow = 0; totRow < firstRow * firstColumn;) {
					for (totCol = 0; totCol < secondColumn;) {
						while (s <= (secondRow * secondColumn - 1)) {
							partialResult += valuesFirst[f] * valuesSecond[s];
							//printf ("\n\nWASD: %f\n\n",partialResult);
							f++;
							s += secondColumn;
						}
						printf(" %.2f", partialResult);
						partialResult = 0.0f;
						totCol++;
						f = totRow;
						s = totCol;
					}
					totRow += firstColumn;
					f = totRow;
					s = 0;
				}
				printf("\n");

				free(valuesFirst);
				free(valuesSecond);
			}
		}
	}

	return 0;
}


float* readLine(char *buf, int *firstRow, int *firstColumn) {

	char* token = strtok(buf, "\n");	//Elimino la posibilidad que esté
	token = strtok(buf, "x");

	*firstRow = atoi(token);

	token = strtok(NULL, " ");

	*firstColumn = atoi(token);

	float* values = malloc((*firstRow) * (*firstColumn) * sizeof(float));//Acordarse del free
	int counter = 0;
	while (token = strtok(NULL, " ")) {
		values[counter] = atof(token);
		counter++;
	}
	printf("\n");
	return values;

}

