import random
random.seed(2345)

with open("B.in2","wt") as fp :
    print(1000,file=fp)
    primary = [0] * 30 + list(range(1,101))
    for i in range(1000) :
        done = False
        while (not done) :
            done = True
            r = random.choice(primary)
            b = random.choice(primary)
            y = random.choice(primary)
            o = random.randrange(0,b+1)
            v = random.randrange(0,y+1)
            g = random.randrange(0,r+1)
            n = r+b+y+o+v+g
            if n == 0 : done = False
        print(f"{n} {r} {o} {y} {g} {b} {v}", file=fp)





