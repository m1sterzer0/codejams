import random
random.seed(8675309)

def genInterestingTest() :
    A = random.randrange(2,100_000+1)
    B = random.randrange(2,20+1)
    X = random.randrange(1,B)
    Y = random.randrange(1,A)
    Vx = random.randrange(1,20+1)
    Vy = random.randrange(1,1_000_000)
    M = random.randrange(1,3+1)
    N = random.randrange(1,3+1)
    newA = A * Vx
    for i in range(1000) :
        Vy = random.randrange(1,1_000_000)
        del1 = 2*B*Vy % newA
        if del1 // (2*B*max(N,M)) >= 1 : break
    V = max(1, del1 // (2*B*N) - random.randrange(0,5+1))
    W = max(1, del1 // (2*B*M) - random.randrange(0,5+1))
    return (A,B,N,M,V,W,Y,X,Vy,Vx)

def genRandomTest() :
    A = random.randrange(2,100_000+1)
    B = random.randrange(2,20+1)
    X = random.randrange(1,B)
    Y = random.randrange(1,A)
    Vx = random.randrange(1,20+1)
    Vy = random.randrange(1,1_000_000)
    M = random.randrange(1,3+1)
    N = random.randrange(1,3+1)
    V = random.randrange(1,100_000)
    W = random.randrange(1_100_000)
    return (A,B,N,M,V,W,Y,X,Vy,Vx)

(fn,ntc) = ("Dtc1.in",2000)
with open(fn,'wt') as fp :
    with open("Dtc2.in","wt") as fp2 :
        print(ntc, file=fp)
        print(1,file=fp2)
        for i in range(ntc) :
            (A,B,N,M,V,W,Y,X,Vy,Vx) = genInterestingTest() if random.random() < 0.7 else genRandomTest()
            print(f"{A} {B}",file=fp)
            print(f"{N} {M}",file=fp)
            print(f"{V} {W}",file=fp)
            print(f"{Y} {X} {Vy} {Vx}",file=fp)
            if i == 40 :
                print(f"{A} {B}",file=fp2)
                print(f"{N} {M}",file=fp2)
                print(f"{V} {W}",file=fp2)
                print(f"{Y} {X} {Vy} {Vx}",file=fp2)


