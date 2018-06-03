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
    N,p,q,r,s = IN.ints()
    return (N,p,q,r,s)

## Managers always show up earlier than the employess in the list
## This means we can just process things in order
import bisect
def solve(inp) :
    (N,p,q,r,s) = inp
    tarr = []
    for i in range(N) :
        t = ((i*p + q) % r) + s
        tarr.append(t)
    totalt = sum(tarr)
    sumt = list(itertools.accumulate(tarr))
    sumtrev = list(itertools.accumulate(reversed(tarr)))

    ## Deal with the base cases    
    #if N == 1 :   ans = 0.00
    #elif N == 2 : ans = 1.0 * min(tarr[0],tarr[1]) / totalt
    #elif N == 3 : ans = 1.0 * min(tarr[0],tarr[1],tarr[2]) / totalt
    a,b = 0,2000000000000
    while (b-a > 1) :
        m = (a+b) // 2
        if check(m,sumt,sumtrev,totalt) : b = m
        else                            : a = m
    ans = 1.0 * (totalt - b) / totalt 
    return "%.10f" % ans

def check(v,s1,s2,totalt) :
    i1 = bisect.bisect_right(s1,v)
    i2 = bisect.bisect_right(s2,v)
    v1 = 0 if i1 == 0 else s1[i1-1]
    v2 = 0 if i2 == 0 else s2[i2-1]
    v3 = totalt-v1-v2
    if v3 > v : return False
    return True

#####################################################################################################
if __name__ == "__main__" :
    doit()

