#define timer byte
#define set(tmr,val) (tmr=val)
#define expire(tmr)(tmr==0)
#define tick(tmr) if :: tmr>0 -> tmr = tmr-1 ::else fi
#define delay(tmr,x) set (tmr,x);expire(tmr)
#define udelay(tmr) do ::delay(tmr,1) ::break od
proctype Timers()
{
    do 
        ::timeout -> atomic{tick(tmr1);tick(tmr2)}
    od
}

proctype Transmitter() {
    byte j;
    do
    :: expire(bag) ->
        set(bag, BAG);
        rchk = 0;
        randomjitter();
        delay(transmitterjitter, jitter);
        randomreset();
        if
        :: reset == 0 ->
            generatemessagedigest(tfr);
            channelt1 ! tfr, messagedigest;
            set(tdrf, TDRF);
            channelt2 ! tfr, messagedigest;
            do
                :: expire(tdrf) ->
                if
                :: tfr < 255 -> tfr = tfr + 1;
                :: else -> tfr =1;
                fi;
                break;
            od;
        :: reset == 1 ->
            rchk =1;
            tfr = 0;
            generatemessagedigest(tfr);
            channelt1 ! tfr, messagedigest;
            set(tdrf, TDRF);
            channelt2 ! tfr, messagedigest;
            do
            :: expire(tdrf) ->
                delay(resetdelay, HRD);
                tfr = 1; j = 0;
                do
                    :: j < 256 ->
                    ec1flag[j] = 0;
                    ec2flag[j] = 0;
                    rfflag[j] = 0;
                    j++;
                    :: j == 256 -> break;
                od;
                break;
            od;
        fi;
    od
}

proctype Channel1() {
    byte j;
    byte cfr1, cmd1;
    randombabbleinchannel1();
    do
    :: babble1 == 1 ->
        generatebabbleframeforchannel1();
        channelr1! babblefrm1,
        randommsgedigest1;
        babble1 = 0;
    :: channelt1 ? cfr1, cmd1 ->
        randomerrorinchannel1();
        if
        :: error1 == 0 ->
            ec1flag[cfr1] = 1;
            randomlatencyinchannel1();
            delay(channeldelay1, latency1);
            channelr1 ! cfr1, cmd1;
        :: error1 == 1 ->
            delay(channeldelay1, MAXLATENCY);
            ec1flag[cfr1] = 0;
        fi;
        randombabbleinchannel1();
    od;
}
proctype EndSystem(){
    atomic {
        verify(rfr1, rmd1);
        if
        :: babblechk == 0 ->
        if
        :: rfr1 != 0 ->
            ispresentinlist(rfr1);
            if
            :: ispresentflag == 0 ->
                if
                :: rfr1 = psnr + 1 ->
                deliverframetoendsystem(rfr1);
                :: rfr1 > psnr + 1->
                insertframeinlist(rfr1);
                :: rfr1 < psnr + 1 ->
                fi;
            :: ispresentflag == 1 ->
                deliverframetoendsystem(rfr1);
            :: else ->
            fi;
        :: rfr1 ==0 ->
                resetflag = 1;
            psnr = 0;
            fi;
        :: babblechk == 1->
            babblechk = 0;
        fi;
    }
}

inline deliverframe(element) {
    byte j, k;
    rfflag[element] = 1;
    psnr = element;
    j =0;
    do
    :: psnr < 255 ->
        if
        :: listelement[j] == psnr +1 ->
            rfflag[listelement[j]] = 1;
            psnr = listelement[j];
            j++;
        :: listelement[j] != psnr + 1 ->
            break;
        fi;
    :: psnr == 255 ->
        if
        :: listelement[j] == 1 ->
            rfflag[listelement[j]] = 1;
            psnr = listelement[j];
            j++;
        :: listelement[j] != 1 ->
            break;
        fi;
    od;
    k = j;
    do
    :: k < numoflistelements ->
        listelement[k] = listelement[k-j];
        k++;
    :: k >= numoflistelements ->
        break;
    od;
    numoflistelements = numoflistelements - j;
}