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
    r,t = IN.ints()
    return (r,t)

## A ring of inner radius r is pi * ((r+1)^2 - r^2) = pi * (2r+1) cm^2 which takes (2r+1) milliliters of paint
## k rings of paint will take (2r+1) + (2r+5) + (2r+9) + ... + (2r+4*k-3) = 2rk + (2k^2-k) milliliters of paint
## We need to find the maximal k such that (2k^2-k) + 2rk <= t
## Floating point is not quite precise enough here, so we just do binary search on k

def solve(inp) :
    (r,t) = inp
    a,b = 0,1000000000000000000
    while (b-a) > 1 :
        k = (b+a) // 2
        paintNeeded = 2*r*k + 2*k*k - k
        if t >= paintNeeded : a = k
        else                : b = k
    return "%d" % a

#####################################################################################################
if __name__ == "__main__" :
    doit()

