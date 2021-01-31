import random
random.seed(8675309)
with open("Ftc1.in","wt") as fp :
    print(20000,file=fp)
    for t in range(10000) :
        N = random.randrange(10,100+1)
        R = random.randrange(2,5+1)
        G = random.randrange(2,5+1)

        nprobs = random.choice([3,4,5])
        a = random.randrange(N+1)
        b = random.randrange(N+1)
        c = random.randrange(N+1)
        d = random.randrange(N+1)
        p1 = random.randrange(10000+1) / 10000.0
        p2 = random.randrange(10000+1) / 10000.0
        p3 = random.randrange(10000+1) / 10000.0
        p4 = random.randrange(10000+1) / 10000.0
        p5 = random.randrange(10000+1) / 10000.0
        if nprobs == 3 :
            a,b = sorted([a,b])
            p1,p2,p3 = sorted([p1,p2,p3])
            n1,n2,n3 = a,b-a,N-b
            plist = [p1] * n1 + [p2] * n2 + [p3] * n3
        elif nprobs == 4 :
            a,b,c = sorted([a,b,c])
            p1,p2,p3,p4 = sorted([p1,p2,p3,p4])
            n1,n2,n3,n4 = a,b-a,c-b,N-c
            plist = [p1] * n1 + [p2] * n2 + [p3] * n3 + [p4] * n4
        else :
            a,b,c,d = sorted([a,b,c,d])
            p1,p2,p3,p4,p5 = sorted([p1,p2,p3,p4,p5])
            n1,n2,n3,n4,n5 = a,b-a,c-b,d-c,N-d
            plist = [p1] * n1 + [p2] * n2 + [p3] * n3 + [p4] * n4 + [p5] * n5
        random.shuffle(plist)
        mmax = 1000 // N
        mymult = random.randrange(2,mmax+1)
        print(f"{N} {R} {G}",file=fp)
        out1 = " ".join(["%.4f" % x for x in plist])
        print(f"{out1}",file=fp)
        plist2 = plist * mymult
        print(f"{mymult*N} {R} {G}",file=fp)
        out2 = " ".join(["%.4f" % x for x in plist2])
        print(f"{out2}",file=fp)




    










    a,b,c,d = sorted([a,b,c,d])
    if b < a : (a,b) = (b,a)
    numlow = a
    nummid = b-a
    numhi = 100-b

