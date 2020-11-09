mtype = {ok,err,msg1,msg2,msg3,keyA,keyB,keyI,agentA,agentB,agentI,nonceA,nonceB,nonceI};

chan network=[0] of {mtype,mtype,mtype,mtype,mtype};

mtype partnerA;
mtype statusA =err;
mtype partnerB;
mtype statusB = err;
bool knows_nonceA,knows_nonceB;

active[2] proctype Alice() 
{
    mtype pkey,pnonce;
    mtype key,data1,data2;
    if
        ::partnerA = agentB;pkey=keyB;
        ::partnerA = agentI;pkey=keyI;
    fi;
    network!msg1(partnerA,pkey,agentA,nonceA);
    network?msg2(agentA,key,data1,data2);
    (key == keyA)&& (data1==nonceA);
    pnonce=data2;
    network!msg3(partnerA,pkey,pnonce,0);
    statusA = ok;
}

active[2] proctype Bob()
{
    mtype pkey,pnonce;
    mtype key,data1,data2;
    mtype key2,data3,data4;
    network?msg1(agentB,key,data1,data2)->
    if
    ::(key==keyB)&&(data1==agentA)->
        partnerB=agentA;
    network!msg2(partnerB,keyA,data2,nonceB);
    ::(key==keyB)&&(data1==agentI)->
        partnerB=agentI;
    network!msg2(agentI,keyI,data2,nonceB);
    fi;
    network?msg3(agentB,key2,data3,data4)->
    (key2==keyB)&&(data3==nonceB);
    statusB=ok;
}

active proctype Intruder()
{
    mtype msg,recpt;
    mtype key,data1,data2;
    mtype key1,data3,data4;
    do
    ::network?msg(_,key,data1,data2)->
        if
            ::key1=key;data3=data1;data4=data2;
            ::skip;
        fi;
        if
            ::(key==keyI)->
            if
                ::(data1==nonceA)||(data2==nonceA)->
                    knows_nonceA=true;
                ::(data1==nonceB)||(data2==nonceB)->
                    knows_nonceB=true;
                ::else->skip;
            fi;
            ::else->skip;
        fi;
        if 
            ::msg=msg1;
            ::msg=msg2;
            ::msg=msg3;
        fi;
        if
            ::recpt=agentA;
            ::recpt=agentB;
        fi;
        if 
            ::skip;
            ::if
                ::data3=agentA;
                ::data3=agentB;
                ::data3=agentI;
                ::knows_nonceA->data3=nonceA;
                ::knows_nonceB->data3=nonceB;
                ::data3=nonceI;
            fi;
            if
                ::data4=nonceI;
                ::knows_nonceA->data4=nonceA;
                ::knows_nonceB->data4=nonceB;
            fi;
            if
                ::key1=keyA;
                ::key1=keyB;
            fi;
        fi;
        network!msg(recpt,key1,data3,data4);
    od;
}

ltl p1 { []((statusA==ok &&statusB == ok) -> <> (partnerA == agentB && partnerB ==agentA)) }
ltl p2 { []((statusA==ok && partnerA == agentB)-> !knows_nonceA) }
ltl p3 { []((statusB==ok && partnerB == agentA)-> !knows_nonceB) }