proctype testcount(byte x)
{
    do
        :: (x != 0 ) ->
            if
                :: x ++
                :: x --
                :: break
            fi
        :: else -> break
    od;
    printf("counter = %d\n", x);
}

init {
    run testcount(1)
}

ltl larger_or_equal { [] (testcount[1]:x >= 0) };
ltl strictly_larger { [] (testcount[1]:x > 0) };