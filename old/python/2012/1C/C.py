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
cache = {}

def getInputs(IN) :
    n,m = IN.ints()
    l1 = list(IN.ints())
    l2 = list(IN.ints())
    a = l1[0::2]
    A = l1[1::2]
    b = l2[0::2]
    B = l2[1::2]
    return (n,m,a,A,b,B)

def solve(inp) :
    (n,m,a,A,b,B) = inp
    global cache
    cache = {}
    ans = dp(0,0,a[0],b[0],n,m,a,A,b,B)
    return str(ans)

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def dp(i,j,ni,nj,n,m,a,A,b,B) :
    if (i,j,ni,nj) not in cache :
        if i >= n or j >= m :
            ans = 0
        elif (A[i] != B[j]) :
            a1 = 0 if i == n-1 else dp(i+1,j,a[i+1],nj,n,m,a,A,b,B)
            a2 = 0 if j == m-1 else dp(i,j+1,ni,b[j+1],n,m,a,A,b,B)
            ans = max(a1,a2)
        elif ni > nj :
            a1 = nj
            a2 = 0 if j == m-1 else dp(i,j+1,ni-nj,b[j+1],n,m,a,A,b,B)
            ans = a1+a2
        elif ni < nj :
            a1 = ni
            a2 = 0 if i == n-1 else dp(i+1,j,a[i+1],nj-ni,n,m,a,A,b,B)
            ans = a1+a2
        else :
            a1 = ni
            a2 = 0 if i == n-1 or j == m-1 else dp(i+1,j+1,a[i+1],b[j+1],n,m,a,A,b,B)
            ans = a1+a2
        cache[(i,j,ni,nj)] = ans
    return cache[(i,j,ni,nj)]

#####################################################################################################
if __name__ == "__main__" :
    doit()
