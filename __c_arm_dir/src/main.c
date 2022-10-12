int main();

/*
 * This method is a clean exit.
 */
void _exit(int exit_code) {
	__asm("MOV r7, #1");
	__asm("MOV r0, #0");
	__asm("svc #0");

	// to 'assure' the no return of the func
	while(1) ;
}

/*
 * This method is a clean start, it just calls the main function.
 */
void _start() {
	_exit(main());
}

/* ##################################################################################
 * ##################################################################################
   ##################################################################################*/

/*
 * Actual starting function.
 */
int main() {
	return 0;
}