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
    n = int(IN.input())
    return (n,)

anscache = {}
def presolve() :
    anscache[1] = 1
    q = collections.deque([(1,1)])
    while q :
        x,c = q.popleft()
        y1 = x+1
        y2 = revp1(x)
        for y in (y1,y2) :
            if y > 1e6 : continue
            if y not in anscache :
                anscache[y] = c+1
                q.append((y,c+1))

def revp1(x) :
    s = str(x)[::-1]
    i = 0
    while s[i] == '0' : i += 1
    return int(s[i:])

def solve(inp) :
    (n,) = inp
    return "%d" % anscache[n]

#####################################################################################################
if __name__ == "__main__" :
    presolve()
    doit()
