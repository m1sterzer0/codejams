import sys
import math
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

def calcEnd(b,x,v) :
    ans = (b-x)//v
    if x + v*ans < b : ans += 1
    return ans

def solve(inp) :
    (n,k,b,t,xarr,varr) = inp
    if k == 0 : return(str(0))
    endTimes = [calcEnd(b,x,v) for (x,v) in zip(xarr,varr)][::-1]
    naturalWinners = sum(1 for x in endTimes if x <= t)
    if naturalWinners < k : return "IMPOSSIBLE"
    winners = []
    for i in range(n) :
        if endTimes[i] <= t : 
            winners.append(i) 
            if len(winners) == k : break
    ans = sum(winners) - (k) * (k-1) // 2
    return str(ans)

def getInputs(IN) :
    n,k,b,t = IN.ints()
    xarr = tuple(IN.ints())
    varr = tuple(IN.ints())
    return (n,k,b,t,xarr,varr)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t)]

    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %s" % (tt,ans))
