
#################################################################################
## Lets do 4 stacks of 3 cards
#################################################################################
import random
random.seed(2345)

cards = []
for i in range(1,13+1) :
    for j in range(1,4+1) :
        cards.append((i,j))

with open("E.in2","wt") as fp :
    print(1200,file=fp)
    for dig in [2,3,4] :
        for tt in range(100) :
            random.shuffle(cards)
            b1,b2,b3,b4 = [dig],[dig],[dig],[dig]
            for i in range(dig) :
                b1 += list(cards[4*i])
                b2 += list(cards[4*i+1])
                b3 += list(cards[4*i+2])
                b4 += list(cards[4*i+3])
            print(" ".join(str(x) for x in b1),file=fp)
            print(" ".join(str(x) for x in b2),file=fp)
            print(" ".join(str(x) for x in b3),file=fp)
            print(" ".join(str(x) for x in b4),file=fp)
    print(300,file=fp)
    for i in range(300) :
        C = 2 if i < 100 else 3 if i < 200 else 4
        N = 4
        print(f"{N} {C}", file=fp)
        print(" ".join(str(x) for x in range(4*i,4*i+4)),file=fp)





