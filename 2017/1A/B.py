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
    r = list(IN.ints())
    parr = [ list(IN.ints()) for x in range(n) ]
    return (n,p,r,parr)
    
def solve(inp) :
    (n,p,r,parr) = inp

    parr2 = [0] * n
    for i in range(n) :
        parr[i].sort()
        parr2[i] = [ evaluate(r[i],parr[i][j]) for j in range(p) ]

    idxarr = [0] * n
    ans = 0

    while max(idxarr) < p :
        largestmin  = max(parr2[i][idxarr[i]][0] for i in range(n))
        smallestmax = min(parr2[i][idxarr[i]][1] for i in range(n))
        if smallestmax == 0 :
            for i in range(n) :
                r = parr2[i]
                while idxarr[i] < p and r[idxarr[i]][1] == 0 : idxarr[i] += 1
        elif (largestmin <= smallestmax) :
            ans += 1
            for i in range(n) : idxarr[i] += 1
        else :
            for i in range(n) :
                r = parr2[i]
                while idxarr[i] < p and r[idxarr[i]][1] < largestmin : idxarr[i] += 1
    return "%d" % ans

def evaluate(r,val) :
    ## Need smallest integer need 0.9*r*x <= val <= 1.1*r*x
    return (math.ceil(10*val / (11*r)), math.floor(10*val / (9*r)))

#####################################################################################################
if __name__ == "__main__" :
    doit()
