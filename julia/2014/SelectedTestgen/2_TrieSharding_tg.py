import random
random.seed(8675309)

with open("Dtc1.in","wt") as fp :
    t = 10000
    print(t,file=fp)
    for i in range(t) :
        M = random.randrange(1,8+1)
        N = random.randrange(1,min(4,M)+1)
        print(f"{M} {N}",file=fp)
        letters = random.choice(["A","AB","ABC","ABCD"])
        words = []
        for j in range(M) :
            word = ""
            while word == "" or word in words :
                wlen = random.randrange(1,11)
                word = "".join([random.choice(letters) for k in range(wlen)])
            words.append(word)
            print(word,file=fp)

        

