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

def getInputs(IN) :
    d,i,m,n = IN.ints()
    vals = tuple(IN.ints())
    return (d,i,m,n,vals)

def solve(inp) :
    d,i,m,n,vals = inp
    ## dp[lastidx][lastval]
    dp = [[0] * 256 for x in range(n)]
    for ii in range(n) :
        for v in range(256) :
            dp[ii][v] = doDP(d,i,m,n,vals,dp,ii,v)
    ans = min(dp[n-1][x] for x in range(256))
    return "%d" % ans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def doDP(d,i,m,n,vals,dp,ii,v) :
    ## OPTIONS:
    ##     delete ourselves
    ##     insert between the last guy and us and change ourselves
    ## We use the convention that we don't add after us -- that is the job of the next guy
    startVal = vals[ii]
    moveCost = abs(startVal - v)
    delCost  = d + (0 if ii == 0 else dp[ii-1][v])
    if delCost <= moveCost : return delCost
    if ii == 0: return moveCost  ## Special case for the first column
    if m == 0 : return min(delCost,moveCost + dp[ii-1][v]) ## Special case for m == 0 
    best = delCost
    for prev in range(256) :
        #numInserts = 0 if v == prev else 1e99 if m == 0 else (abs(v-prev)-1) // m
        numInserts = 0 if v == prev else (abs(v-prev)-1) // m
        optionCost = i*numInserts + moveCost + dp[ii-1][prev]
        best = min(best,optionCost)
    return best
    
#####################################################################################################
if __name__ == "__main__" :
    doit(multi=True)

