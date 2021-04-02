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
    r,c,n = IN.ints()
    return (r,c,n)

## Fill in the spaces greedily
## If there are an odd number of rows and columns, (with both >= 2) -- need to check both configurations of the checkerboard pattern

def solve(inp) :
    (r,c,n) = inp
    if c < r : r,c = c,r
    gaps = r*c - n
    maxunhappy = (r-1) * c + (c-1) * r
    if r == 1:
        ## we have k empties that cut out 2 unhappiness each, and sometimes 1 unhappyness at the end -- this formula still works for that case
        ans = max(0, maxunhappy - 2 * gaps)
    elif r % 2 == 0 or c % 2 == 0 :
        numfour = (r-2) * (c-2) // 2
        numthree = (r-2) + (c-2)
        numtwo = 2
        ans = lsolve(maxunhappy,gaps,numfour,numthree,numtwo)
    else :
        ## Two cases -- all the corners or none of them
        n4_1 = (r-2) * (c-2) // 2
        n4_2 = (r-2) * (c-2) // 2 + 1
        n3_1 = ((r-2) // 2 + (c-2) // 2) * 2 + 4
        n3_2 = ((r-2) // 2 + (c-2) // 2) * 2
        n2_1 = 0
        n2_2 = 4
        ans1 = lsolve(maxunhappy,gaps,n4_1,n3_1,n2_1)
        ans2 = lsolve(maxunhappy,gaps,n4_2,n3_2,n2_2)
        ans = min(ans1,ans2)
    return "%d" % ans  

def lsolve(maxu,g,n4,n3,n2) :
    ans = maxu
    ans -= 4 * min(g,n4); g -= min(g,n4)
    ans -= 3 * min(g,n3); g -= min(g,n3)
    ans -= 2 * min(g,n2); g -= min(g,n2)
    return ans
    
#####################################################################################################
if __name__ == "__main__" :
    doit()
