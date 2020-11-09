c_code{
\#include <stdio.h>
\#include <stdlib.h>
\#include <time.h>
}
int q;
init{
    c_code{srand((unsigned int)time(0));int num = rand() % 255 + 1;now.q=num;printf("%d\n",now.p);}
    printf("%d\n",q)
}