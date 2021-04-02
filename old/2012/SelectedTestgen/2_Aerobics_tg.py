
import random
random.seed(8675309)
def pickr(a=0.2,b=0.95) :
    t = random.random()
    r = (random.randrange(1,10+1) if t < a else
         random.randrange(10,100+1) if t < b else
         random.randrange(100,1000+1))
    return r 


(fn,ntc) = ("Btc1.in",1000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        N = random.randrange(5,10+1)
        (a,b) = (0.2,0.95) if random.random() < 0.8 else (0.05,0.10) if random.random() < 0.75 else (0.8,0.99)
        R = [pickr(a,b) for j in range(N)]
        carea = sum(x*x for x in R)
        w = random.random()
        lmin = 16*carea // 1_000_000_000 + 1
        L = random.randrange(lmin,lmin+5+1) if w < 0.10 else random.randrange(lmin+6,lmin+100+1) if w < 0.8 else random.randrange(lmin+101,lmin+10000)
        W = 16*carea // L + 1
        if random.random() < 0.5 : (L,W) = (W,L)
        print(f"{N} {W} {L}",file=fp)
        print(" ".join(str(x) for x in R),file=fp)

(fn,ntc) = ("Btc2.in",1000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        N = random.randrange(1,1000+1)
        (a,b) = (0.2,0.95) if random.random() < 0.8 else (0.05,0.10) if random.random() < 0.75 else (0.8,0.99)
        R = [pickr(a,b) for j in range(N)]
        carea = sum(x*x for x in R)
        w = random.random()
        lmin = 16*carea // 1_000_000_000 + 1
        L = random.randrange(lmin,lmin+5+1) if w < 0.10 else random.randrange(lmin+6,lmin+100+1) if w < 0.8 else random.randrange(lmin+101,lmin+10000)
        W = 16*carea // L + 1
        if random.random() < 0.5 : (L,W) = (W,L)
        print(f"{N} {W} {L}",file=fp)
        print(" ".join(str(x) for x in R),file=fp)

