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

anscache = {}
def presolve() :
    for n in range(1,13) : anscache[n] = []
    for winner in 'PRS' :
        s = [winner]
        for n in range(1,13) :
            s = "".join(["PR" if x == "P" else "RS" if x == "R" else "PS" for x in s])
            s2 = doOrdering(s,n)
            anscache[n].append( (s2.count('P'), s2.count('R'), s2.count('S'), s2) ) 

def doOrdering(s,n) :
    a = [x for x in s ]
    for _ in range(n) :
        a = [ a[i] + a[i+1] if a[i] < a[i+1] else a[i+1] + a[i] for i in range(0,len(a),2) ]
    return a[0]

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n,r,p,s = IN.ints()
    return (n,r,p,s)
    
def solve(inp) :
    (n,r,p,s) = inp
    ansqueue = []
    for pp,rr,ss,pans in anscache[n] :
        if rr==r and pp==p and ss==s : ansqueue.append(pans)
    ansqueue.sort()
    if ansqueue : return ansqueue[0]
    else        : return "IMPOSSIBLE"
              
#####################################################################################################
if __name__ == "__main__" :
    presolve()
    doit()
