
import random
random.seed(8675309)
(fn,ntc) = ("Dtc1.in",1000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        N = random.choice([1,2,3,4,5] + [100]*5 + [1000]*10 + [100000])
        D = random.randrange(1,4+1)
        Nmax = random.choice([1,2,3,4,5,10,15,20,25])
        #k = random.randrange(2,3+1)
        k = 2
        print(f"{N} {D} {k}",file=fp)
        NN = [random.randrange(1,Nmax+1) for x in range(N*D)]
        numstr = " ".join(str(x) for x in NN)
        print(numstr,file=fp)

