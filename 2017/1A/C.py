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
    ## We have n+c1 debuff turns + cures --> (h,a,c1) --> t+c2 offense turns + cures
    if d == 0 : return t + solveBack(t,h,h,a)
    nd = 0 if h > 2 * a else 1 if h > 2*a-min(a,d) else 2
    c1 = 0; best = sys.maxsize; la = a; lh = h, lastnd = 0 
    while (True) :
        (c1adder,lh,la) += solveFront(nd-lastnd,h,lh,la,d)
        c1 += c1adder
        c2 = solveBack(t,h,lh,la)
        best = min(c1+c2+t+nd,best)
        if la == 0 : break
        lastnd = nd
        nd = nextnd(h,a,d,nd)
    return best

def solveBack(t,sh,h,a) :
    turnsToFirstHeal = (h-1) // a
    if t <= turnsToFirstHeal + 1 : return 0
    t -= turnsToFirstHeal
    turnsBetweenHeals = (sh-a-1) // a
    extraHeals = (t-1) // turnsBetweenHeals
    return 1 + extraHeals

def nextnd(h,a,d,nd) :
    v = (h-1) // (a-nd*d)
    x = (v * d) // (a * v - h +1)
    if x == nd : x -= 1
    return x

def solveFront(nnd,sh,h,a,d) :
  

#####################################################################################################
if __name__ == "__main__" :
    doit()
