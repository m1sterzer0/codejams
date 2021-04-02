import random
random.seed(8675309)

def genrow() :
    (d,n,w,e,s,dd,dp,ds) = (0,0,0,0,0,0,0,0)
    n = 1000
    good = False
    while not good :
        d = random.randrange(676060+1)
        dd = random.randrange(676060//999+1)
        if d+999*dd >= 0 and d+999*dd <= 676060 : good = True
    good = False
    while not good :
        w = random.randrange(-1000000,1000000+1)
        e = random.randrange(-1000000,1000000+1)
        if w < e :  good = True
    good = False
    while not good :
        s = random.randrange(1,1000000+1)
        ds = random.randrange(-100000,100000+1)
        if s + 999*ds >= 1 : good = True
    dp = random.randrange(-100000,100000+1)
    return (d,n,w,e,s,dd,dp,ds)

(fn,ntc) = ("Ctc1.in",20)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        N = 1000
        print(N,file=fp)
        for i in range(N) :
            (d,n,w,e,s,dd,dp,ds) = genrow()
            print(f"{d} {n} {w} {e} {s} {dd} {dp} {ds}",file=fp)

