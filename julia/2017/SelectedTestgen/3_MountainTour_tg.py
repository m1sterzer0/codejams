import random
random.seed(2345)

def genGraph(C) :
    good = False
    gr = [0 for x in range(2*C)]
    while not good :
        good = True
        gr = [0 for x in range(2*C)]
        unclaimed = set(range(1,2*C))
        i = 0
        for _x in range(2*C-1) :
            good2 = False
            for _y in range(10) :
                l = list(unclaimed )
                x = random.choice(l)
                if abs(x-i) > 1 : good2 = True; break
                if i % 2 == 0 and x < i: good2 = True; break
                if i % 2 == 1 and x > i: good2 = True; break
            if not good2: good = False; break
            unclaimed.remove(x)
            gr[i] = x
            i = x
        if gr[1] == 0: good = False
    return gr 

with open("C.in2","wt") as fp :
    tt = 100
    print(tt,file=fp)
    for _t in range(tt) :
        #c = random.choice(random.choice( [list(range(5,16)), list(range(5,16)), list(range(50,101)), list(range(900,1001))] ))
        C = random.randrange(5,16)
        print(C,file=fp)
        L = [random.randrange(0,24)  for _x in range(2*C)]
        D = [random.randrange(1,100) for _x in range(2*C)]
        gr = genGraph(C)
        print(C,gr)
        E = [gr[i]//2+1 for i in range(2*C)]
        for (x,y,z) in zip(E,L,D) :
            print(f"{x} {y} {z}",file=fp)
