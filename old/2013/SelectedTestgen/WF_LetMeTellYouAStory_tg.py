
import random
random.seed(8675309)
(fn,ntc) = ("Etc1.in",1000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        #N = random.randrange(1,100+1) if i < 800 else random.randrange(1500,2000+1) if i < 980 else random.randrange(7900,8000+1)
        N = random.randrange(1,100+1)
        Nmax = random.choice([1,3,10,30,100,300,1000,3000,10000,30000,100000])
        NN = [random.randrange(1,Nmax+1) for i in range(N)]
        NNstr = " ".join(str(x) for x in NN)
        print(N,file=fp)
        print(NNstr,file=fp)

(fn,ntc) = ("Etc2.in",100)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        #N = random.randrange(1,100+1) if i < 800 else random.randrange(1500,2000+1) if i < 980 else random.randrange(7900,8000+1)
        N = random.randrange(1500,2000+1) if i < 80 else random.randrange(7900,8000+1)
        Nmax = random.choice([1,3,10,30,100,300,1000,3000,10000,30000,100000])
        NN = [random.randrange(1,Nmax+1) for i in range(N)]
        NNstr = " ".join(str(x) for x in NN)
        print(N,file=fp)
        print(NNstr,file=fp)

