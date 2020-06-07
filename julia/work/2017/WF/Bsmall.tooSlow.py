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
    print("Case #%d: %d %d" % (tt,ans[0],ans[1]))

def getInputs(IN) :
    S,C = IN.ints()
    O = [0] * C
    V = [0] * C
    for i in range(C) :
        aa = IN.input().rstrip().split()
        O[i] = aa[0]
        V[i] = int(aa[1])
    return (S,C,O,V)

def tadd(a,b) : return (a[0]+b*a[1],a[1])
def tsub(a,b) : return (a[0]-b*a[1],a[1])
def tmul(a,b) : return (a[0]*b,a[1])
def tdiv(a,b) : return (a[0],a[1]*b) if b > 0 else (-a[0],-a[1]*b)
def tgt(a,b) :  return b[1]*a[0] > a[1]*b[0]
def tlt(a,b) :  return b[1]*a[0] < a[1]*b[0]

def solve(inp) :
    (S,C,O,V) = inp
    maxbm = 1<<C-1
    minvals = [(1,1) for i in range(1<<C)]
    maxvals = [(1,1) for i in range(1<<C)]
    minvals[0] = (S,1)
    maxvals[0] = (S,1)
    for i in range(1,1<<C) :
        first = True
        for j in range(C) :
            bm = 1 << j
            if i & bm == 0: continue
            residual = i & ~bm
            v1,v2 = (1,1),(1,1)
            if O[j] == "+" :
                v1 = tadd(maxvals[residual],V[j])
                v2 = tadd(minvals[residual],V[j])
            elif O[j] == "-" :
                v1 = tsub(maxvals[residual],V[j])
                v2 = tsub(minvals[residual],V[j])
            elif O[j] == "*" :
                v1 = tmul(maxvals[residual],V[j])
                v2 = tmul(minvals[residual],V[j])
            elif O[j] == "/" :
                v1 = tdiv(maxvals[residual],V[j])
                v2 = tdiv(minvals[residual],V[j])
            (maxv,minv) = (v1,v2) if tgt(v1,v2) else (v2,v1)
            if first :
                maxvals[i] = maxv
                minvals[i] = minv
                first = False
            else :
                maxvals[i] = maxvals[i] if tgt(maxvals[i],maxv) else maxv
                minvals[i] = minvals[i] if tlt(minvals[i],minv) else minv
    f = Fraction(maxvals[(1<<C)-1][0],maxvals[(1<<C)-1][1])
    return (f.numerator,f.denominator)     

#####################################################################################################
if __name__ == "__main__" :
    doit()
