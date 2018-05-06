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
    c,d = IN.ints()
    p = [0] * c; v = [0] * c
    for i in range(c) :
        p[i],v[i] = IN.ints()
    return (c,d,p,v)

def solve(inp) :
    (c,d,p,v) = inp
    ## Bin search on time
    a,b = 0,1e12  ## Max distance someone should have to walk is bounded by 1e6 * 1e6
    while (b-a) > 1e-8 and 2*(b-a)/(b+a) > 1e-8 :
        m = (a+b) / 2
        if check(m,c,d,p,v) : (a,b) = (a,m)
        else                : (a,b) = (m,b)
    return "%.8f" % (0.5*(a+b))

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def check(t,c,d,p,v) :
    #print("DBG: Checking:",t)
    leftmax = -1e99
    for pp,vv in zip(p,v) :
        pa = pp-t; pb = pp+t
        leftloc = pa if pa >= leftmax+d else leftmax+d
        rightloc = leftloc + (vv-1)*d
        if pb < rightloc : return False
        leftmax = rightloc
    return True 

#####################################################################################################
if __name__ == "__main__" :
    doit()
