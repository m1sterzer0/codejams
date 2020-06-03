### For capacity checking
import random
random.seed(2345)

with open("C.in2","wt") as fp :
    t = 20
    print(t,file=fp)
    for tt in range(t) :
        n = random.choice(list(range(900,1001)))
        s = random.choice(list(range(1,101)))
        print(f"{n} {s}",file=fp)
        for i in range(n) :
            print(" ".join(str(random.randrange(-500,501)) for x in range(6)),file=fp)