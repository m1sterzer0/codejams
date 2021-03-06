
import random
random.seed(8675309)
(fn,ntc) = ("Dtc1.in",1000000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        R = random.randrange(3,10+1)
        C = random.randrange(3,10+1)
        maxcaves = min(10,(R-2)*(C-2))
        numcaves = random.randrange(1,maxcaves+1)
        board = [["." for x in range(C)] for y in range(R)]
        for x in range(C): board[0][x] = '#'; board[R-1][x] = '#'
        for x in range(R): board[x][0] = '#'; board[x][C-1] = '#'
        for c in range(numcaves) :
            (xx,yy) = (0,0)
            while board[xx][yy] != '.' :
                xx = random.randrange(1,R)
                yy = random.randrange(1,C)
            board[xx][yy] = str(c)
        wallpercentage = 0.90 * random.random()
        for x in range(R) :
            for y in range(C) :
                if board[x][y] == '.' and random.random() < wallpercentage :
                    board[x][y] = "#"
        print(f"{R} {C}",file=fp)
        for x in range(R) :
            print("".join(board[x]),file=fp)