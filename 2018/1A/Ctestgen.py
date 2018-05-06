import random
import math

def knobi(breakpoints,ranges) :
    x = random.random()
    for i,b in enumerate(breakpoints) :
        if x < b : return random.randint(ranges[i][0],ranges[i][1])
    return random.randint(ranges[-1][0],ranges[-1][1])

def knobf(breakpoints,ranges) :
    x = random.random()
    for i,b in enumerate(breakpoints) :
        if x < b : return random.uniform(ranges[i][0],ranges[i][1])
    return random.uniform(ranges[-1][0],ranges[-1][1])

if __name__ == "__main__" :
    t = 1000
    random.seed(1)
    print(t)
    for tt in range(t) :
        w = random.randint(1,250)
        h = random.randint(1,250)
        n = random.randint(1,100)
        minperim = n * (2*w+2*h)
        maxperim = minperim + int(n * 2 * math.sqrt(w*w+h*h)) + 1
        p = random.randint(minperim,int(1.15*maxperim))
        print("%d %d" % (n,p))
        for x in range(n) :
            print("%d %d" % (w,h))
