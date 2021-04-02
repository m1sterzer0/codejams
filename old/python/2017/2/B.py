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
    n,c,m = IN.ints()
    p = [0] * m
    b = [0] * m
    for i in range(m) : p[i],b[i] = IN.ints()
    return (n,c,m,p,b)

## Consider just first ticket -- like 1 car roller coaster
## Limited by either number of seats sold or number of seats sold to one person
##
## Coninue to two seat case.
## Then, in addition to the "first seat" constraints above, limited by number of tickets sold to first two seats or number of such tickets sold to one person

def solve(inp) :
    (n,c,m,p,b) = inp
    t = [ [0] * (c+1) for x in range(n+1)]
    for (pp,bb) in zip(p,b) : t[pp][bb] += 1

    ## Accumulate the tickets by position
    a = [ [0] * (c+1) for x in range(n+1)]
    a[1] = t[1]
    for pp in range(2,n+1) :
        for bb in range(1,c+1) :
            a[pp][bb] = a[pp-1][bb] + t[pp][bb]

    ## Now find the minimum number of roller coaster rides needed
    minride = 0
    for pp in range(1,n+1) :
        minride = max( minride, math.ceil( sum(a[pp]) / pp ), max(a[pp]) )

    promotions = 0
    for pp in range(1,n+1) :
        promotions += max(0, sum(t[pp]) - minride)

    return "%d %d" % (minride, promotions)

#####################################################################################################
if __name__ == "__main__" :
    doit()
