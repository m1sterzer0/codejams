import random
random.seed(1234)

def makeGoodDeckArr(N,trials) :
    arr = [[x for x in range(N)] for y in range(trials)]
    for t in range(trials) :
        a = arr[t]
        for k in range(N) :
            p = random.randint(k,N-1)
            a[k],a[p] = a[p],a[k]
    return arr

def makeBadDeckArr(N,trials) :
    arr = [[x for x in range(N)] for y in range(trials)]
    for t in range(trials) :
        a = arr[t]
        for k in range(N) :
            p = random.randint(0,N-1)
            a[k],a[p] = a[p],a[k]
    return arr

numeach = 60
print(2*numeach)
arr1 = makeGoodDeckArr(1000,numeach)
arr2 = makeBadDeckArr(1000,numeach)
for d in arr1 :
    print(1000)
    print(" ".join([str(x) for x in d]))
for d in arr2 :
    print(1000)
    print(" ".join([str(x) for x in d]))
