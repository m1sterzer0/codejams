### For capacity checking
import random
random.seed(2345)

def genRandomForest(n,p) :
    ## Do the math zero indexed, and then add one for the final result
    nodes = list(range(n))
    parents = [-1 for x in nodes]
    random.shuffle(nodes)
    for (i,n) in enumerate(nodes) :
        if i == 0 : continue
        if random.random() < p : continue
        parents[n] = random.choice(nodes[:i])
    return [x+1 for x in parents]

def genCoolWords(m) :
    lengths = [1] * 1 + [2] * 2 + [3] * 4 + [4] * 8 + [5] * 16 + [6] * 32
    coolWords = []
    for i in range(m) :
        l = random.choice(lengths)
        cw = "".join([random.choice("ABCDEF") for x in range(l)])
        coolWords.append(cw)
    return coolWords

with open("B.in2","wt") as fp :
    t = 100
    print(t,file=fp)
    for tt in range(t) :
        n = random.choice(list(range(90,101)))
        print(n,file=fp)
        parents = genRandomForest(n,0.02)
        pstr = " ".join([str(x) for x in parents])
        print(pstr,file=fp)
        fls = "".join([random.choice("ABCDEF") for x in range(n)])
        print(fls,file=fp)
        m = 5
        print(m,file=fp)
        cwstr = " ".join(genCoolWords(m))
        print(cwstr,file=fp)




