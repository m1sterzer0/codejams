import random
random.seed(8675309)

def graphGen1(n,t,chance) :
    ans = []
    for i in range(n) :
        for j in range(i+1,n) :
            if (j == i+1 and j <= t) or (random.random() < chance) :
                jj = n-1 if j == t else t if j == n-1 else j
                ans.append((i,jj))
    return ans

def graphGen2(n,t,chancearr) :
    ans = []
    for i in range(n) :
        for j in range(i+1,n) :
            if (j == i+1 and j <= t) or (random.random() < chancearr[i]*chancearr[j]) :
                jj = n-1 if j == t else t if j == n-1 else j
                ans.append((i,jj))
    return ans

def dograph(n,edges,fp) :
    for k in range(1,11) :
        print(f"{n} {len(edges)} {k}",file=fp)
        for (n1,n2) in edges :
            print(f"{n1} {n2}",file=fp)



if __name__ == "__main__" :
    with open("Dtc1.in","wt") as fp :
        print(2400,file=fp)

        ## 20 graphs with N = 10, t = 9 chance = 10%
        for i in range(20) : edges = graphGen1(10,9,0.1); dograph(10,edges,fp)
        for i in range(20) : edges = graphGen1(10,9,0.2); dograph(10,edges,fp)
        for i in range(20) : edges = graphGen1(10,9,0.3); dograph(10,edges,fp)
        for i in range(10) : edges = graphGen1(10,9,0.5); dograph(10,edges,fp)

        for i in range(20) : edges = graphGen1(20,9,0.1); dograph(20,edges,fp)
        for i in range(20) : edges = graphGen1(20,9,0.2); dograph(20,edges,fp)
        for i in range(20) : edges = graphGen1(20,9,0.3); dograph(20,edges,fp)
        for i in range(10) : edges = graphGen1(20,9,0.5); dograph(20,edges,fp)

        choices = [0.05 + x*0.01 for x in range(71)]
        for i in range(50) : chancearr = [random.choice(choices) for x in range(10)]; edges = graphGen2(10,9,chancearr); dograph(10,edges,fp)
        for i in range(50) : chancearr = [random.choice(choices) for x in range(20)]; edges = graphGen2(20,9,chancearr); dograph(20,edges,fp)



        ## 50 graphs with N = 10, t = 9 chancearr = [5% .. 75%]
        ## 50 graphs with N = 20, t = 9 chancearr = [5% .. 75%]
