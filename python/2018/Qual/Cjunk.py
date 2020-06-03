import random
random.seed(1)

def gopher(x,y) :
    return (x + random.randint(-1,1), y + random.randint(-1,1))

def printScoreboard(scoreboard) :
    for x in range(30) :
        row = [ "X" if scoreboard[x][j] else "." for j in range(30) ]
        print("".join(row))


def doit(dbg=False) :
    trials = 0
    scoreboard = [[False] * 30 for x in range(30)]
    trials = 0
    (xb,yb) = gopher(2,2); trials += 1; scoreboard[xb][yb] = True
    minx,miny = xb,yb
    maxx,maxy = xb+9,yb+19
    ## Try the stupid way first
    for x in range(minx,minx+10) :
        xx = x + 1 if x + 1 < maxx else x if x < maxx else x-1
        for y in range(miny,miny+20) :
            while not scoreboard[x][y] :
                yy = y+1 if y+1 < maxy else y if y < maxy else y-1
                (xb,yb) = gopher(xx,yy); trials += 1; scoreboard[xb][yb] = True
    if dbg : print(trials); printScoreboard(scoreboard); print("")
    return trials

doit(True)
doit(True)
doit(True)
doit(True)
doit(True)
doit(True)
#for i in range(1000) :
#    x = doit(); print(x)
        