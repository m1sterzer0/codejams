import random
random.seed(8675309)

def genk(s) :
    ans = 1
    for x in s :
        if random.random() < 0.5 : ans *= x
    return ans

def makeCase(fn1,fn2,R,N,M,K) :
    with open(fn1,"wt") as fp1:
        with open (fn2,"wt") as fp2:
            print("Case 1:",file=fp2)
            print("1",file=fp1)
            print(f"{R} {N} {M} {K}",file=fp1)
            for r in range(R) :
                s = [random.randrange(2,M+1) for x in range(N)]
                s.sort()
                knums = [genk(s) for k in range(K)]
                kstr = " ".join(str(x) for x in knums)
                sstr = "".join(str(x) for x in s)
                print(kstr,file=fp1)
                print(sstr,file=fp2)

makeCase("Ctc1.in","Ctc1.out",10000,3,5,7)
makeCase("Ctc2a.in","Ctc2a.out",8000,12,8,12)
makeCase("Ctc2b.in","Ctc2b.out",8000,12,8,12)
makeCase("Ctc2c.in","Ctc2c.out",8000,12,8,12)
makeCase("Ctc2d.in","Ctc2d.out",8000,12,8,12)
makeCase("Ctc2e.in","Ctc2e.out",8000,12,8,12)
