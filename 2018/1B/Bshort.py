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
    s = int(IN.input())
    d = [0] * s
    a = [0] * s
    b = [0] * s
    for i in range(s) :
        d[i],a[i],b[i] = IN.ints()
    return (s,d,a,b)

def solve(inp) :
    (s,d,a,b) = inp
    dPlusa  = [x + y for x,y in zip(d,a) ]
    dMinusb = [x - y for x,y in zip(d,b) ] 
    if s == 1 : return "1 1"
    if s == 2 : return "2 1"

    for size in range(s,2,-1) :
        count = 0
        for start in range(s-size+1) :
            if check(dPlusa,dMinusb,start,size) or check(dMinusb,dPlusa,start,size) : count += 1
        if count >= 1 : return "%d %d" % (size,count)

    ## Length 3 didn't work, but length 2 works for everyone
    return "%d %d" % (2,s-1)

def check(a,b,start,size) : 
    v1 = a[start]
    v2 = None
    for i in range(start,start+size) :
        if a[i] == v1 : continue
        if v2 is None: v2 = b[i]; continue
        if b[i] == v2 : continue
        return False
    return True

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()

