
import random
random.seed(8675309)
(fn,ntc) = ("Ctc1.in",100000)
goodids = [448]
with open(fn,'wt') as fp :
    with open("Ctc2.in",'wt') as fp2:
        print(ntc, file=fp)
        print(len(goodids), file=fp2)
        for nnn in range(ntc) :
            M = random.randrange(1,2_000_000+1)
            F = M
            numiter = random.randrange(1,5+1)
            for i in range(numiter) : F = random.randrange(1,F+1)
            s = random.random()
            N = 1 if s < 0.05 else random.randrange(1,10+1) if s < 0.50 else random.randrange(1,100+1) if s < 0.9 else random.randrange(1,200+1)
            meals = []
            for n in range(N) :
                p = M
                numiter = random.randrange(1,5+1)
                for i in range(numiter) : p = random.randrange(1,p+1)
                ss = random.random()
                s = random.randrange(0,10+1) if ss < 0.50 else random.randrange(0,100+1) if ss < 0.99 else random.randrange(0,1000+1) if ss < 0.999 else random.randrange(0,2000000+1)
                meals.append((p,s))
            print(f"{M} {F} {N}",file=fp)
            for (p,s) in meals :
                print(f"{p} {s}",file=fp)
            if nnn+1 in goodids :
                print(f"{M} {F} {N}",file=fp2)
                for (p,s) in meals :
                    print(f"{p} {s}",file=fp2)

        



