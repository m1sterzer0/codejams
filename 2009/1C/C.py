import collections
import functools
import heapq
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
cache = {}

def getInputs(IN) :
    p,_ = IN.ints()
    qarr = tuple(IN.ints())
    return (p,qarr)

def solve(inp) :
    (p,qarr) = (inp)
    global cache
    cache = {}
    ans = lsolve(1,p,qarr)
    return "%d" % ans

def lsolve(a,b,qarr) :
    if a >= b : return 0
    if (a,b) not in cache :
        best = 1e99
        found = False    
        for c in qarr :
            if c >= a and c <= b :
                found = True
                tmp = (b-a) + lsolve(a,c-1,qarr) + lsolve(c+1,b,qarr)
                best = min(tmp,best)
        cache[(a,b)] = best if found else 0
    return cache[(a,b)]

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()
