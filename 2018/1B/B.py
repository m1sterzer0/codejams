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
    size,count = lsolve(dPlusa,dMinusb,0,s-1)
    return "%d %d" % (size,count)

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def lsolve(a,b,l,r) :
    if r == l : return 1,1
    if r-l == 1 : return 2,1
    m = (r+l)//2
    s1,c1 = lsolve(a,b,l,m-1)
    s2,c2 = lsolve(a,b,m+1,r)
    s3,c3 = csolve(a,b,l,r,m)
    size = max(s1,s2,s3)
    count = (0 if s1 < size else c1) + (0 if s2 < size else c2) + (0 if s3 < size else c3)
    return size,count

def csolve(a,b,l,r,m) :
    #There are only 4 candidates for the longest string that contains m
    #   a) elem m sets M, N is determined first left then right
    #   b) elem m sets M, N is determined first right then left
    #   c) elem m sets N, M is determined first left then right
    #   d) elem m sets N, M is determined first right then left
    s1,i1,j1 = doLeftFirstSearch(a,b,l,r,m)
    s2,i2,j2 = doRightFirstSearch(a,b,l,r,m)
    s3,i3,j3 = doLeftFirstSearch(b,a,l,r,m)
    s4,i4,j4 = doRightFirstSearch(b,a,l,r,m)
    size = max(s1,s2,s3,s4)
    count = 0; ss = set()
    for s,i,j in ( (s1,i1,j1),(s2,i2,j2),(s3,i3,j3),(s4,i4,j4) ) :
        if s == size and (i,j) not in ss :
            ss.add((i,j))
            count += 1
    return size,count

def doLeftFirstSearch(a,b,l,r,m) :
    v1 = a[m]
    v2 = None
    i,j = m,m
    while i >= l :
        if a[i] == v1 :            i -= 1; continue
        if v2 is None : v2 = b[i]; i -= 1; continue
        if b[i] == v2 :            i -= 1; continue
        break
    i += 1
    while j <= r :
        if a[j] == v1 :            j += 1; continue
        if v2 is None : v2 = b[j]; j += 1; continue
        if b[j] == v2 :            j += 1; continue
        break
    j -= 1
    return j-i+1,i,j

def doRightFirstSearch(a,b,l,r,m) :
    v1 = a[m]
    v2 = None
    i,j = m,m
    while j <= r :
        if a[j] == v1 :            j += 1; continue
        if v2 is None : v2 = b[j]; j += 1; continue
        if b[j] == v2 :            j += 1; continue
        break
    j -= 1
    while i >= l :
        if a[i] == v1 :            i -= 1; continue
        if v2 is None : v2 = b[i]; i -= 1; continue
        if b[i] == v2 :            i -= 1; continue
        break
    i += 1
    return j-i+1,i,j

#####################################################################################################
if __name__ == "__main__" :
    doit()

