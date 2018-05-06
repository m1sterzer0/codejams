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
    a1,a2,b1,b2 = IN.ints()
    return (a1,a2,b1,b2)

def solve(inp) :
    (a1,a2,b1,b2) = inp
    ans = 0
    for x in range(a1,a2+1) :
        for y in range(b1,b2+1) :
            if evalPosition(x,y) : ans += 1
    return "%d" % ans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def evalPosition(x,y) :
    x,y = max(x,y),min(x,y)
    if x == y     : return False ## (a,a) is losing position
    if x >= 2 * y : return True ## (ky+c,y) forks to (ky+c,y) --> (y+c,y) --> (c,y) via forced move or directly to (c,y).
                                ## since (c,y) is either winning or losing and we have the option of giving that ot either us or our opponent, we win.
    return not evalPosition(y,x-y)

#####################################################################################################
if __name__ == "__main__" :
    doit()

