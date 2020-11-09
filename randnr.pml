active proctype randnr()
{	
	byte nr;	/* pick random value  */
	do
	:: nr<255->nr++		/* randomly increment */
	:: nr>0->nr--		/* or decrement       */
	:: break	/* or stop            */
	od;
	printf("nr: %d\n",nr)	/* nr: 0..255 */
}
