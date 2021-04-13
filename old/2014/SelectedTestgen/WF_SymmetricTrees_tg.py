import random
random.seed(8675309)

with open("Ctc1.in","wt") as fp :
    numtc = 1000
    print(numtc,file=fp)
    treesizes = [x for x in range(2,12+1)]
    #treesizes = [x for x in range(2,12+1)] + [100,300,1000,3000,10000]
    for t in range(numtc) :
        n = random.choice(treesizes)
        print(n,file=fp)
        colors = random.choice([['A'],['A','B'],['A','B','C']])
        mycolors = [random.choice(colors) for x in range(n)]
        for c in mycolors :
            print(c,file=fp)
        nodes = [x for x in range(1,n+1)]
        random.shuffle(nodes)
        edges = []
        for i in range(1,n) :
            j = random.randrange(i)
            edges.append((nodes[i],nodes[j]))
        for (n1,n2) in edges:
            print(f"{n1} {n2}", file=fp)

