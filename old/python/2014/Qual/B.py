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
    c,f,x = IN.floats()
    return (c,f,x)

## Assume we have n farms
## We should buy the (n+1)th farm if
##     C / (2 + F*n) < X / (2 + F*n) - X / (2 + F*n + F)
## which simplifies to
#      n > X/C - 2/F -1
# or
#      n+1 > X/C - 2/F        
def solve(inp) :
    (c,f,x) = inp
    n = max(0,int(x/c-2.0/f))
    farmBuildingTime = 0.00
    for i in range(1,n+1) :
        farmBuildingTime += c / (2.0 + f * (i-1))
    cookieTime = x / (2.0 + f * n)
    return "%.8f" % (farmBuildingTime+cookieTime)

#####################################################################################################
if __name__ == "__main__" :
    doit()

