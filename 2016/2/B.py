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
    p = tuple(IN.floats())
    return n,k,p
    
def solve(inp) :
    (n,k,p) = inp
    pp = list(p)
    pp.sort()

    ## You want some of them from one end, and the rest from the other end
    best = 0.00
    for lower in range(k+1) :
        if lower == k : myp = pp[0:lower]
        else : upp = -k+lower; myp = pp[0:lower] + pp[upp:]
        assert len(myp) == k
        ans = doProb(myp,k)
        best = max(best,ans)
    return "%.8f" % best

def doProb(myp,k) :
    kd2 = k // 2
    dp = [ [0] * (kd2+1) for x in range(k+1) ]
    dp[0][0] = 1.0
    for i,p in enumerate(myp,1) :
        dp[i][0] = dp[i-1][0] * (1-p)
        for j in range(1,kd2+1) :
            dp[i][j] = dp[i-1][j] * (1-p) + dp[i-1][j-1] * p
    return dp[k][kd2]

#####################################################################################################
if __name__ == "__main__" :
    doit()
