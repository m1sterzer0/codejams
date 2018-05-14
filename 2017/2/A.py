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
    n,p = IN.ints()
    g = tuple(IN.ints())
    return (n,p,g)

def solve(inp) :
    (n,p,g) = inp
    if p == 2 : ans = solve2(g)
    elif p == 3 : ans = solve3(g)
    else        : ans = solve4(g)
    return "%d" % ans

def solve2(g) :
    ## Do all of the even numbered groups first.  They will all get fresh chocolate
    gg0 = len([ x for x in g if (x % 2) == 0 ])
    gg1 = len([ x for x in g if (x % 2) == 1 ])

    return gg0 + math.ceil(0.5*gg1)

def solve3(g) :
    ## First do the multiples of 3
    gg0 = len([ x for x in g if (x % 3) == 0 ])
    gg1 = len([ x for x in g if (x % 3) == 1 ])
    gg2 = len([ x for x in g if (x % 3) == 2 ])

    a = min(gg1,gg2)
    b = max(gg1,gg2) - a
    return gg0 + a + math.ceil(b/3)

def solve4(g) :
    gg0 = len([ x for x in g if (x % 4) == 0 ])
    gg1 = len([ x for x in g if (x % 4) == 1 ])
    gg2 = len([ x for x in g if (x % 4) == 2 ])
    gg3 = len([ x for x in g if (x % 4) == 3 ])
    a = min(gg1,gg3)
    b = max(gg1,gg3) - a 
    ans = gg0     ## Do the multiples of 4 first
    ans += a      ## Pair up the 1s and the 3s
    ans += gg2//2 ## Pair up the 2s with themselves
    if (gg2 % 2 == 0) :
        ans += math.ceil(0.25*b)  ## Sequences of 4
    elif (b >= 2) :
        ans += 1
        b -= 2
        ans += math.ceil(0.25*b)
    else :
        ans += 1
    return ans

#####################################################################################################
if __name__ == "__main__" :
    doit()
