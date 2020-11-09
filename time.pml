#define timer byte 
#define set(tmr,val) tmr = val
#define expire(tmr) tmr == 0 
#define tick(tmr) if :: tmr >0 -> tmr = tmr-1 :: else fi 
#define delay(tmr,x) set(tmr,x);expire(tmr)
#define udelay(tmr) do ::delay(tmr,1) :: break od 
timer tmr1,tmr2;
timer jitter;
bool reset;
inline randomjitter()
{
    if
    ::set(jitter,1)
    ::set(jitter,2)
    ::set(jitter,3)
    fi
}
inline randomreset()
{
    if
    ::set(reset,1)
    ::set(reset,0)
    fi
}
active proctype SetTest()
{   
    randomreset();
    assert(reset == 1 || reset == 0 )
}

proctype Timers()
{
    do
    :: timeout -> atomic{tick(tmr1);tick(tmr2)}
    od
}
