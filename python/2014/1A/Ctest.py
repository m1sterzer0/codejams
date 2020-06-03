import numpy as np 
import matplotlib
import matplotlib.pyplot as plt
import random

random.seed(1)

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

def badHistogram(N,trials) :
    incr = 1.0/trials
    res1 = np.zeros((N,N),dtype=np.float)
    arr = makeBadDeckArr(N,trials)
    for t in range(trials) :
        for k in range(N) :
            res1[k,arr[t][k]] += incr

    f, (ax1,ax2) = plt.subplots(1,2)
    ax1.imshow(res1,cmap='Greys',vmin=0.5*1.0/N, vmax=1.5*1.0/N)
    ax2.imshow(res1-1.0/N,cmap='seismic')
    plt.show()
    
def classifier1(deck,N) :
    score = 0
    for j in range(N) :
        if deck[j] > j : score += 1
    return score

def classifier2(deck,N) :
    score = 0
    for j in range(N) :
        if deck[j] > j : score += 1
        if deck[j] > j + N/2 : score -= 3
    return score

def testClassifier1(N,runs) :
    arr2 = makeGoodDeckArr(N,runs)
    arr3 = makeBadDeckArr(N,runs)
    class2 = [classifier1(x,N) for x in arr2]
    class3 = [classifier1(x,N) for x in arr3]
    plt.hist(class2, bins=40, alpha=0.5)
    plt.hist(class3, bins=40, alpha=0.5)
    plt.show()

def testClassifier2(N,runs) :
    arr2 = makeGoodDeckArr(N,runs)
    arr3 = makeBadDeckArr(N,runs)
    class2 = [classifier2(x,N) for x in arr2]
    class3 = [classifier2(x,N) for x in arr3]
    plt.hist(class2, bins=40, alpha=0.5)
    plt.hist(class3, bins=40, alpha=0.5)
    plt.show()

if __name__ == "__main__" :
    badHistogram(100,50000)
    #badHistogram(1000,10000)
    #testClassifier1(1000,1000)
    #testClassifier2(1000,1000)    