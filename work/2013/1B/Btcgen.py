
import random
random.seed(8675309)

def makeDict() :
    DD = set()
    weights = [x for x in range(1,26+1)]
    random.shuffle(weights)
    while len(DD) < 500000 :
        wlen = random.randrange(1,10+1)
        lets = random.choices("abcdefghijklmnopqrstuvwxyz",weights,k=wlen)
        w = "".join(lets)
        DD.add(w)
    D = [x for x in DD]
    D.sort()
    return D

def makeWord(D,targlen) :
    w = ""
    while len(w) < targlen : w += random.choice(D)
    lets = [x for x in w]
    prev = 4
    cchance = random.random()
    for i in range(len(lets)) :
        if prev < 4 or random.random() < cchance:
            prev += 1
        else :
            prev = 0
            lets[i] = random.choice("abcdefghijklmnopqrstuvwxyz")
    ww = "".join(lets)
    return w

D = makeDict()
(fn,ntc) = ("Btc1.in",20+20)
with open(fn,'wt') as fp :
    print(len(D),file=fp)
    for w in D : print(w,file=fp)
    print(ntc, file=fp)
    for i in range(20) :
        w  = makeWord(D,20)
        print(w, file=fp)
    for i in range(20) :
        w  = makeWord(D,3990)
        print(w, file=fp)