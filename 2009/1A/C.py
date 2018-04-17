import sys
import math
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

def nCr(n,r) :
    f = math.factorial
    return f(n) // f(r) // f(n-r)

def p(c,n,missing,found) :
    # ( missing ) ( c - missing )
    # ( found   ) ( n - found   )
    # ----------------------------
    #        ( c )
    #        ( n )
    if found < 0 : return 0
    if found > missing : return 0
    if n - found < 0 : return 0
    if n - found > c - missing : return 0
    return 1.0 * nCr(missing,found) * nCr(c-missing,n - found) / nCr(c,n)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        c,n = IN.ints()

        ## E(1) = 1 + P(c,n,1,0) * E(1) --> E(1) = (1) / (1 - P(c,n,1,0))
        ## E(2) = 1 + P(c,n,2,1) * E(1) + P(c,n,2,0) * E(2) = (1 + P(c,n,2,1) * E(1)) / (1 - P(c,n,2,0))
        ## E(3) = 1 + P(C,n,3,2) * E(1) + P(c,n,3,1) * E(2) + P(c,n,3,0) * E(3) = (1 + P(c,n,3,2) * E(1)) 
        e = [0] * (c+1)
        for missing in range(1,c+1) :
            num = 1
            for found in range(1,missing) :
                num += p(c,n,missing,found) * e[missing-found]
            denom = 1.0 - p(c,n,missing,0)
            e[missing] = num / denom
        print("Case #%d: %.8f" % (tt,e[c]))
        