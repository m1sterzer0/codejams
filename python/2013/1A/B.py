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
    e,r,n = IN.ints()
    v = list(IN.ints())
    return (e,r,n,v)

## For each activity taken in order
##     -- If there is no better activity following us, then spend everything
##     -- If there is a better activity following us, then only spend as much on the current activity so we won't
##        waste energy.
##     -- We just need to know in how many days will we hit another maximum, we can use stock span algorithm for this (in reverse order)

def solve(inp) :
    (e,r,n,v) = inp
    energy = e
    value = 0
    maxDuration = localMaxDuration(v)
    for i,x in enumerate(v) :
        md = maxDuration[i]
        nextBest = i+md
        energyToSpend = energy if nextBest >= n else energy + md * r - e
        if energyToSpend < 0 : energyToSpend = 0
        if energyToSpend > energy : energyToSpend = energy
        value += energyToSpend * x
        energy = energy - energyToSpend + r
        if energy > e : energy = e  ## Poorly constrained problem, sometimes r > e
    return str(value)

def stockSpan(v):
    span = [0] * len(v)
    s = []
    for i,x in enumerate(v) :
        while (s and x >= s[-1][1]) : s.pop()
        span[i] = i+1 if not s else i - s[-1][0]
        s.append((i,x))
    return span

def localMaxDuration(v) :
    vrev = list(reversed(v))
    spanrev = stockSpan(vrev)
    span = list(reversed(spanrev))
    return span
    
#####################################################################################################
if __name__ == "__main__" :
    doit()

