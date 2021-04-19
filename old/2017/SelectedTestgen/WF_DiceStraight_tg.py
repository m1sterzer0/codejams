import random
random.seed(2345)

with open("A.in2","wt") as fp :
    tt = 1000
    print(tt,file=fp)
    for _t in range(tt) :
        dmax = random.choice([100,300,1000,3000])
        n = 100
        print(n,file=fp)
        for _n in range(n) :
            dvals = [random.randrange(1,dmax+1) for _i in range(6)]
            print(" ".join(str(x) for x in dvals), file=fp)

with open("A.in3","wt") as fp :
    tt = 1000
    print(tt,file=fp)
    for _t in range(tt) :
        n = 3
        dmax = random.choice([1*n,2*n,3*n,4*n,5*n,6*n,12*n,24*n])
        print(n,file=fp)
        for _n in range(n) :
            dvals = [random.randrange(1,dmax+1) for _i in range(6)]
            print(" ".join(str(x) for x in dvals), file=fp)

with open("A.in4","wt") as fp :
    tt = 10
    print(tt,file=fp)
    for _t in range(tt) :
        n = 50000
        print(n,file=fp)
        for _n in range(n) :
            dvals = [random.randrange(1000000-2*6*n,1000001) for _i in range(6)]
            print(" ".join(str(x) for x in dvals), file=fp)
