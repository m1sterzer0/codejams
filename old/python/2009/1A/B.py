import collections
import functools
import heapq
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

class minheap(object) :
    def __init__(self) : self.h = []
    def push(self,a)   : heapq.heappush(self.h,a)
    def pop(self)      : return heapq.heappop(self.h)
    def top(self)      : return self.h[0]
    def empty(self)    : return False if self.h else True

def getInputs(IN) :
    n,m = IN.ints()
    s = [ [0] * m for x in range(n)]
    w = [ [0] * m for x in range(n)]
    t = [ [0] * m for x in range(n)]
    for i in range(n) :
        buf = tuple(IN.ints())
        s[i] = buf[0::3]
        w[i] = buf[1::3]
        t[i] = buf[2::3]
    return (n,m,s,w,t)

def solve(inp) :
    (n,m,ss,ww,tt) = inp
    h = minheap(); d = {}; s = set()
    h.push((0,(n-1,0,'S','W')))
    while not h.empty():
        (dist,node) = h.pop()
        if node in s : continue
        d[node] = dist; s.add(node)
        conn = getConnections(node,n,m)
        for c in conn :
            if c in s : continue
            dd = calcDist(node,c,dist,n,m,ss,ww,tt)
            #print("DEBUG DIJKSTRA:",c,dd)
            h.push((dd,c))
    return "%d" % d[(0,m-1,'N','E')]

def calcDist(node,c,dist,n,m,s,w,t) :
    #print("DEBUG calcDist",node,c,dist,n,m,s,w,t)
    (y1,x1,ns1,ew1) = node
    (y2,x2,ns2,ew2) = c
    if y1 != y2 or x1 != x2 : return dist + 2
    (ls,nextl) = getLight(dist,s[y1][x1],w[y1][x1],t[y1][x1])
    if ns1 != ns2 and ls == 'NS' or ew1 != ew2 and ls == "EW" : return dist + 1
    return nextl+1

def getLight(d,s,w,t) :
    #print("DEBUG getLight",d,s,w,t)
    firstNS = t % (s + w)
    firstNS -= (s + w) ## Guarantees that firstNS is non-positive so d - firstNS will be non-negative
    offset = (d - firstNS) % (s + w)
    if offset < s : return 'NS', d + (s - offset)
    else          : return 'EW', d + (s + w - offset)

def getConnections(node,n,m) :
    (y,x,ns,ew) = node
    connections = []
    if (ns == 'S') :
        connections.append((y,x,'N',ew))
        if y != n-1 : connections.append((y+1,x,'N',ew))
    else :
        connections.append((y,x,'S',ew))
        if y != 0 : connections.append((y-1,x,'S',ew))

    if (ew == 'W') :
        connections.append((y,x,ns,'E'))
        if x != 0 : connections.append((y,x-1,ns,'E'))
    else :
        connections.append((y,x,ns,'W'))
        if x != m-1 : connections.append((y,x+1,ns,'W'))
    return connections

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()

