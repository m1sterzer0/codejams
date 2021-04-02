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
    n,k = IN.ints()
    r = [0] * n; h = [0] * n
    for i in range(n) : r[i],h[i] = IN.ints()
    return (n,k,r,h)

def solve(inp) :
    (n,k,r,h) = inp
    sidearea = [2 * math.pi * rr * hh  for rr,hh in zip(r,h) ]
    toparea  = [    math.pi * rr * rr  for rr    in r        ]
    pancakes = [ (a,b) for a,b in zip(sidearea,toparea) ]
    pancakes.sort(reverse=True)
    sumSideArea = 0 if k == 1 else sum(p[0] for p in pancakes[:k-1])
    largestTopArea = 0 if k == 1 else max(p[1] for p in pancakes[:k-1])
    syrupAreas = [ sumSideArea + p[0] + max(largestTopArea,p[1]) for p in pancakes[k-1:] ]
    ans = max(syrupAreas)
    return "%.8f" % ans

#####################################################################################################
if __name__ == "__main__" :
    doit()
