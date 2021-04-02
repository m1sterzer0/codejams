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
    b,n = IN.ints()
    m = tuple(IN.ints())
    return b,n,m

def check(b,n,m,test) :
    tally = sum( 1 + test//x for x in m )
    return tally >= n

def solve(inp) :
    (b,n,m) = inp
    ## Bin search for the minute where the nth barber is seated
    u,v = -1,100000000000000
    while (v-u > 1) :
        mid = (u+v)//2
        if check(b,n,m,mid) : v = mid
        else                : u = mid
    minute = v ## This is the minute where we seat the nth barber
    if minute == 0 : return str(n)
    nm1 = sum(1 + (minute-1)//x for x in m)  ## Number of people seated on or before minute-1
    for i,mm in enumerate(m,1) :
        if minute % mm == 0 :
            nm1 += 1
            if nm1 == n : return str(i)
    return '0'  ## Shouldn't get here

#####################################################################################################
if __name__ == "__main__" :
    doit()
