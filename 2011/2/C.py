import sys
import math
import collections
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

def sieve(limit) :
    ll= limit+1
    a = [True] * ll
    a[0] = False
    a[1] = False
    a[2::2] = [False] * len(a[2::2])
    yield 2
    for i in range(3,ll,2) :
        if not a[i] : continue
        yield i
        a[i*i::2*i] = [False] * len(a[i*i::2*i])
    
def doPrimeSearch(n) :
    lim = int(math.sqrt(n))
    if lim*lim > n : lim -= 1
    if (lim+1)*(lim+1) <= n : lim += 1
    tarr = []
    for p in sieve(lim) : ## A bit wasteful, as we are sieving every testcase, but given the parallelization, it is fine
        x = p*p; cnt=1
        while x <= n : cnt += 1; x *= p
        tarr.append(cnt)
    return tarr

def solve(inp) :
    (n,) = inp
    if n == 1 : return 0
    t = doPrimeSearch(n)
    gap = 1
    for tt in t : gap += (tt-1)
    return str(gap)

def getInputs(IN) :
    n = int(IN.input())
    return (n,)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    ## Non-multithreaded case
    if (False) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            print("Case #%d: %s" % (tt,ans))

    ## Multithreaded case
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            print("Case #%d: %s" % (tt,ans))