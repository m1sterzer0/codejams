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
        with Pool(processes=2) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            printOutput(tt,ans)

#####################################################################################################

maxG = 9
parentsWithParents = collections.defaultdict(list)
def presolve() :
    for i in range(1,maxG+1) :
        par = enumeratePartitionsLen(i)
        #print("i:",i,"par:",par)
        for p in par :
            d = decay(p)
            tp = tuple(p)
            td = tuple(d)
            if tp != td : parentsWithParents[tuple(d)].append(tuple(p))

def enumeratePartitionsLen(i) :
    p = []
    for k in range(1,i+1) :
        p = p + enumeratePartitions(i,k)
    return p

def decay(p) :
    ans = [0] * len(p)
    for x in p :
        if x > 0 : ans[x-1] += 1
    #print("decay p:",p,"ans:",ans) 
    return ans

@functools.lru_cache(maxsize=None)
def enumeratePartitions(l,k) :
    p = []
    if l == 1 : 
        p.append([k]) 
    else :
        for i in range(0,k+1) :
            p2 = enumeratePartitions(l-1,k-i)
            for pp in p2 :
                p.append([i] + pp)
    return p

@functools.lru_cache(maxsize=None)
def countParents(tt) :
    if sum(tt) > len(tt) : return 0
    num = math.factorial(len(tt))
    denom = math.factorial(len(tt)-sum(tt)) ## Number of zeros to place
    for t in tt : denom *= math.factorial(t)
    return num // denom

selfdecay = set([(1,), (1,0), (1,0,0), (1,0,0,0), (1,0,0,0,0), (1,0,0,0,0,0), (1,0,0,0,0,0,0), (1,0,0,0,0,0,0,0), (1,0,0,0,0,0,0,0,0)] )
@functools.lru_cache(maxsize=None)
def countAncestors(tt) :
    ans = 1
    ans += countParents(tt)
    if tt in selfdecay: ans -= 1
    for p in parentsWithParents[tt] :
        ans -= 1
        ans += countAncestors(p)
    return ans
         
def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    s = tuple(int(x) for x in IN.input().rstrip())
    return (s,)

def solve(inp) :
    (s,) = inp
    t = tuple(int(x) for x in s)
    ans = countAncestors(t)
    return "%d" % ans

#####################################################################################################
if __name__ == "__main__" :
    presolve()
    doit()

