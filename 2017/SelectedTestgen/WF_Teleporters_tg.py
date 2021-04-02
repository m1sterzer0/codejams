import random
random.seed(2345)

with open ("F.in3","wt") as fp :
    tt = 100
    print(tt,file=fp)

    ## 100 cases with 2 plantets, each within 5 of the origin.  target planet is at (100,100,100)
    for _t in range(tt) :
        Xs,Ys,Zs = 0,0,0
        Xf,Yf,Zf = 100,100,100
        N = random.choice([2,3,4])
        print(N,file=fp)
        print(f"{Xs} {Ys} {Zs}",file=fp)
        print(f"{Xf} {Yf} {Zf}",file=fp)
        used = set()
        used.add((0,0,0))
        d = random.randrange(1,6)
        for _n in range(N) :
            X,Y,Z = 0,0,0
            while (X,Y,Z) in used :
                X = random.randrange(-d,d+1)
                Y = random.randrange(-d,d+1)
                Z = random.randrange(-d,d+1)
            used.add((X,Y,Z))
            print(f"{X+Xs} {Y+Ys} {Z+Zs}",file=fp)

with open ("F.in4","wt") as fp :
    tt = 100
    print(tt,file=fp)

    ## 100 cases with 2 plantets, each within 5 of the origin.  target planet is at (100,100,100)
    for _t in range(tt) :
        Xs,Ys,Zs = -900,-900,-900
        Xf,Yf,Zf = 1000,1000,1000
        N = random.randrange(100,151)
        print(N,file=fp)
        print(f"{Xs} {Ys} {Zs}",file=fp)
        print(f"{Xf} {Yf} {Zf}",file=fp)
        used = set()
        used.add((0,0,0))
        d = random.randrange(3,10)
        for _n in range(N) :
            X,Y,Z = 0,0,0
            while (X,Y,Z) in used :
                X = random.randrange(-d,d+1)
                Y = random.randrange(-d,d+1)
                Z = random.randrange(-d,d+1)
            used.add((X,Y,Z))
            print(f"{X+Xs} {Y+Ys} {Z+Zs}",file=fp)

