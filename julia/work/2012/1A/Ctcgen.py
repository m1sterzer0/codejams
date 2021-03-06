import random

def gencase(N,Smax,Pmax) :
    A = []
    for i in range(N) :
        l = random.choice(["L","R"])
        s = random.randrange(1,Smax+1)
        p = random.randrange(0,Pmax+1)
        A.append((l,s,p))
    return A

def check(N,A) :
    larr = []
    rarr = []
    for (l,s,p) in A: 
        if l == "L" : larr.append(p)
        else : rarr.append(p)
    for arr in [larr,rarr]:
        if len(arr) <= 2 : continue
        arr.sort()
        for i in range(len(arr)-1) :
            if arr[i+1]-arr[i] < 5 : return False
    return True 


random.seed(8675309)
(fn,ntc) = ("Ctc1.in",1000)
goodcases = [4,11,18,19,30,37,39,41,45,47,52,55,57,65,71,72,74,76,78,97,99]
with open(fn,'wt') as fp :
    with open("Ctc2.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodcases), file=fp2)
        for i in range(ntc) :
            N = random.randrange(1,6+1)
            Smax = random.choice([3,10,30,100,300,1000])
            Pmax = random.choice([30,100,1000,10000])
            A = gencase(N,Smax,Pmax)
            while not check(N,A) : A = gencase(N,Smax,Pmax)
            print(N,file=fp)
            for (l,s,p) in A :
                print(f"{l} {s} {p}",file=fp)
            if i+1 in goodcases :
                print(N,file=fp2)
                for (l,s,p) in A :
                    print(f"{l} {s} {p}",file=fp2)



