
import random
random.seed(8675309)
(fn,ntc) = ("Btc1.in",1000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        E = random.randrange(1,5+1)
        R = random.randrange(1,5+1)
        N = random.randrange(1,10+1)
        VV = [random.randrange(1,10+1) for i in range(N)]
        vstr = " ".join(str(x) for x in VV)
        print(f"{E} {R} {N}",file=fp)
        print(f"{vstr}",file=fp)
