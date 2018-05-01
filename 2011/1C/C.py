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

    check,res = checkRange(1,f[0],gcdarr[0],1,l,h)
    if check : return str(res)
    for i in range(n-1) :
        check,res = checkRange(f[i],f[i+1],gcdarr[i+1],lcmarr[i],l,h)
        if check : return str(res)
    check,res = checkTop(f[-1],lcmarr[-1],l,h)
    if check : return str(res)
    return "NO"
    
def checkRange(l1,h1,gg,ll,l2,h2) :
    l = max(l1,l2,ll)
    h = min(h1,h2,gg)
    if l > h : return False,0
    if gg % ll != 0 : return False,0
    ## Now we are looking for a number in [l,h] that is both a multiple of ll and a divisor of gg
    div = getDivisors(gg)
    for d in div :
        if d < l or d > h : continue
        if d % ll != 0    : continue
        return True, d
    return False, 0

def getDivisors(n) :
    factors = {}
    nn = n; i = 2
    while i*i <= nn :
        if nn % i == 0 :
            factors[i] = [1]
            while nn % i == 0 : factors[i].append(factors[i][-1] * i); nn //= i
        i += 2 if i > 2 else 1
    if nn != 1 : factors[nn] = [1, nn]

    ## Now we just need to make the product of these various arrays
    rawans = [1]
    for a in factors.values() :
        newraw = [x*y for x in rawans for y in a]
        rawans = newraw
    ans = sorted(rawans)
    return ans

def checkTop(l1,ll,l2,h) :
    l = max(l1,l2,ll)
    if l > h : return False, 0
    t = l // ll * ll
    if t < l : t += ll
    if t <= h : return True,t
    return False,0

def getInputs(IN) :
    n,l,h = IN.ints()
    freqs = tuple(IN.ints())
    return (n,l,h,freqs)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    if (False) :
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            print("Case #%d: %s" % (tt,ans))
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            print("Case #%d: %s" % (tt,ans))