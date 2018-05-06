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
    n,p = IN.ints()
    widths = [0] * n
    heights = [0] * n
    for i in range(n) :
        widths[i],heights[i] = IN.ints()
    return (n,p,widths,heights)

def solve(inp) :
    (n,p,widths,heights) = inp
    intervals = [ (2*min(l,w), 2*math.sqrt(l*l+w*w)) for l,w in zip(widths,heights) ]
    minadder =min(x[0] for x in intervals)
    maxadder = sum(x[1] for x in intervals)
    minperim = sum(2*l+2*w for l,w in zip(widths,heights))
    maxperim = minperim + maxadder

    if minperim + minadder > p : ans = minperim
    elif maxperim <= p         : ans = maxperim
    else                       : ans = intervalSearch(intervals,p,minperim)

    return "%.8f" % ans

def intervalSearch(intervals,p,minperim) :
    targetAdder = p - minperim
    l = [ intervals[0] ]
    if checkIntervals(l,targetAdder) : return p
    for i in intervals[1:] :
        l = mergeInterval(l,i)
        if checkIntervals(l,targetAdder) : return p
        l = [x for x in l if x[0] < targetAdder]
    return minperim + l[-1][1]

def checkIntervals(l,t) :
    for (ll,rr) in l :
        if ll <= t and t <= rr : return True
    return False

def mergeInterval(l,i) :
    l1,r1 = i
    l2 = l + [i] + [(l1+x,r1+y) for x,y in l]
    l2.sort()
    l3 = []
    ll,rr = l2[0]
    for x,y in l2[1:] :
        if x > rr : l3.append( (ll,rr) ); ll,rr = x,y
        else: rr = max(y,rr)
    l3.append( (ll,rr) )
    return l3

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()

