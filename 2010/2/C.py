import sys
import math
import heapq
from operator import itemgetter
class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

def createGraph(r,rarr) :
    edges = []
    for i in range(1,r) :
        (x1a,y1a,x2a,y2a) = rarr[i] 
        for j in range(0,i) :
            (x1b,y1b,x2b,y2b) = rarr[j]
            if x1b - x2a > 1 : continue ## Rectangle B is right of rectangle A
            if x1a - x2b > 1:  continue ## Rectangle A is right of Rectangle B
            if y1b - y2a > 1:  continue ## Rectangle B is below Rectange A
            if y1a - y2b > 1:  continue ## Rectangel A is below Rectangle B
            if x1b == x2a + 1 and y1b == y2a + 1  : continue ## This diagonal connection doesn't survive
            if x1a == x2b + 1 and y1a == y2b + 1  : continue ## This diagonal connection doesn't survive
            edges.append((i,j))
    return list(range(r)),edges 

def getCC(ee,sb,i) :
    cc = [i]
    sb[i] = True
    q = [i]
    while q :
        x = q.pop(0)
        for n in ee[x] :
            if sb[n] : continue
            sb[n] = True
            cc.append(n)
            q.append(n)
    return cc

def getConnectedComponents(r,rarr,nodes,edges) :
    ee = [ [] for x in range(r) ]
    for (i,j) in edges : 
        ee[i].append(j); ee[j].append(i)
    ccs = []
    sb = [False] * r
    for i in range(r) :
        if sb[i] : continue
        cc = getCC(ee,sb,i)
        rects = [ rarr[x] for x in cc ]
        ccs.append(rects)
    return ccs

def getCCStats(cc) :
    diags = list(x1+y1 for (x1,y1,x2,y2) in cc)
    maxxs = list(x2    for (x1,y1,x2,y2) in cc)
    maxys = list(y2    for (x1,y1,x2,y2) in cc)
    return min(diags),max(maxxs),max(maxys)

def solve(inp) :
    (r,rarr) = inp
    nodes,edges = createGraph(r,rarr)
    ccon = getConnectedComponents(r,rarr,nodes,edges)
    best = 1
    for cc in ccon :
        minDiag,maxx,maxy = getCCStats(cc) 
        lifetime = maxx + maxy - minDiag + 1
        best = max(best,lifetime)
    return best

def getInputs(IN) :
    r = int(IN.input())
    rarr = [ tuple(IN.ints()) for x in range(r) ]
    return (r,rarr)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %d" % (tt,ans))
