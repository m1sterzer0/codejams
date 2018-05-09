import collections
import functools
import heapq
import itertools
import math
import re
import sys
from fractions       import gcd
from fractions       import Fraction
from multiprocessing import Pool    
from operator        import itemgetter

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

def doit(fn=None,multi=False) :
    IN = myin(fn)
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    if (not multi) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            printOutput(tt,ans)
    else :
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            printOutput(tt,ans)

#####################################################################################################

class MinHeap(object):
  def __init__(self): self.h = []
  def __len__(self): return len(self.h)
  def __getitem__(self,i): return self.h[i]
  def push(self,x): heapq.heappush(self.h,x)
  def pop(self): return heapq.heappop(self.h)
  def empty(self) : return False if self.h else True
  def top(self) : return self.h[0]

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n,q = IN.ints()
    e = [0] * (n+1)
    s = [0] * (n+1)
    for i in range(1,n+1) : e[i],s[i] = IN.ints()
    g = {}
    for i in range(1,n+1) : g[i] = {}
    for i in range(1,n+1) : 
        t = list(IN.ints())
        for j,v in enumerate(t,1) :
            if v > 0 : g[i][j] = v
    qarr = [ tuple(IN.ints()) for x in range(q) ]
    return (n,q,e,s,g,qarr)

def solve(inp) :
    (n,q,e,s,g,qarr) = inp
    d = {}
    for i in range(1,n+1) : d[i] = {}
    for i in range(1,n+1) :
        doLocGraph(n,i,e[i],s[i],g,d)
    sp = allPairsShortestPath(n,d)
    ansarr = []
    for u,v in qarr :
        ansarr.append("%.8f" % sp[u][v])
    return " " .join(ansarr)

## Dijkstra
def doLocGraph(n,i,e,s,g,dgraph) :
    mindist = [1e99] * (n+1)
    mh = MinHeap()
    mh.push((0,i,e))
    while not mh.empty() :
        (x,nn,end) = mh.pop()
        if mindist[nn] < 1e99 : continue
        mindist[nn] = x
        for n2 in g[nn] :
            d = g[nn][n2]
            if d <= end : mh.push((x+d,n2,end-d))
    for j in range(1,n+1) :
        if i != j and mindist[j] < 1e99 : dgraph[i][j] = mindist[j] / s

## Floyd-Warshall
def allPairsShortestPath(n,d) :
    sp = [ [1e99] * (n+1) for x in range(n+1) ]
    for i in range(1,n+1) :
        for j in d[i] :
            sp[i][j] = d[i][j]

    for k in range(1,n+1) :
        for i in range(1,n+1) :
            for j in range(1,n+1) :
                sp[i][j] = min(sp[i][j],sp[i][k]+sp[k][j])

    return sp

#####################################################################################################
if __name__ == "__main__" :
    doit()
