/*time slice */
#define timer byte 
#define set(tmr,val) tmr = val
#define expire(tmr) tmr == 0 
#define tick(tmr) if :: tmr >0 -> tmr = tmr-1 :: else fi 
#define delay(tmr,x) set(tmr,x);expire(tmr)
#define udelay(tmr) do ::delay(tmr,1) :: break od 
/*other*/
#define BAG 16 // Bandwidth Allocation Gap
#define TDRF 1
#define HRD 4
#define MAXLATENCY 1
#define MINLATENCY 0
timer tmr1,tmr2; 

byte tfr;
timer bag,jitter,transmitterjitter,tdrf,resetdelay;
//transmitter part 
bool rchk; 
bool reset;
byte messagedigest;
chan channel1 = [0] of {byte,byte}; 
chan channel2 = [0] of {byte,byte}; 
byte ec1flag[256];
byte ec2flag[256];
byte rfflag[256];
//channel part
chan channelr1 = [0] of {byte};
chan channelr2 = [0] of {byte};
chan channelt1 = [0] of {byte, byte };
chan channelt2 = [0] of {byte, byte };

byte babblefrm1,babblefrm2;
bool babble1,error1,babble2,error2;
timer channeldelay1,channeldelay2,latency1,latency2;

//deliver part 
byte psnr;
byte listelement[256];
byte numoflistelements[256];

//receive part 
bool ispresentflag;
bool resetflag;
bool babblechk;
byte rfr1,rmd1;
byte rfr;
inline randomjitter(){
    if
    ::set(jitter,1)
    ::set(jitter,2)
    ::set(jitter,3)
    fi
}

inline randomreset(){
    if
    ::set(reset,1)
    ::set(reset,0)
    fi
}

inline generatemessagedigest(tfr){
    select(messagedigest:1..tfr-1)
}

inline randombabbleinchannel1(){
    if 
    :: babble1=1
    :: babble1=0
    fi
}
inline randombabbleinchannel2(){
    if 
    :: babble2=1
    :: babble2=0
    fi
}

inline randomerrorinchannel1(){
    if 
    ::error1 = 1 
    ::error1 = 0
    fi
}
inline randomerrorinchannel2(){
    if 
    ::error2 = 1 
    ::error2 = 0
    fi
}
inline randomlatencyinchannel1(){
	do
	:: latency1<=MAXLATENCY-> latency1++		/* randomly increment */
	:: latency1>=MINLATENCY-> latency1--		/* or decrement       */
	:: break	/* or stop            */
	od;
}

inline randomlatencyinchannel2(){
	do
	:: latency2<=MAXLATENCY-> latency2++		/* randomly increment */
	:: latency2>=MINLATENCY-> latency2--		/* or decrement       */
	:: break	/* or stop            */
	od;
}

inline generatebabbleframeforchannel1(){
    select(babblefrm1:0..255)
}

inline generatebabbleframeforchannel2(){
    select(babblefrm2:0..255)
}

inline deliverframe(element){
    byte j, k ;
    rfflag[element] = 1;
    psnr = element ; 
    j = 0 ;
    do
    :: psnr < 255 -> 
        if 
        :: listelement[j] == psnr + 1 -> 
            rfflag[listelement[j]] = 1 ;
            psnr = listelement[j];
            j++ ; 
        :: listelement[j] != psnr + 1 ->
            break;
        fi;
    :: psnr == 255 ->
        if 
        :: listelement == 1->
            rfflag[listelement[j]] = 1 ;
            psnr = listelement[j];
            j++;
        :: listelement[j] != 1 ->
            break;
        fi;
    od;
    k = j ;
    do 
    :: k< numoflistelements ->
        listelement[k] =listelement[k-j];
        k++;
    :: k >= numoflistelements ->
        break;
    od;
    numoflistelements = numoflistelements -j ; 
}

inline ifpresentinlist(element){
    int i;
    ispresentflag = 0;
    for (i:0..255){
        if
        ::rfflag[i]==element ->
            ispresentflag =1;
        fi;
    }
}
inline deleverframetoendsystem(element){
    deliverframe(element)
}

