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

Segment = collections.namedtuple('Segment', ['s','d'])

def getInputs(IN) :
    x,s,r,t,n = IN.ints()
    b = [0] * n
    e = [0] * n
    w = [0] * n
    for i in range(n) :
        b[i],e[i],w[i] = IN.ints()
    return (x,s,r,t,n,b,e,w)

def solve(inp) :
    (x,s,r,t,n,b,e,w) = inp
    segments = []
    cursor = 0
    for bb,ee,ww in zip(b,e,w) :
        if bb > cursor : segments.append(Segment(s,bb-cursor))
        segments.append(Segment(s+ww,ee-bb))
        cursor = ee
    if x > cursor : segments.append(Segment(s,x-cursor))

    segments.sort()

    ## We want to use our running time in the slowest intervals
    totaltime = 0
    runDelta = r-s
    for ss in segments :
        if t > 0 :
            tt = ss.d / (ss.s + runDelta)
            if tt <= t :
                t -= tt
            else :
                d1 = t * (ss.s + runDelta)
                d2 = ss.d - d1
                tt = d1 / (ss.s + runDelta) + d2 / ss.s
                t = 0
            totaltime += tt
        else :
            tt = ss.d / ss.s
            totaltime += tt
    
    return "%.8f" % totaltime

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()
