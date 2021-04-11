
import random
random.seed(8675309)
ntc = 10000
goodids = [3270, 6048, 7961]
with open("Btc1.in",'wt') as fp :
    with open("Btc1b.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodids),file=fp2)
        for ttt in range(ntc) :
            N = random.randrange(4,10+1)
            M = [x for x in range(1,N+1)]
            C = [x for x in range(1,N+1)]
            random.shuffle(M)
            random.shuffle(C)
            print(N,file=fp)
            for i in range(N) :
                print(f"{M[i]} {C[i]}",file=fp)
            if ttt+1 in goodids :
                print(N,file=fp2)
                for i in range(N) :
                    print(f"{M[i]} {C[i]}",file=fp2)


