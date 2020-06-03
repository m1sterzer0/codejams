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
    eps = 1e-13
    for i in range(n) :
        x1,y1 = x[i],y[i]
        points = [ (x[j]-x1,y[j]-y1) for j in range(n) if j != i ]
        angles = [ math.atan2(y,x) for (x,y) in points ]
        angles.sort()
        angles = angles + [ x + 2 * math.pi for x in angles ]
        best = n
        k = 0
        for j in range(n-1) :
            targ = angles[j] + math.pi + eps
            while angles[k] < targ : k += 1
            left = k-j-1; right = n-left-2
            best = min(best,left,right)
        ans.append(str(best))
    return ans

#####################################################################################################
if __name__ == "__main__" :
    doit(multi=True)
