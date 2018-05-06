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
    ldelta = 2 * min(widths[0],heights[0])
    rdelta = 2 * math.sqrt(widths[0] * widths[0] + heights[0] * heights[0])
    minperim = 2 * n * (widths[0] + heights[0])
    pdelta = p - minperim

    ## How many ldeltas can I fit in
    nn1 = int(1.0 * pdelta / ldelta)
    nn2 = int(1.0 * pdelta / rdelta)

    if nn1 == 0 :                  ans = minperim                ## Min perimeter case
    elif nn1 == nn2 and nn2 <= n : ans = minperim + nn2 * rdelta ## Intervals don't overlap
    elif n * rdelta < pdelta :     ans = minperim + n * rdelta   ## Max Perimeter Calse
    else :                         ans = p                       ## Perfect

    return "%.8f" % ans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()

