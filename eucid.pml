active proctype Euclid(int x,y)
{
    do
        ::(x>y)->x=x-y
        ::(x==y)->goto done 
    od
    done:skip
}
