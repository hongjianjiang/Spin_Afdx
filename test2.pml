#define timer byte
#define set(tmr,val) (tmr=val)
#define expire(tmr)(tmr==0)
#define tick(tmr) if :: tmr>0 -> tmr = tmr-1 ::else fi
#define delay(tmr,x) set (tmr,x);expire(tmr)
#define udelay(tmr) do ::delay(tmr,1) ::break od
byte tmr1=10,tmr2=11;
active proctype Timers()
{
    do 
        ::timeout -> atomic{tick(tmr1);tick(tmr2)}
    od
}
