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
    n, = IN.ints()
    data = []
    for _ in range(n) : data.extend(list(IN.ints()))
    xs = data[0::3]
    ys = data[1::3]
    rs = data[2::3]
    return (n,xs,ys,rs)

def solve(a) :
    (n,xs,ys,rs) = a
    if n == 1 : return "%.8f" % rs[0]
    l = max(rs); r = 500 * math.sqrt(2) + l + 1
    while (r-l > 4e-6) :
        m = (r+l) * 0.5
        if good(n,xs,ys,rs,m) : r = m
        else                  : l = m
    return "%.8f" % (0.5*(r+l))

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getCenter(x1,y1,r1,x2,y2,r2) :
    d = math.sqrt((x1-x2)**2+(y1-y2)**2)
    if d > r1 + r2 : return []
    uv = ( (x2-x1)/d, (y2-y1)/d )
    uv2 = ( -uv[1], uv[0] ) ## Orthogonal unit vector
    if r1 + r2 - d < 1e-10 : return [ (x1+r1*uv[0],y1+r1*uv[1]) ]
    x = (r1**2-r2**2+d**2) / (2 * d)
    y = math.sqrt(r1*r1-x*x)
    return [ (x1 + uv[0] * x + uv2[0] * y, y1 + uv[1] * x + uv2[1] * y), 
             (x1 + uv[0] * x - uv2[0] * y, y1 + uv[1] * x - uv2[1] * y) ]

def findCenters(xs,ys,rs,n,radius) :
    ans = []
    for i in range(n) : ans.append((xs[i],ys[i]))
    for i in range(n) :
        for j in range(i) :
            lans = getCenter(xs[i],ys[i],radius-rs[i],xs[j],ys[j],radius-rs[j])
            ans.extend(lans)
    return ans

def betterCheck(centers,r,xarr,yarr,rarr) :
    n = len(xarr)
    r *= (1 + 1e-10) ## For numerical accuracy
    target = (1 << n) - 1
    nCenters = len(centers)
    sb = [0] * nCenters
    for j in range(n) :
        val = 1 << j
        rhs = (r - rarr[j])**2
        x0,y0 = xarr[j],yarr[j]
        margin = [ rhs - (x-x0)**2 - (y-y0)**2 for (x,y) in centers ]
        for c,m in enumerate(margin) :
            if m >= 0 : sb[c] |= val
    scores = [x | y for (x,y) in itertools.combinations(sb,2)]
    if target in scores : return True
    return False
        
def good(n,xs,ys,rs,radius) :
    centers = findCenters(xs,ys,rs,n,radius)
    if betterCheck(centers,radius,xs,ys,rs) : return True
    return False

##def check(c1,c2,r,xarr,yarr,rarr) :
##    r *= (1+1e-10) ## For numerical accuracy, since we set the r exactly to be tangent to some of these
##    for i in range(len(xarr)) :
##        if (r-rarr[i])**2 + 1e-10 >= (c1[0]-xarr[i])**2 + (c1[1]-yarr[i])**2 : continue
##        if (r-rarr[i])**2 + 1e-10 >= (c2[0]-xarr[i])**2 + (c2[1]-yarr[i])**2 : continue
##        return False
##    return True

#####################################################################################################
if __name__ == "__main__" :
    doit(multi=True)
