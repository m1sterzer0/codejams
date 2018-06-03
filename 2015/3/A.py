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
    N,D = IN.ints()
    S0,As,Cs,Rs = IN.ints()
    M0,Am,Cm,Rm = IN.ints()
    return (N,D,S0,As,Cs,Rs,M0,Am,Cm,Rm)

## Managers always show up earlier than the employess in the list
## This means we can just process things in order
def solve(inp) :
    (N,D,S0,As,Cs,Rs,M0,Am,Cm,Rm) = inp
    minmax = [0] * N
    s = S0; m = M0; minmax[0] = (s,s)
    for i in range(1,N) :
        m = (m * Am + Cm) % Rm
        s = (s * As + Cs) % Rs
        manager = m % i
        (oldmin,oldmax) = minmax[manager]
        minmax[i] = ( min(oldmin,s),max(oldmax,s) )

    ## Now we want to find a choice for salary lower bound L
    ## for each employee, we need L to be <= MIN and L+D >= MAX
    LIntervals = [0] * (Rs+2)
    for i in range(N) :
        lmax = minmax[i][0]
        lmin = max(0,minmax[i][1]-D)
        if lmin <= lmax :
            LIntervals[lmin] += 1
            LIntervals[lmax+1] -= 1
    
    nn = 0; best = 0
    for i in range(Rs+1) :
        nn += LIntervals[i]
        best = max(best,nn)

    return "%d" % best

#####################################################################################################
if __name__ == "__main__" :
    doit(multi=True)

