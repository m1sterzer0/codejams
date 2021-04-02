import random
random.seed(2345)

def printRandomCase(fp) :
    R = random.choice([2,6,10,19,47,90,97,100])
    C = random.choice([2,6,10,19,47,90,97,100])
    H = 1 if R==2 else random.randrange(1,6)
    V = 1 if C==2 else random.randrange(1,6)
    print(f"{R} {C} {H} {V}",file=fp)
    chipPercent = random.choice([0.02,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.75,0.99,1.00])
    gr = [["." for j in range(C)] for i in range(R)]
    for i in range(R) :
        for j in range(C) :
            if random.random() < chipPercent : gr[i][j] = "@"
    for grow in gr :
        ss = "".join(grow)
        print(ss,file=fp)


def printPossibleCase(fp) :
    H = random.randrange(1,6)
    V = random.randrange(1,6)
    R = 100
    C = 100
    print(f"{R} {C} {H} {V}",file=fp)
    hcuts = set()
    for i in range(H) :
        x = random.randrange(100)
        while x in hcuts : x = random.randrange(100)
        hcuts.add(x)
    hcuts = sorted([x for x in hcuts])
    vcuts = set()
    for i in range(V) :
        x = random.randrange(100)
        while x in vcuts : x = random.randrange(100)
        vcuts.add(x)
    vcuts = sorted([x for x in vcuts])



with open("A.in2","wt") as fp :
    with open("A.in2b","wt") as fp2 :
        tt = 10000
        print(tt,file=fp)
        print(1,file=fp2)
        for i in range(10000):
            if i == 398: printRandomCase(fp2) 
            printRandomCase(fp)
    #for i in range(100): printPossibleCase(fp)
