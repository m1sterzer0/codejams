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

def solve(inp) :
    (n,a,b) = inp
    ans = 0
    for i in range(1,n) :
        for j in range(i) :
            if (a[i]-a[j])*(b[i]-b[j]) < 0 : ans += 1
    return ans

def getInputs(IN) :
    n, = IN.ints()
    a,b = [],[]
    for _ in range(n) :
        x,y = IN.ints()
        a.append(x); b.append(y)
    return (n,a,b)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t)]

    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %d" % (tt,ans))
