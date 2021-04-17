import random
random.seed(2345)
t = 100
sizeVector = [1] + [2]*10 + [3]*100 + [4]*1000
bitVectors = [
                ['0']*1 + ['1']*1,
                ['0']*3 + ['1']*1,
                ['0']*10 + ['1']*1,
                ['0']*1  + ['1']*3,
                ['0']*1  + ['1']*10,                
             ]
with open("D.in2","wt") as fp :
    print(t,file=fp)
    for i in range(t) :
        s = random.choice(sizeVector)
        bv = random.choice(bitVectors)
        print(s,file=fp)
        for i in range(s) :
            zz = "".join(random.choice(bv) for x in range(s))
            print(zz,file=fp)