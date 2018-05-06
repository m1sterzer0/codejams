import collections
import functools
import heapq
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
    x,y,z,vx,vy,vz = [],[],[],[],[],[]
    arrs = (x,y,z,vx,vy,vz)
    for i in range(n) :
        nn = tuple(IN.ints())
        for arr,val in zip(arrs,nn) :
            arr.append(val)
    return (n,x,y,z,vx,vy,vz)

def solve(inp) :
    (n,x,y,z,vx,vy,vz) = inp
    x0 = sum(x) / n
    y0 = sum(y) / n
    z0 = sum(z) / n
    a = sum(vx) / n
    b = sum(vy) / n
    c = sum(vz) / n
    ## Distance squared is x0^2 + y0^2 + z0^2 + 2(ax0 + by0 + cz0)*t + (a^2+b^2+c^2)*t^2
    ## Derivative at 0 is 2(ax0 + by0 + cz0)
    ## If derivative at zero is positive or 0, then minimum is at zero
    ## Otherwise, minimum is at t = -(ax0+by0+cz0) / (a^2+b^2+c^2)
    deriv_at_0 = 2 * (a * x0 + b * y0 + c * z0)
    if deriv_at_0 >= 0 :
        d_at_0 = math.sqrt(x0*x0+y0*y0+z0*z0)
        (ans1,ans2) = (d_at_0,0.00)
    else :
        tmin = -1.0*(a * x0 + b * y0 + c * z0) / (a*a + b*b + c*c)
        d2min = (x0 + a * tmin)**2 + (y0 + b * tmin)**2 + (z0 + c * tmin)**2
        (ans1,ans2) = (math.sqrt(d2min),tmin)
    return "%.8f %.8f" % (ans1,ans2)

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()
