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
    print("Case #%d:" % tt)
    for l in ans : print(l)

def getInputs(IN) :
    n = int(IN.input())
    x = [0] * n; y = [0] * n
    for i in range(n) :
        x[i],y[i] = IN.ints()
    return n,x,y

def solve(inp) :
    (n,x,y) = inp
    if n <= 3 : return ["0"] * n
    ans = []
    for i in range(n) :
        x1,y1 = x[i],y[i]
        mintrees = n
        for j in range(n) :
            if j == i : continue
            x2,y2 = x[j],y[j]
            u1,u2 = x2-x1,y2-y1
            left,right = 0,0
            for k in range(n) :
                if k == i or k == j : continue
                x3,y3 = x[k],y[k]
                v1,v2 = x3-x1,y3-y1
                crossprod = u1*v2-u2*v1
                if crossprod > 0 : left += 1
                if crossprod < 0 : right += 1
            cand = min(left,right)
            mintrees = min(mintrees,cand)
        ans.append(str(mintrees))
    return ans

#####################################################################################################
if __name__ == "__main__" :
    doit()
