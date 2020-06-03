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
    u = float(IN.input())
    p = IN.floats()
    return (n,k,u,p)

def solve(inp) :
    ## No way in hell I would have come up with the full solution  without reading
    ## the analysis -- playing around with nelder-mead optimization didn't yield the insight
    (n,k,u,p) = inp
    pp = list(p); pp.sort(); p = tuple(pp) 
    best = 0.00
    for i in range(n) :
        p2 = spreadImprovement(n,i,p,u)
        cand = calcProb(p2,k)
        best = max(best,cand)
    return "%.8f" % best

def calcProb(p,k) :
    dp = [0] * (k+1); dp[0] = 1.00
    olddp = [0] * (k+1)
    for pp in p :
        ppbar = 1.0 - pp
        olddp,dp = dp,olddp
        dp[0] = olddp[0] * ppbar
        for i in range(1,k) : dp[i] = pp * olddp[i-1] + ppbar * olddp[i]
        dp[k] = olddp[k] + olddp[k-1] * pp
    return dp[k] 

def spreadImprovement(n,si,p,u) :
    p2 = list(p)
    if u == 0.00 : return tuple(p2)
    for i in range (si,n) :
        targ = 1.0 if i == n-1 else p2[i+1]
        gap = targ - p[i]
        numelem = i-si+1
        if u > gap * numelem :
            for j in range(si,i+1) : p2[j] = targ
            u -= gap * numelem
        else :
            budget = u / numelem
            for j in range(si,i+1): p2[j] += budget
            return tuple(p2)
    ## Dump leftovers back on the previous entry if we can.
    ## No need to look further, as other cases of si will pick
    ## those cases up.
    if u > 0 and si > 0 :
        p2[si-1] = min(1.0,p2[si-1]+u)
    return tuple(p2)

#####################################################################################################
if __name__ == "__main__" :
    doit()
