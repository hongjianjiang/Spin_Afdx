int x = 15, y = 20;
int a = x, b = y;
 /*parGCD2*/
 active proctype Action1() {
 do
 :: a > b -> a = a - b
 
 :: a == b -> break
 od;
 printf("Action1 terminating: GCD of %d and %d is equal to %d\n", x, y, a)
 }
 
  active proctype Action2() {
 do
 
 :: b > a -> b = b - a
 :: a == b -> break
 od;
 printf("Action2 terminating: GCD of %d and %d is equal to %d\n", x, y, b)
 }