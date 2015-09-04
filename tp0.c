#include <stdio.h>
#include <string.h>
#include <ctype.h>
#define ARGUMENTS_NEEDED 2
#define CURRENT_VERSION "0.101"
#define VERSION_OPTION_ONE "-v"
#define VERSION_OPTION_TWO "--version"
#define HELP_OPTION_ONE "-h"
#define HELP_OPTION_TWO "--help"

int main (int argc, char *argv[]) {
	
	//Primera idea
	//Que sólo funcione con alguna de las siguientes formas
	// ./tp0 -h ó ./tp0 --help para que se le muestre algún tipo de ayuda
	// ./tp0 -v ó ./tp0 --version para que se le muestre la versión del programa, más humo que raider y smoke juntos
	// ./tp0 file para que se le diga donde está ese archivo *.txt para que revise los numeritos que tenga adentro y haga su magia

	//Como sólo le vamos a dejar eso, si argc es distinto de cero ya decimos que está mal y le mostramos como usarlo

	if (argc == ARGUMENTS_NEEDED){

		//esto es para que el usuario escriba como quiera escribir con los cases
		char *loweredOption = argv[ARGUMENTS_NEEDED - 1];
		int i = 0;	//Porque si no lo declaro antes, el compilador se vuelve loco
		for(i = 0; loweredOption[i]; i++){
			loweredOption[i] = tolower(loweredOption[i]);
		}


		if (!strcmp(loweredOption,VERSION_OPTION_ONE) || !strcmp(loweredOption,VERSION_OPTION_TWO)){
			printf ("Versión "CURRENT_VERSION"\n");
		}
		
	}
	else {
		printf("\nPara utilizar correctamente el comando, indique como primer argumento un archivo de texto.\n");
	}

	return 0;
}