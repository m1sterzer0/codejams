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
    (status,linearr) = ans
    print("Case #%d: %s" % (tt,status))
    for l in linearr: print(l)

def getInputs(IN) :
    b,m = IN.ints()
    return (b,m)

def solve(inp) :
    (b,m) = inp
    maxans = 2**(b-2)
    if m > maxans : return ("IMPOSSIBLE",[])
    sb = [ ['0'] * b for x in range(b) ]
    for i in range(b) :
        for j in range(i+1,b) :
            sb[i][j] = '1'
    pp = 2 ** (b-3)
    for i in range(1,b-1) :
        if m > pp  : m -= pp
        else       : sb[0][i] = '0'
        pp = pp >> 1 
    ans = []
    for l in sb : ans.append("".join(l))
    return ("POSSIBLE",ans)

#####################################################################################################
if __name__ == "__main__" :
    doit()
