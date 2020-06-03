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

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n = int(IN.input())
    w = list(IN.ints())
    return (n,w)

def solve(inp) :
    (n,w) = inp
    inf = 1000000000000000000
    w6 = [6*x for x in w]
    ## Use simple dp, calculating the minimum weight k stack that can be made with elements <= i
    dp = list(itertools.accumulate(w,min))
    for stackSize in range(2,n+1) :
        olddp = [inf] + dp[:n]
        candidates = [ inf if x6 < odp else x + odp for x,x6,odp in zip(w,w6,olddp) ]
        dp         = list(itertools.accumulate(candidates,min))
        if dp[-1] == inf : return "%d" % (stackSize-1)
    return "%d" % n

#####################################################################################################
if __name__ == "__main__" :
    doit()

