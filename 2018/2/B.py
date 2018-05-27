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

import copy
maxsize = 500
anscache = [ [0] * (maxsize+1) for x in range(maxsize+1) ]
def presolve() :
    dp = [ [0] * (maxsize+1) for x in range(maxsize+1) ]
    doFirstRow(dp,maxsize)
    for maxr in range(1,33) :
        nextdp = copy.deepcopy(dp)
        columncost = maxr * (maxr+1) // 2
        for r in range(maxsize+1) :
            nummax = r // columncost
            for i in range(1,nummax+1) :
                bcost = (i)*(i-1)//2
                for b in range(bcost,maxsize+1) :
                    nextdp[r][b] = max(nextdp[r][b],i+dp[r-i*maxr][b-bcost])
        dp = nextdp
    for r in range(maxsize+1) :
        for c in range(maxsize+1) :
            anscache[r][c] = dp[r][c]

def doFirstRow(dp,maxsize) :
    lastsum = 0
    for n in range(1,33) :
        mysum = n * (n+1) // 2
        upperbnd = min(mysum,maxsize+1)
        for r in range(maxsize + 1) :
            for b in range(lastsum, upperbnd) : dp[r][b] = n-1
        lastsum = mysum
        if lastsum >= maxsize+1 : return

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    r,b = IN.ints()
    return (r,b)
    
def solve(inp) :
    (r,b) = inp
    return "%d" % anscache[r][b]

#####################################################################################################
if __name__ == "__main__" :
    presolve()
    doit()
