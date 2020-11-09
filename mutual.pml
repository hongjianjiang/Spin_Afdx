bit p,v;
byte mutex,turn;

active proctype A()
{
    p=1;
    turn=2;
    v==0||turn==1;
    mutex++;
    mutex--;
    p=0;
}
active proctype B()
{
    v=1;
    turn=1;
    p==0||turn==2;
    mutex++;
    mutex--;
    v=0;
}
active proctype monitor()
{
    assert (mutex!=2)
}