import random
random.seed(2345)

### m rows by n columns.  x <--> i <--> n, y <--> j <--> m
def makeMaze(m,n) :
    graph = [[{'N':True,'S':True,'E':True,'W':True} for x in range(n)] for y in range(m)]
    nonVisited = set([(x,y) for x in range(n) for y in range(m)])
    nonVisited.remove((0,0))
    nv = 1
    ntot = m*n
    cellStack = []
    (i,j) = (0,0)
    while nv < ntot:
        neighbors = []
        if i > 0   and (i-1,j) in nonVisited : neighbors.append((i-1,j))
        if i < n-1 and (i+1,j) in nonVisited : neighbors.append((i+1,j))
        if j > 0   and (i,j-1) in nonVisited : neighbors.append((i,j-1))
        if j < m-1 and (i,j+1) in nonVisited : neighbors.append((i,j+1))
        if not neighbors:
            (i,j) = cellStack.pop()
        else :
            (ni,nj) = random.choice(neighbors)
            if   ni > i : graph[j][i]['E'] = False; graph[nj][ni]['W'] = False
            elif ni < i : graph[j][i]['W'] = False; graph[nj][ni]['E'] = False
            elif nj > j : graph[j][i]['S'] = False; graph[nj][ni]['N'] = False
            elif nj < j : graph[j][i]['N'] = False; graph[nj][ni]['S'] = False
            cellStack.append((ni,nj))
            (i,j) = (ni,nj)
            nonVisited.remove((i,j))
            nv += 1
    return graph

def buildCharMaze(m,n,yscale,xscale) :
    gr = makeMaze(m,n)
    totalX = 2 + (2 * n - 1) * xscale
    totalY = 2 + (2 * m - 1) * yscale
    gr2 = [['#'] * totalX for y in range(totalY)]
    y = 1
    for j in range(m):
        x = 1
        for i in range(n) :
            for k in range(xscale) :
                for l in range(yscale) :
                    gr2[y+l][x+k] = "."
            if not gr[j][i]['E'] :
                for k in range(xscale) :
                    for l in range(yscale) :
                        gr2[y+l][x+xscale+k] = "."
            if not gr[j][i]['S'] :
                for k in range(xscale) :
                    for l in range(yscale) :
                        gr2[y+yscale+l][x+k] = "."
            x += 2 * xscale
        y += 2 * yscale
    gr2[1][1] = 'S'
    gr2[totalY-2][totalX-2] = 'F'
    return gr2

import queue
def solveMyMaze(gr,st,en) :
    (i,j) = st
    visited = set()
    q = queue.Queue()
    q.put((0,i,j))
    while not q.empty() :
        (d,i,j) = q.get()
        if (i,j) in visited : continue
        visited.add((i,j))
        #print(f"DEBUG: (d,i,j)=({d},{i},{j})")
        if (i,j) == en : return d
        if gr[j][i+1] in "F." : q.put((d+1,i+1,j))
        if gr[j][i-1] in "F." : q.put((d+1,i-1,j))
        if gr[j+1][i] in "F." : q.put((d+1,i,j+1))
        if gr[j-1][i] in "F." : q.put((d+1,i,j-1))
    return -1

if __name__ == "__main__" :
    with open("D.in2","wt") as fp :
        t = 100
        print(t,file=fp)
        for tt in range(t) :
            xscale = random.choice([1,2])
            yscale = random.choice([1,2])
            n = random.randrange(4,(38+xscale) // (2*xscale) + 1)
            m = random.randrange(4,(38+yscale) // (2*yscale) + 1)
            gr = buildCharMaze(m,n,xscale,yscale)
            sizeY = len(gr)
            sizeX = len(gr[0])
            st = (1,1)
            en = (sizeX-2,sizeY-2)
            mindist = en[0]-st[0]+en[1]-st[1]
            curdist = solveMyMaze(gr,st,en)
            d = min(mindist+2,curdist)
            print(f"{sizeY} {sizeX} {d}",file=fp)
            for a in gr : print("".join(a),file=fp)
