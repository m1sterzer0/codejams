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
    ds,p = IN.strs()
    d = int(ds) 
    return (d,p)

def solve(inp) :
    (d,p) = inp
    if p.count('S') > d : return "IMPOSSIBLE"
    a = parse(p)
    mult = 1; dmg = 0
    for n in a : dmg += mult*n; mult *= 2
    mult /= 2
    swaps = 0
    for i in range(len(a)-1,-1,-1) :
        if dmg - mult // 2 * a[i] > d :
            dmg -= mult // 2 * a[i]
            swaps += a[i]
            a[i-1] += a[i]
            a[i] = 0
            mult = mult // 2
        else :
            mult =  mult //2
            while dmg > d : dmg -= mult; a[i] -= 1; a[i-1] += 1; swaps += 1
            return str(swaps)

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def parse(p) :
    cnt = p.count('C')
    a = [0] * (cnt+1)
    idx = 0
    for c in p :
        if c == 'S' : a[idx] += 1
        else        : idx += 1
    return a

#####################################################################################################
if __name__ == "__main__" :
    doit()
