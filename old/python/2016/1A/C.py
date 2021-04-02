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

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n = int(IN.input())
    bffs = tuple(IN.ints())
    return (n,bffs)

def solve(inp) :
    (n,bffs) = inp
    fwdgraph,revgraph = makeGraphs(n,bffs)
    ## Two choices -- either cycle or strings connected to a pair of mutual best friends
    n1,pairs = findCycles(fwdgraph,n)
    n2 = 0
    for (p1,p2) in pairs :
        k1 = traceBack(p1,p2,revgraph)
        k2 = traceBack(p2,p1,revgraph)
        n2 += k1+k2
    ans = max(n1,n2)
    return "%d" % ans

def makeGraphs(n,bffs) :
    fwdgraph = [ 0  for x in range(n+1) ]
    revgraph = [ [] for x in range(n+1) ]
    for i,x in enumerate(bffs,1) :
        fwdgraph[i] = x
        revgraph[x].append(i)
    return fwdgraph,revgraph

def findCycles(fwd,n) :
    maxCycle = 0
    pairs = []
    checklist = [False] * (n+1)
    for i in range(1,n+1) :
        if checklist[i] : continue
        locchecklist = {}
        c = 0; j = i; rerun = False
        while j not in locchecklist :
            locchecklist[j] = c
            if checklist[j] : rerun = True; break
            checklist[j] = True 
            c += 1
            j = fwd[j]
        if rerun : continue
        cyclen = c - locchecklist[j]
        if cyclen == 2 : pairs.append( (j,fwd[j]) )
        maxCycle = max(cyclen,maxCycle)
    return maxCycle,pairs

def traceBack(p1,p2,revgraph) :
    queue = [ (2,x) for x in revgraph[p1] if x != p2 ]
    best = 1
    while queue :
        (l,nn) = queue.pop()
        best = max(l,best)
        for x in revgraph[nn] : queue.append((l+1,x))
    return best

#####################################################################################################
if __name__ == "__main__" :
    doit()
