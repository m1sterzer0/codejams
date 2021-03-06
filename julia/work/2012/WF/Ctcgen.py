import random
def getpts(N,cmax,xmax) :
    cx = random.randrange(-cmax,cmax+1)
    cy = random.randrange(-cmax,cmax+1)
    s = set()
    while len(s) < N :
        x = random.randrange(-xmax,xmax+1)
        y = random.randrange(-xmax,xmax+1)
        s.add((x,y))
    pts = [(x,y) for (x,y) in s]
    random.shuffle(pts)
    return (cx,cy,pts)

def doit(fn,fn2,goodids,ntc,nmax,cmax,xmax) :
    with open(fn,'wt') as fp :
        with open(fn2,'wt') as fp2 : 
            print(ntc, file=fp)
            print(len(goodids), file=fp2)
            for ttt in range(ntc) :
                N = random.randrange(1,nmax+1)
                corrupt = [True if random.random() < 0.9995 else False for i in range(N)]
                (cx,cy,pts) = getpts(N,cmax,xmax)
                print(N,file=fp)
                if ttt+1 in goodids : print(N,file=fp2)
                for i,(x,y) in enumerate(pts):
                    d = max(abs(x-cx),abs(y-cy))
                    d2 = d % 2 == 0
                    c = "." if d2 ^ corrupt[i] else "#"
                    print(f"{x} {y} {c}",file=fp)
                    if ttt+1 in goodids : print(f"{x} {y} {c}",file=fp2)

if __name__ == "__main__" :
    random.seed(8675309)
    doit("Ctc1.in","Ctc1b.in",[97,561],1000,4,300,100)
    doit("Ctc2.in","Ctc2b.in",[],1000,100,300,100)
    doit("Ctc3.in","Ctc3b.in",[],1000,1000,3_000_000_000_000_000,1_000_000_000_000_000)
