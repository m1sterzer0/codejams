import sys
import math
import collections
import heapq
from operator import itemgetter

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

def solve(inp) :
    (d,n,ai,t,x,aa) = inp
    ## No brakes baby, just wait until you can fall all the way down
    ## position (relative to top of the hill) will be 0 for t < t0 and 0.5*a*(t-t0)^2 for t >= t0
    ## Thus, problem is to find the minimum t0 we need to stay behind the car
    ## for a given xi,ti pair, we need 0.5*a*(ti-t0)^2 <= xi --> (ti-t0)^2 < 2*xi/a --> ti-t0 < sqrt(2*xi/a) --> t0 > ti - sqrt(2*xi/a)
    ## Once we find the maximum t0 from all these constraints, we can solve for the t where we hit the end
    ## t = t0 + sqrt(2*D/a)
    ans = []
    for a in aa :
        tlast,xlast,t0 = 0,0,0
        for tt,xx in zip(t,x) :
            if   xx < d  : t0 = max(t0, tt - math.sqrt(2*xx/a)); tlast,xlast = tt,xx
            elif xx == d : t0 = max(t0, tt - math.sqrt(2*xx/a)); break 
            elif tt == 0 : break ## Car starts further down the hill than our destination
            else :                
                xi=d
                ti = tlast + (tt-tlast) * (d-xlast)/(xx-xlast)
                t0 = max(t0, ti - math.sqrt(2*xi/a))
                break
        ans.append(t0 + math.sqrt(2*d/a))
    return ans

def getInputs(IN) :
    xx = IN.strs(); d = float(xx[0]); n = int(xx[1]); a = int(xx[2])
    t = [0] * n; x = [0] * n
    for i in range(n) :
        t[i],x[i] = IN.floats()
    aa = tuple(IN.floats())
    return (d,n,a,t,x,aa)

def printOutput(tt,ans) :
    #print("Case #%d: %s" % (tt,ans))
    print("Case #%d:" % tt)
    for a in ans : print("%.8f" % a)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    ## Non-multithreaded case
    if (True) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            printOutput(tt,ans)
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            printOutput(tt,ans)
