byte sem=1;
byte critical = 0;
#define sss (sem>0)
#define mutex (critical <= 1)

active proctype P1(){
    do ::
        atomic{sem>0;sem--;}
        critical ++;
        critical -- ;
        sem++;
    od 
}

active proctype P2(){
   do ::
        atomic{sem>0;sem--;}
        critical ++;
        critical -- ;
        sem++;
    od 
}
ltl e1 {<>mutex}
ltl e2 {!<>mutex}
ltl e3 {<>!mutex}
ltl e4 {[] mutex}
ltl e5 {![] mutex}
ltl e6 {[]! mutex}
ltl e7 {!sss-> []mutex}
