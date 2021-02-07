import random
random.seed(8765309)

with open("D.in2","wt") as fp :
    tt = 100
    print(tt,file=fp)
    for _t in range(tt) :
        R = random.randrange(18,21)
        C = random.randrange(18,21)
        print(f"{R} {C}",file=fp)
        g = [[random.choice("WB") for x in range(C)] for y in range(R)]
        for gr in g :
            print("".join(gr),file=fp)
        