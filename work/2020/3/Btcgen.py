
import random
random.seed(8675309)
ntc = 1000
goodids = [14]
with open("Btc1.in",'wt') as fp :
    with open("Btc1b.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodids),file=fp2)
        for ttt in range(ntc) :
            K = random.randrange(2,10+1)
            N = random.randrange(2,K+1)
            l = [x for x in range(0,K)]
            random.shuffle(l)
            l2 = l[0:N]
            l2.sort()
            temps = set()
            while len(temps) < N :
                t = random.randrange(184,330+1)
                temps.add(t)
            ltemps = [x for x in temps]
            random.shuffle(ltemps)
            l1 = f"{K} {N}"
            l2 = " ".join([str(x) for x in l2])
            l3 = " ".join([str(x) for x in ltemps])
            print(l1,file=fp)
            print(l2,file=fp)
            print(l3,file=fp)
            if ttt+1 in goodids :
                print(l1,file=fp2)
                print(l2,file=fp2)
                print(l3,file=fp2)




