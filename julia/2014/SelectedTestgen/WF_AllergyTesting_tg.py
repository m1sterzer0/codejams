import random
random.seed(8675309)
ntests = 10000
with open("Etc1.in","wt") as fp :
    print(ntests,file=fp)
    for t in range(ntests) :
        ee = random.randrange(0,14+1)
        N = random.randrange(10**ee,10**(ee+1)+1)
        A = random.randrange(1,100+1)
        B = random.randrange(A,100+1)
        print(f"{N} {A} {B}",file=fp)

