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
    (n,v,xx) = IN.strs(); n = int(n); v = float(v); xx = float(xx)
    r = [0] * n; c = [0] * n
    for i in range(n) :
        r[i],c[i] = IN.floats()
    return (n,v,xx,r,c)

def solve(inp) :
    (n,v,xx,r,c) = inp
    #print(n,v,xx,r,c)
    possible,rate = solveRate(n,v,xx,r,c)
    if not possible : return "IMPOSSIBLE"
    return "%.8f" % (v / rate)

def solveRate(n,v,xx,r,c) :
    eps = 1e-10
    f = [ (x,y) for x,y in zip(c,r) ]
    f.sort()
    f2 = []
    lastc = f[0][0]; lastr = 0
    for cc,rr in f :
        if cc == lastc : lastr += rr
        else : f2.append( (lastc,lastr) ); lastc,lastr = cc,rr
    f2.append( (lastc,lastr) )

    if xx < f[0][0] or xx > f[-1][0] : return False, 0.1

    sumrc = 0; sumr = 0
    for cc,rr in f2 :
        newsumrc = sumrc + rr*cc
        newsumr = sumr + rr
        if (1-eps) * xx < newsumrc / newsumr < (1+eps) * xx : return True,newsumr
        elif xx < newsumrc / newsumr :
            rate = ((sumrc) - (sumr * xx)) / (xx-cc)
            return True, (sumr+rate)
        sumrc,sumr = newsumrc,newsumr

    for cc,rr in f2[:-1] :
        newsumrc = sumrc - rr*cc
        newsumr = sumr - rr
        if (1-eps) * xx < newsumrc / newsumr < (1+eps) * xx : return True,newsumr
        elif xx < newsumrc / newsumr :
            rate = ((sumrc) - (sumr * xx)) / (cc-xx)
            return True,(sumr-rate)
        sumrc,sumr = newsumrc,newsumr

    return True,sumr
        

#####################################################################################################
if __name__ == "__main__" :
    doit()
