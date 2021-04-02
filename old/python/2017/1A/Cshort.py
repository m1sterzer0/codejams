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
    hd,ad,hk,ak,b,d = IN.ints()
    return (hd,ad,hk,ak,b,d) 

def solve(inp) :
    (hd,ad,hk,ak,b,d) = inp
    atk1 = max(ak-d,0)
    atk2 = max(ak-2*d,0)
    canKillIn1 = (hk <= ad)
    canKillIn2 = (hk <= max(2*ad,ad+b))
    if atk1 >= hd      and not canKillIn1 : return "IMPOSSIBLE"
    if atk1+atk2 >= hd and not canKillIn2 : return "IMPOSSIBLE"
    t1 = solveOffense(hk,ad,b)
    t2 = solveDefense(t1,hd,ak,d)
    return "%d" % t2

def solveOffense(h,a,b) :
    best = math.ceil(h/a)
    if b == 0 : return best
    if b*h <= a*a : return best
    opt = int((math.sqrt(b*h)-a) / b)
    for x in (opt-1,opt,opt+1,opt+2) :
        if x <= 0 : continue
        cand = x + math.ceil(h/(a + b * x))
        best = min(best,cand)
    return best

def solveDefense(t,h,a,d) :
    if d == 0 : return sim(t,h,a,d,0)
    maxd = math.ceil(a/d)
    ans = min(sim(t,h,a,d,nd) for nd in range(0,maxd+1))
    return ans

def sim(t,h,a,d,nd) :
    starth = h
    turns = 0

    ## Do the debuffs
    for i in range(nd) :
        if h > (a-d) :
            a = max(0,a-d)
            h -= a
            turns += 1
        else : 
            h = starth-a
            a = max(0,a-d)
            h -= a; 
            if h <= 0 : return sys.maxsize
            turns += 2

    ## Do the attacks
    for i in range(t) :
        h -= a
        if h > 0 or i == t-1 :
            turns += 1
        else :
            h = starth-2*a
            if h <= 0 : return sys.maxsize
            turns += 2
            
    return turns

#####################################################################################################
if __name__ == "__main__" :
    doit()
