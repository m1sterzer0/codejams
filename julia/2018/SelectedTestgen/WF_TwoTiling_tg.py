import random
random.seed(8675309)
tiles = [1,3,7,11,15,23,27,30,31,47,63,79,94,95,111,121,
         122,123,124,125,126,127,186,187,189,191,239,247,
         254,255,367,381,383,495,511]

def genstr(tv) :
    s = ""
    for i in range(9) :
        s += "@" if tv & 1 else "."
        tv = (tv >> 1)
    return s

with open ("Btc1.in","wt") as fp :
    print(35*34 // 2, file=fp)
    for i in range(35) :
        for j in range(i+1,35) :
            s1 = genstr(tiles[i])
            s2 = genstr(tiles[j])
            if random.random() > 0.5 : (s1,s2) = (s2,s1)
            print(s1[0:3]+" "+s2[0:3],file=fp)
            print(s1[3:6]+" "+s2[3:6],file=fp)
            print(s1[6:9]+" "+s2[6:9],file=fp)
            print("",file=fp)

            
