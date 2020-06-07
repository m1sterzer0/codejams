import random
random.seed(2345)

for (fn,tt,m,c,r,s,t) in [("D.in2",100, 899, 30, 30, 10, 10),
                          ("D.in3",100,9999,100,100,100,100),
                          ("D.in4",100,9999,100,100,62,62),
                          ("D.in5",100,9999,100,100,70,70) ] :
    with open(fn,"wt") as fp :
        print(tt,file=fp)
        for _t in range(tt) :
            print(f"{c} {r} {m}",file=fp)

            ## Should add some mazes, but for now, just random walls
            gr = [["."] * c for i in range(r)]
            wallprob = random.uniform(0.0,0.6)
            for i in range(r) :
                for j in range(c) :
                    if random.random() < wallprob :
                        gr[i][j] = '#'
            squares = []
            for i in range(r) :
                for j in range(c) :
                    squares.append((i,j))
            random.shuffle(squares)
            for i in range(s) :
                gr[squares[i][0]][squares[i][1]] = 'S'
            for j in range(s,s+t) :
                gr[squares[j][0]][squares[j][1]] = 'T'
            for i in range(r) :
                ss = "".join(gr[i])
                print(ss,file=fp)
    

