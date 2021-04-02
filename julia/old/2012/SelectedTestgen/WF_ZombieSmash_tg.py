
import random
random.seed(8675309)
goodids = [125]
(fn,ntc) = ("Atc1.in",1000)
with open(fn,'wt') as fp :
    with open("Atc2.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodids),file=fp2)
        for ttt in range(ntc) :
            Cmax = random.choice([5]*32+[10]*32+[100]*16+[1000]*2)
            Cmin = -Cmax
            Mmax = random.choice([100]*2+[1000]*2+[10000]*8+[100000]*4+[1000000]*2+[100000]*2+[100_000_000])
            Z = random.randrange(1,8+1)
            while(True) :
                zombies = [(random.randrange(Cmin,Cmax+1),
                            random.randrange(Cmin,Cmax+1),
                            random.randrange(0,Mmax+1)) for i in range(Z)]
                good = True
                for i in range(0,Z-1) :
                    for j in range(i+1,Z) :
                        if zombies[i][0] != zombies[j][0] : continue
                        if zombies[i][1] != zombies[j][1] : continue
                        if abs(zombies[i][2] - zombies[j][2]) > 1000 : continue
                        good = False
                if good : break

            print(Z,file=fp)
            for (x,y,m) in zombies: print(f"{x} {y} {m}",file=fp)
            if ttt+1 in goodids :
                print(Z,file=fp2)
                for (x,y,m) in zombies: print(f"{x} {y} {m}",file=fp2)


