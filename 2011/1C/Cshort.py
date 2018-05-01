import sys
import math
from fractions import gcd

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

def lcm(a,b) : return a * b // gcd(a,b)

def solve(inp) :
    (n,l,h,freqs) = inp
    f = sorted(freqs)
    gcdarr = [0] * len(f)
    lcmarr = [0] * len(f)

    ## LCMarr first
    lcmarr[0] = f[0]
    for i in range(1,n) : 
        lcmarr[i] = lcm(lcmarr[i-1],f[i])
        if lcmarr[i] > h : lcmarr[i] = h+1

    ## GCDarr
    gcdarr[-1] = f[-1]
    for i in range(n-2,-1,-1) :
        gcdarr[i] = gcd(gcdarr[i+1],f[i])

    ## Do the preamble
    for i in range(1,f[0]+1) :
        if gcdarr[0] % i == 0 and i >= l and i <= h : return str(i)

    ## Do the middle
    for idx in range(n-1) :
        for i in range(f[idx],f[idx+1]+1) :
            if gcdarr[idx+1] % i == 0 and i % lcmarr[idx] == 0 and i >= l and i <= h : return str(i)

    for i in range(f[-1],h+1) :
        if i % lcmarr[-1] == 0 and i >= l and i <= h : return str(i) 

    return "NO" 

def getInputs(IN) :
    n,l,h = IN.ints()
    freqs = tuple(IN.ints())
    return (n,l,h,freqs)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %s" % (tt,ans))