inline verify(rfr,cmd){
    if
    ::rfr == cmd ->babblechk =0;
    ::else -> babblechk =1;
    fi;
}
active proctype Timers(){
    do 
        ::timeout -> atomic{tick(tmr1);tick(tmr2)}
    od
}
active proctype Transmitter(){
    byte j;
    do 
    :: expire(bag) -> //once expires，new bag starts
        set(bag,BAG);
        rchk = 0;
        randomjitter();
        delay(transmitterjitter,jitter);
        randomreset();
        if
        :: reset == 0 ->
            generatemessagedigest(tfr);
            channel1!tfr,messagedigest;
            set(tdrf,TDRF);
            channel2!tfr,messagedigest;
            do
            :: expire(tdrf)->
                if
                :: tfr <255 -> tfr = tfr +1 ;
                :: else -> tfr = 1 ;
                fi;
                break;
            od;
        :: reset == 1 ->
            rchk = 1 ;
            tfr = 0 ;
            generatemessagedigest(tfr);
            channel1!tfr,messagedigest;
            set(tdrf,TDRF);
            channel2!tfr,messagedigest;
            do
            :: expire(tdrf) ->
                delay(resetdelay,HRD);
                tfr = 1 ;j = 0;
                do 
                :: j < 256 -> 
                    ec1flag[j]=0;
                    ec2flag[j]=0;
                    rfflag[j]=0;
                    j++;
                ::j==256->break;
                od;
                break;
            od;
        fi;
    od
}
active proctype Channel1 ()
{ 
    byte j;
    byte cfr1,cmd1;
    do 
    :: babble1 == 1 ->
        generatebabbleframeforchannel1();
        channelr1!babblefrm1;
        babble1=0;
    :: channelt1?cfr1,cmd1 ->
        randomerrorinchannel1();
        if 
        :: error1==0 ->
            ec1flag[cfr1]=1;
            randomlatencyinchannel1();
            delay(channeldelay1,latency1);
            channelr1!cfr1,cmd1;
        :: error1 ==1 ->
            delay(channeldelay1,MAXLATENCY);
            ec1flag[cfr1]=0;
        fi;
        randombabbleinchannel1();
    od
}

active proctype Channel2 ()
{
    byte j;
    byte cfr2,cmd2;
    do 
    :: babble2 == 1 ->
        generatebabbleframeforchannel2();
        channelr2!babblefrm2;
        babble2=0;
    :: channelt2?cfr2,cmd2 ->
        randomerrorinchannel2();
        if 
        :: error2==0 ->
            ec1flag[cfr2]=1;
            randomlatencyinchannel2();
            delay(channeldelay2,latency2);
            channelr2!cfr2,cmd2;
        :: error2 ==1 ->
            delay(channeldelay2,MAXLATENCY);
            ec1flag[cfr2]=0;
        fi;
        randombabbleinchannel2();
    od
}

active proctype EndSystem(){
    //从信道1或者信道2上接受帧
    channel1? rfr1,messagedigest;
    channelr1? rfr,rmd1;
    atomic{//检查是否是杂音
        verify(rfr1,rmd1);
        if 
        :: babblechk == 0 ->
            if
            :: rfr1 != 0 -> 
                ifpresentinlist(rfr1);
                if 
                :: ispresentflag == 0 ->
                    if 
                    :: rfr1 = psnr + 1 ->
                        deleverframetoendsystem(rfr1);
                    :: rfr1 > psnr + 1 ->
                        insertframinlist(rfr1);
                    :: rfr1 < psnr + 1 ->
                    fi;
                :: ispresentflag == 1 -> 
                    deliverframetoendsystem(rfr1);
                :: else ->
                fi;
            :: rfr1 == 0 -> 
                resetflag = 1;
            psnr = 0;
            fi;
        :: babblechk == 1 -> 
            babblechk = 0;
        fi;
    }
}
