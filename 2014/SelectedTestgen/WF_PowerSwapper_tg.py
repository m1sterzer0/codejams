import random
random.seed(8675309)

with open ("Btc1.in","wt") as fp :
    numt = 10000
    print(numt,file=fp)
    choices = [1] * 1 + [2] * 10 + [3] * 100 + [4] * 1000
    #choices = [1] * 1 + [2] * 10 + [3] * 100
    #choices = [1] * 1 + [2] * 10


    for t in range(numt) :
        n = random.choice(choices)
        print(n,file=fp)
        l = 2**n
        arr = [x for x in range(1,l+1)]
        if random.random() < 0.05 :
            random.shuffle(arr)
        else :
            for i in range(n) :
                myl = 2**i
                if random.random() < 0.3 : continue
                n1 = random.randrange(0,l,2**i)
                n2 = random.randrange(0,l,2**i)
                if n1 == n2 : continue
                arr[n1:n1+myl],arr[n2:n2+myl] = arr[n2:n2+myl],arr[n1:n1+myl]
        x = " ".join(str(x) for x in arr)
        print(x,file=fp)

