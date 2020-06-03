import random

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
        c = random.randint(1,5)
        r = random.randint(1,c)
        b = random.randint(1,20)
    
        done = False
        while not done :
            mi = [ random.randint(1,b) for x in range(c) ]
            smi = sorted(mi,reverse=True)
            if sum(smi[0:r]) >= b : done = True
        
        si = [ random.randint(1,1000) for x in range(c) ]
        pi = [ random.randint(1,1000) for x in range(c) ]
        print("%d %d %d" % (r,b,c))
        for m,s,p in zip(mi,si,pi) :
             print("%d %d %d" % (m,s,p))
        




