import random
random.seed(8675309)
with open("Atc1.in","wt") as fp :
    with open("Atc2.in","wt") as fp2 : 
        ntc = 1000
        targets = [12,20,26,60]
        print(f"{ntc}",file=fp)
        print(f"{len(targets)}",file=fp2)

        for i in range(ntc) :
            R,C = 1,1
            while(R*C == 1) :
                R = random.randrange(1,20+1)
                C = random.randrange(1,20+1)
            S = random.randrange(2,min(15,R*C)+1)
            station = []
            while len(station) < S :
                r1 = random.randrange(1,R+1)
                c1 = random.randrange(1,C+1)
                if (r1,c1) in station : continue
                station.append((r1,c1))
            print(f"DBG stations:{station}")
            dmax = max(R,C)
            print(f"{R} {C} {S}", file=fp)
            if i+1 in targets : print(f"{R} {C} {S}", file=fp2)
            for (r,c) in station :
                d = random.randrange(1,dmax+1)
                print(f"{r} {c} {d}",file=fp)
                if i+1 in targets : print(f"{r} {c} {d}",file=fp2)

