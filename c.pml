int q;
c_code { int *p; };
init {
	c_code { *p = 0; *p++; };
	c_code [p != 0] { *p = &(now.q); };
	c_code { Printf("%d\n", Pinit->_pid); }
}