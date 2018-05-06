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
    m = int(IN.input())
    recipes = [(0,0)] + [ tuple(IN.ints()) for x in range(m) ]
    inv = [0] + list(IN.ints())
    return (m,recipes,inv)

def solve(inp) :
    (m,recipes,inv) = inp
    l = 0
    r = sum(inv)+1
    while (r-l > 1) :
        mid = (r+l)//2
        if eval(m,recipes,inv,mid) : l = mid
        else                       : r = mid
    return "%d" % l

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def eval(m,recipes,inv,n) :
    linv = inv[:]
    return make(1,n,set(),recipes,linv)

def make(e,n,s,recipes,inv) :
    if e in s :                   return False
    if inv[e] >= n : inv[e] -= n; return True
    s.add(e)
    deficit = n - inv[e]; inv[e] = 0
    if not make(recipes[e][0],deficit,s,recipes,inv) : return False
    if not make(recipes[e][1],deficit,s,recipes,inv) : return False
    s.remove(e)
    return True

#####################################################################################################
if __name__ == "__main__" :
    doit()

