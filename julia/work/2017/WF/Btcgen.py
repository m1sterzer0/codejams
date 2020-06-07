import random
random.seed(2345)

with open("B.in2","wt") as fp :
    tt = 100
    print(tt,file=fp)
    for _t in range(tt) :
        c = 15
        s = random.randrange(-1000,1001)
        print(f"{s} {c}",file=fp)
        for _c in range(c) :
             op = random.choice("+-*/")
             val = random.randrange(-1000,1001)
             while op == "/" and val == 0 :
                val = random.randrange(-1000,1001)
             print(f"{op} {val}", file=fp)

with open("B.in3","wt") as fp :
    tt = 100
    print(tt,file=fp)
    for _t in range(tt) :
        c = 3
        s = random.randrange(-5,6)
        print(f"{s} {c}",file=fp)
        for _c in range(c) :
             op = random.choice("+-*/")
             val = random.randrange(-5,6)
             while op == "/" and val == 0 :
                val = random.randrange(-5,6)
             print(f"{op} {val}", file=fp)
