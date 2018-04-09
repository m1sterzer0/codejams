
import random
random.seed(1)

def knobint(buckets,cutoffs,minval,maxval) :
    w = random.random()
    for i in range(buckets) :
        if w < cutoffs[i] : return random.randint(minval[i],maxval[i])
    return minval[0]

numtests = 1000
print(numtests)
for tt in range(numtests) :
    n = knobint(2,(0.25,1.00),(3,11),(10,100))
    print (n)
    v = [random.randint(1,100) for x in range(n)]
    print(" ".join([str(x) for x in v]))
    
