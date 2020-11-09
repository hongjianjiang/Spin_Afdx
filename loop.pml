chan c = [5] of {int}
active proctype Reliable() {
    int i;
    int r ;
    for (i:0..4) {c!i}
}

