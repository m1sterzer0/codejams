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

class unionFind(object) :
    def __init__(self) :
        self.weight = {}
        self.parent = {}
        self.size   = {}
    def insert(self,x) : self.find(x)
    def insertList(self,l) :
        for x in l : self.find(x)
    def find(self,x) :
        if x not in self.parent :
            self.weight[x] = 1
            self.parent[x] = x
            return x
        stk = [x]; par = self.parent[stk[-1]]
        while par != stk[-1] :
            stk.append(par)
            par = self.parent[stk[-1]]
        for i in stk : self.parent[i] = par
        return par
    def union(self,x,y) :
        px = self.find(x)
        py = self.find(y)
        if px != py :
            wx = self.weight[px]
            wy = self.weight[py]
            if wx >= wy : self.weight[px] = wx + wy; del self.weight[py]; self.parent[py] = px
            else        : self.weight[py] = wx + wy; del self.weight[px]; self.parent[px] = py
    def nodeSize(self,x) :
        px = self.find(x)
        return self.weight[px]

def getInputs(IN) :
    h,w = IN.ints()
    topo = tuple(tuple(IN.ints()) for x in range(h))
    return (h,w,topo)

def solve(inp) :
    (h,w,topo) = inp
    uf = unionFind()

    ## Insert all of those nodes into the graph
    for y in range(h) :
        for x in range(w) :
            uf.find((y,x))

    ## Merge every node with the node it flows into
    for y in range(h) :
        for x in range(w) :
            mymin = topo[y][x]; target=(y,x)
            if y != 0   and topo[y-1][x] < mymin : mymin,target = topo[y-1][x],(y-1,x) #North
            if x != 0   and topo[y][x-1] < mymin : mymin,target = topo[y][x-1],(y,x-1) #West
            if x != w-1 and topo[y][x+1] < mymin : mymin,target = topo[y][x+1],(y,x+1) #East
            if y != h-1 and topo[y+1][x] < mymin : mymin,target = topo[y+1][x],(y+1,x) #South
            uf.union((y,x),target)

    ans = [ []  for x in range(h) ]
    letters = 'abcdefghijklmnopqrstuvwxyz'
    nextIdx = 0
    parentMap = {}
    for y in range(h) :
        for x in range(w) :
            p = uf.find((y,x))
            if p not in parentMap : parentMap[p] = letters[nextIdx]; nextIdx += 1
            ans[y].append(parentMap[p])
    return ans

def printOutput(tt,ans) :
    #print("Case #%d: %s" % (tt,ans))
    print("Case #%d:" % (tt,))
    for r in ans : print(" ".join(r))

#####################################################################################################
if __name__ == "__main__" :
    doit()
