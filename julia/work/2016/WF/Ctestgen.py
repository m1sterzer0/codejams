### For capacity checking
import random
random.seed(2345)
with open("C.in2","wt") as fp :
    t = 100
    print(t,file=fp)
    for tt in range(t) :
        n = random.randrange(2,1000000001)
        rr = random.choice([(1,11),(10,101),(100,1001),(1000,10001),(10000,100001),(100000,1000001),(999000,1000001)])
        r = random.randrange(rr[0],rr[1])
        print(f"{n} {r}", file=fp)