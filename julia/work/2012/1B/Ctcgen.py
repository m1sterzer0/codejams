import random
random.seed(8675309)
(fn,ntc) = ("Ctc1.in",1000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        N = 500
        s = set()
        while len(s) < 500 :
            b = random.randrange(1,100000+1)
            s.add(b)
        a = [x for x in s]
        random.shuffle(a)
        a = [500] + a
        astr = " ".join(str(x) for x in a)
        print(astr,file=fp)

