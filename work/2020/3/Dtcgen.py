
import random
random.seed(8675309)
ntc = 10000
goodids = [311,3137]
Nmax=3
Dmax=5
Cmax=6
with open("Dtc1.in",'wt') as fp :
    with open("Dtc1b.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodids),file=fp2)
        for ttt in range(ntc) :
            N = random.randrange(2,Nmax+1)
            D = random.randrange(1,Dmax+1)
            pts = set()
            while len(pts) < N :
                x = random.randrange(-Cmax,Cmax+1)
                y = random.randrange(-Cmax,Cmax+1)
                pts.add((x,y))
            lpts = [(x,y) for (x,y) in pts]
            random.shuffle(lpts)
            print(f"{N} {D}",file=fp)
            for (x,y) in lpts: 
                print(f"{x} {y}",file=fp)
            if ttt+1 in goodids :
                print(f"{N} {D}",file=fp2)
                for (x,y) in lpts: 
                    print(f"{x} {y}",file=fp2)
                

            

            pass

