show int temp1;
show int temp2;
proctype A()
{
    temp1=0;
    temp1=temp1+1;
    temp1=2*temp1;
}
proctype B()
{
    temp2=0;
    temp2=temp2+1;
    temp2=2*temp2;
}
init {run A();run B();}