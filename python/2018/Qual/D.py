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
    f = float(IN.input())
    return (f,)

def solve(inp) :
    (f,) = inp
    besty = 0.783653124333
    maxfunc = evalWrap(1.0,besty)
    if f == 1.000 : return doAns(0.0,0.0)
    elif f < math.sqrt(2) :
        xx = rootfind(lambda x: evalWrap(x,0.0)-f,0.00,1.00)
        return doAns(xx,0.0)
    elif f < maxfunc :
        yy = rootfind(lambda x: evalWrap(1.0,x)-f,0.00,besty)
        return doAns(1.0,yy)
    else : return doAns(1.0,besty)

def printOutput(tt,ans) :
    print("Case #%d:" % tt)
    for p in ans : print("%.15f %.15f %.15f" % (p[0],p[1],p[2]))

def createRotationMatrix(theta,psi) :
    return [[math.cos(psi), -1*math.sin(psi)*math.cos(theta),  math.sin(psi)*math.sin(theta)],
            [math.sin(psi),    math.cos(psi)*math.cos(theta), -1*math.cos(psi)*math.sin(theta)],
            [0,                math.sin(theta),                math.cos(theta)]]

def rotatePoints(m,points) :
    ans = []
    for p in points :
        ans.append([ m[0][0] * p[0] + m[0][1] * p[1] + m[0][2] * p[2],
                     m[1][0] * p[0] + m[1][1] * p[1] + m[1][2] * p[2],
                     m[2][0] * p[0] + m[2][1] * p[1] + m[2][2] * p[2] ])
    return ans

def planarProjection(rpoints) :
    return list([ (p[0],p[2]) for p in rpoints ])

## Adapted From: https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain#Python
def cross(o,a,b) :
    oa = (a[0]-o[0],a[1]-o[1])
    ob = (b[0]-o[0],b[1]-o[1])
    return oa[0]*ob[1]-ob[0]*oa[1]

## Adapted From: https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain#Python
def convexHull(ppoints) :
    points = sorted(set(ppoints))
    lower,upper = [],[]
    for p in points :
        while len(lower) >= 2 and cross(lower[-2],lower[-1],p) <= 0 : lower.pop()
        lower.append(p)
    for p in reversed(points) :
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0 : upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]

def shoelaceArea(chull) :
    twoarea = 0.0
    for i in range(len(chull)) :
        j = i+1 if i+1 < len(chull) else 0
        k = i-1 if i > 0 else len(chull)-1
        twoarea += chull[i][0]*chull[j][1]
        twoarea -= chull[i][0]*chull[k][1]
    return 0.5 * twoarea

def evaluate(theta,psi) :
    points = [ (-0.5,-0.5,-0.5),
               (-0.5,-0.5, 0.5),
               (-0.5, 0.5,-0.5),
               (-0.5, 0.5, 0.5),
               ( 0.5,-0.5,-0.5),
               ( 0.5,-0.5, 0.5),
               ( 0.5, 0.5,-0.5),
               ( 0.5, 0.5, 0.5) ]
    m = createRotationMatrix(theta,psi)
    rpoints = rotatePoints(m,points)
    #print(rpoints)
    ppoints = planarProjection(rpoints)
    chull   = convexHull(ppoints)
    area    = shoelaceArea(chull)
    return area

def golden(f,a,b,tol=1e-10) :
    gr = (math.sqrt(5) + 1) / 2.0
    c = b - (b-a) / gr
    d = a + (b-a) / gr
    while abs(b-a) > tol :
        if f(c) < f(d) : b = d
        else           : a = c
        c = b - (b-a) / gr
        d = a + (b-a) / gr
    return (b+a)/2.0

def rootfind(f,a,b,tol=1e-10) :
    while (b-a) > tol :
        m = (a+b) / 2.0
        if f(a) * f(m) > 0 : a,b = m,b
        else               : a,b = a,m
    return (a+b)/2.0

def doAns(x,y) :
    points = [ (0.5,0.0,0.0), (0.0,0.5,0.0), (0.0,0.0,0.5) ]
    m = createRotationMatrix(x * math.pi/4.0,y * math.pi/4.0)
    rpoints = rotatePoints(m,points)
    return rpoints

def evalWrap(x,y) : return evaluate(x*math.pi/4.0,y*math.pi/4.0)

#####################################################################################################

if __name__ == "__main__" :
    doit()