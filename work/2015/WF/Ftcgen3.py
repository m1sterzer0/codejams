import random
from math import gcd
random.seed(8675309)

def checks(s) :
    deltaarr = [0] * (2*len(s)+1)
    startloc = len(s)
    c,minc,maxc,totmoves = startloc,startloc,startloc,0
    for cc in s :
        if cc == 'b' :
            c -= 1
            minc = min(c,minc)
            totmoves += 1
        elif cc == 'f' :
            c += 1
            maxc = max(c,maxc)
            totmoves += 1
        elif cc == 'u' :
            deltaarr[c] -= 1
            if deltaarr[c] < 0 : deltaarr[c] += 256
        elif cc == 'd' :
            deltaarr[c] += 1
            if deltaarr[c] >= 256 : deltaarr[c] -= 256
    md = c - startloc
    darr = deltaarr[minc:maxc+1]
    cstartidx = startloc-minc
    cendidx = c-minc
    if md == 0 :
        retval = darr[cendidx] != 0 and gcd(darr[cendidx],256) == 1
        return retval
    else :
        stride = gcd(md,2**40)
        deltas = [darr[x] for x in range(cendidx,len(darr),stride)] + [darr[x] for x in range(cendidx-stride,-1,-1*stride)]
        retval =  sum(deltas) != 0 and gcd(sum(deltas),256) == 1
        return retval


def generateStr(n,docheck=False) :
    pset = [0.01 * i for i in range(1,100)]
    while(True) :
        x = random.random()
        weights = [0.25]*4 if x < 0.1 else [0.02,0.88,0.05,0.05] if x < 0.2 else [0.88,0.02,0.05,0.05] if x < 0.03 else [random.choice(pset) for i in range(4)]
        s = "".join(random.choices(population=['b','f','u','d'],weights=weights,k=n))
        if not docheck : return s
        if checks(s) : return s
        print(f"    {s} failed -- retrying...")


with open("Ftc6.in","wt") as fp :
    print(20000,file=fp)
    pset = [0.01 * i for i in range(1,100)]
    for sl in (10,20,30,40,50,100,200,500,1000,1994) :
        for i in range(2000) :
            print(f"Generating test: {i} for sl:{sl}")
            x = random.random()
            weights = [0.20]*5 if x < 0.2 else [random.choice(pset) for i in range(5)]
            js = "".join(random.choices(population=['a','b','c','d','e'],weights=weights,k=sl))
            len1 = js.count('a')
            len2 = max(1,js.count('b'))
            len3 = js.count('c')
            len4 = max(1,js.count('d'))
            len5 = js.count('e')
            s1 = "" if len1 == 0 else generateStr(len1)
            s2 = generateStr(len2,True)
            s3 = "" if len3 == 0 else generateStr(len3)
            s4 = generateStr(len4,True)
            s5 = "" if len5 == 0 else generateStr(len5)
            print(f"{s1}({s2}){s3}({s4}){s5}",file=fp)

with open("Ftc8.in","wt") as fp :
    print(20000,file=fp)
    pset = [0.01 * i for i in range(1,100)]
    for sl in (1990,1991,1992,1993,1994,1995,1996,1997,1998,1999) :
        for i in range(2000) :
            print(f"Generating test: {i} for sl:{sl}")
            x = random.random()
            weights = [0.20]*5 if x < 0.2 else [random.choice(pset) for i in range(5)]
            js = "".join(random.choices(population=['a','b','c','d','e'],weights=weights,k=sl))
            len1 = js.count('a')
            len2 = max(1,js.count('b'))
            len3 = js.count('c')
            len4 = max(1,js.count('d'))
            len5 = js.count('e')
            s1 = "" if len1 == 0 else generateStr(len1)
            s2 = generateStr(len2,True)
            s3 = "" if len3 == 0 else generateStr(len3)
            s4 = generateStr(len4,True)
            s5 = "" if len5 == 0 else generateStr(len5)
            print(f"{s1}({s2}){s3}({s4}){s5}",file=fp)
