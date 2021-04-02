import random
import math
random.seed(2345)

def doCase(fp) :
    N = random.randrange(1,101)
    W = random.randrange(1,101)
    H = random.randrange(1,101)
    Pmin = N*(2*W+2*H)
    Pminadd = Pmin + 2*min(W,H)
    Pmax = int(Pmin + N*2*math.sqrt(W*W+H*H))
    x = random.random()
    P = random.randrange(Pmin,Pminadd) if x < .2 else random.randrange(Pminadd,Pmax+1) if x < 0.8 else random.randrange(Pmax+1,100000001)
    print(f"{N} {P}",file=fp)
    for i in range(N) :
        print(f"{W} {H}",file=fp)

with open("C.in2","wt") as fp :
    with open("C.in2b","wt") as fp2 :
        tt = 5000
        print(tt,file=fp)
        print(1,file=fp2)
        for _t in range(tt) :
            if _t == 9 : doCase(fp2)
            doCase(fp)





