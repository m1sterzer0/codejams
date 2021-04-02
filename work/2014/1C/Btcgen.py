import random
random.seed(8675309)

def genword() :
    wordlen = random.randrange(1,5)
    letters = [random.choice("abcdefghijklmnopqrstuvwxyz") for i in range(wordlen)]
    return "".join(letters)
    
with open("Btc1.in","wt") as fp :
    print(10000,file=fp)
    for i in range(10000) :
        n = random.randrange(5,11)
        print(f"{n}",file=fp)
        words = [genword() for i in range(n)]
        wordstr = " ".join(words)
        print(f"{wordstr}",file=fp)
