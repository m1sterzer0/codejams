import random
random.seed(8675309)
(fn,ntc) = ("Atc1.in",100000)
goodtc = [859]
with open(fn,'wt') as fp :
    with open("Atc2.in","wt") as fp2:
        print(ntc, file=fp)
        print(len(goodtc), file=fp2)
        for i in range(ntc) :
            #N = random.randrange(3,20+1)
            #X = random.randrange(1,20+1)
            #C = random.randrange(0,10+1)
            #N = random.randrange(3,10+1)
            #X = random.randrange(1,10+1)
            C = random.randrange(0,7+1)
            N = random.randrange(3,7+1)
            X = random.randrange(1,7+1)
            #C = random.randrange(0,10+1)
            #N = random.randrange(3,5+1)
            #X = random.randrange(1,5+1)
            #C = random.randrange(0,5+1)

            #cdelmax = min(N-1,random.randrange(1,X+1))  
            print(f"{C}",file=fp)
            print(f"{X} {N}", file=fp)
            if i+1 in goodtc :
                print(f"{C}",file=fp2)
                print(f"{X} {N}", file=fp2)
            for j in range(C) :
                t = random.randrange(0,X)
                s = random.randrange(1,N+1)
                dmax = min(N-1,X-t)
                mydel = random.randrange(1,dmax+1)
                e = (s + mydel) % N
                if e == 0 : e = N
                print(f"{s} {e} {t}",file=fp)
                if i+1 in goodtc :
                    print(f"{s} {e} {t}",file=fp2)
