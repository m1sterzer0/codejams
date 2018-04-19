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

def solve(a,n) :
    ## Need n-1 leading zeros
    if n <= 1 : return 0
    swaps = 0; mintz = n-1
    for k in range(n) :
        if a[k] >= mintz :
            a.pop(k)
            return swaps + solve(a,n-1)
        swaps += 1

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        n, = IN.ints()
        tz = [0] * n
        for i in range(n) :
            row, = IN.strs()
            for r in reversed(row) :
                if r == '0' : tz[i] += 1
                else         : break
        ans = solve(tz,n)
        print("Case #%d: %d" % (tt,ans))
