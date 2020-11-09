#define MAX 10
mtype = {ack,nak,err,next,accept};
proctype transfer(chan in , out , chin, chout){
    byte o,i;
    in?next(0);
    do
    ::chin?nak(i)->out!accept(i);chout!ack(0)
    ::chin?ack(i)->out!accept(i);in?next(o);chout!ack(0)
    ::chin?err(i)->chout!nak(0)
    od
}
proctype application (chan in,out)
{
    int i=0 , j=0,last_i =0;
    do 
        :: in?accept(i)->assert(i==last_i);
            if 
                ::(last_i!=MAX)->last_i = last_i+1
                ::(last_i ==MAX)
            fi
        :: out!next(j)->
            if 
                ::(j!=MAX) -> j = j+1
                ::(j==MAX)
            fi
    od
}
init
{
    chan AtoB = [1] of {mtype,byte};
    chan BtoA = [1] of {mtype,byte};
    chan Ain = [2] of {mtype,byte};
    chan Bin = [2] of {mtype,byte};
    chan Aout = [2] of {mtype,byte};
    chan Bout = [2] of {mtype,byte};
    atomic{
        run application(Ain,Aout);
        run transfer(Aout,Ain,BtoA,AtoB);
        run transfer(Bout,Bin,AtoB,BtoA);
        run application(Bin,Bout)
    };
    AtoB!err(0)
}
