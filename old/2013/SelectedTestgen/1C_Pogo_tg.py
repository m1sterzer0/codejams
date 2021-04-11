
import random
random.seed(8675309)
(fn,ntc) = ("Btc1.in",101*101-1)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for x in range(-50,50+1) :
        for y in range(-50,50+1) :
            if x == 0 and y == 0 : continue
            print(f"{x} {y}",file=fp)
