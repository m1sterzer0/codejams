### For capacity checking
import random
random.seed(2345)
with open("A.in2","wt") as fp :
    t = 10000
    print(t,file=fp)
    for tt in range(t) :
        n = random.randrange(1,10001)
        k = random.randrange(1,n)
        print(f"{n} {k}", file=fp)