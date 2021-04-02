
import random
random.seed(8675309)
(fn,ntc) = ("Btc1.in",10000)
goodids = [1302]
with open(fn,'wt') as fp :
    with open("Btc2.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodids),file=fp2)
        for i in range(ntc) :
            S = random.randrange(2,5+1)
            tsm1 = 2*S-1
            moves = []
            for x in range(1,2*S) :
                for y in range(1,2*S) :
                    if x-y >= S or y-x >= S : continue
                    moves.append((x,y))
            M = 0 if random.random() < 0.01 else len(moves) if len(moves) < 100 else 100
            random.shuffle(moves)
            if len(moves) > M: moves = moves[0:M]
            print(f"{S} {M}",file=fp)
            for (a,b) in moves : print(f"{a} {b}",file=fp)
            if i+1 in goodids :
                print(f"{S} {M}",file=fp2)
                for (a,b) in moves : print(f"{a} {b}",file=fp2)

