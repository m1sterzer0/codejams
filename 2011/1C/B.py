import sys
import math
from itertools import accumulate

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

def check(t,c,d,p,v) :
    #print("DBG: Checking:",t)
    leftmax = -1e99
    for pp,vv in zip(p,v) :
        pa = pp-t; pb = pp+t
        leftloc = pa if pa >= leftmax+d else leftmax+d
        rightloc = leftloc + (vv-1)*d
        if pb < rightloc : return False
        leftmax = rightloc
    return True 

def solve(inp) :
    (L,t,N,C,a) = inp
    d = [ a[x % C] for x in range(N) ]
    cumd = list(accumulate(d))
    threshold = next((i for i,v in enumerate(cumd) if 2 * v > t),None)
    savings = [0] * N
    if threshold is not None and threshold < N-1 : savings[threshold+1:] = d[threshold+1:]
    if threshold is not None : savings[threshold] = cumd[threshold] - t//2
    savings.sort(reverse=True)
    savedTime = sum(savings[0:L])
    ans = 2*cumd[-1] - savedTime
    return ans

def getInputs(IN) :
    tt = tuple(IN.ints())
    L,t,N,C = tt[0:4]
    a = tt[4:]
    return (L,t,N,C,a)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    if (False) :
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            print("Case #%d: %d" % (tt,ans))
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            print("Case #%d: %d" % (tt,ans))