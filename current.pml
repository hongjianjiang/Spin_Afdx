byte state = 1 ; 
active proctype A() {(state == 1 )-> state = state+1}
active proctype B() {(state == 1 )-> state = state-1}

