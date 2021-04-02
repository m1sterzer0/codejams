import random
import math
random.seed(1)

def perfectSeq() :
    x = [1]; w = 1
    while True :
        n = math.ceil(w/6)
        if n > 1e9 : break
        x.append(n)
        w += n
    #print(len(x))
    #print(x)
    return x

perfectSeq()

t = 100; print(t)
for i in range(6) :
    print(100000)
    x = perfectSeq()
    y = [ random.randint(1,1e9) for _ in range(100000-len(x)) ]
    i=0; j=0; nx = len(x); ny = len(y)
    v = [0] * 100000
    for xx in range(100000) :
        r = random.randrange(nx+ny)
        if r < nx :  v[xx] = x[i]; i += 1; nx -= 1
        else      :  v[xx] = y[j]; j += 1; ny -= 1
    print(" ".join(str(d) for d in v))
for i in range(100-6) :
    print(500)
    v = [ random.randint(1,1e9) for _ in range(500) ]
    print(" ".join(str(d) for d in v))