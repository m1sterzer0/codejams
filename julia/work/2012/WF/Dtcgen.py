import random
def doit(fn1,fn2,ntc,goodids,Nmax,Mmax,Cmax) :  
    with open(fn1,'wt') as fp1 :
        with open (fn2,'wt') as fp2 :
            print(ntc,file=fp1)
            print(len(goodids),file=fp2)
            for ttt in range(ntc) :
                N = random.randrange(1,Nmax+1)
                M = random.randrange(1,Mmax+1)
                pts = set()
                while len(pts) < N :
                    x = random.randrange(-Cmax,Cmax+1)
                    y = random.randrange(-Cmax,Cmax+1)
                    pts.add((x,y))
                fps = [fp1,fp2] if ttt+1 in goodids else [fp1]
                for fp in fps :
                    print(N,file=fp)
                    print(M,file=fp)
                    for (x,y) in pts :
                        print(f"{x} {y}",file=fp)

random.seed(8675309)
doit("Dtc1.in","Dtc1b.in",1000,[15],4,10,10)
doit("Dtc2.in","Dtc2b.in",1000,[],10,10,1000)
doit("Dtc3.in","Dtc3b.in",1000,[],5000,100000000,1000)
