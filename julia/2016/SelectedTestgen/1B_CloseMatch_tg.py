import random
random.seed(2345)
t = 1000
with open("B.in2","wt") as fp :
    print(f"{t}",file=fp)
    for i in range(t) :
        digits = [random.choice("0123456789??????????") for x in range(6)]
        dr = random.random()
        if dr < 0.1 : c,j = digits[0],digits[1]
        elif dr < 0.3 : c,j = "".join(digits[:2]),"".join(digits[2:4])
        else :          c,j = "".join(digits[:3]),"".join(digits[3:6])
        print(f"{c} {j}",file=fp)
t = 10000
with open("B.in3","wt") as fp :
    print(f"{t}",file=fp)
    numdigits = [1,2,3,4,5,6] + [7,8,9] * 3 + [10,11,12,13,14,15,16,17,18] * 5
    for i in range(t) :
        ndig = random.choice(numdigits)
        choicestr = random.choice(["0123456789?????",
                                   "0123456789??????????",
                                   "0123456789????????????????????",
                                   "0123456789??????????????????????????????"])
        c = "".join([random.choice(choicestr) for x in range(ndig)])
        j = "".join([random.choice(choicestr) for x in range(ndig)])
        print(f"{c} {j}",file=fp)