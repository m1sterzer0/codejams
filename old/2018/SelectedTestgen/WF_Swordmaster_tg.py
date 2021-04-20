import random
random.seed(8675309)
with open("Dtc1.in","wt") as fp:
    with open("Dtc2.in","wt") as fp2 :
        ntc = 1000
        print(ntc,file=fp)
        targtcs = [59,159,239,265]
        print(f"{len(targtcs)}",file=fp2)
        for tt in range(ntc) :
            N = random.randrange(2,20+1)
            x = random.random()
            P = random.randrange(1,10+1) if x < 0.33 else random.randrange(1,N+1) if x < 0.66 else random.randrange(1,50+1)
            print(f"{N} {P}",file=fp)
            if tt+1 in targtcs: print(f"{N} {P}",file=fp2)
            for i in range(N) :
                a,d = [1],[1]
                achance = random.random()
                dchance = random.random()
                for j in range(2,P+1) :
                    if random.random() < achance : a.append(j)
                    if random.random() < dchance : d.append(j)
                la,ld = len(a),len(d)
                sa = " ".join(str(x) for x in a)
                sd = " ".join(str(x) for x in d)
                print(f"{la} {ld}",file=fp)
                print(sa,file=fp)
                print(sd,file=fp)
                if tt+1 in targtcs:
                    print(f"{la} {ld}",file=fp2)
                    print(sa,file=fp2)
                    print(sd,file=fp2)
            
