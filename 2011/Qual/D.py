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

## We intuit that we should hold down all of the elements that are in the correct place. (why not?)
## ASSUME we can just NOT hold down any of the elements in the wrong place 
## Let f(n) denote the expected number of poundings for a list initially with n
# elements in the wrong place
## Note f(0) = 0.
## We never have only one element in the wrong place
## f(2) = 1 + 1/2 * f(2) --> f(2) = 2
## f(3) = 1 + 1/2 * f(2) + 1/3 * f(3) --> f(3) = 3
## f(4) = 1 + 6/24 * f(2) + 8/24 * f(3)  + 9/24 * f(4) = 5/2 + 9/24 f(4) --> f(4) = 4
##
## Looks to be a pattern, can we prove
##
## a) By linearity of expectation (famous hat check problem)
##        p_0 * 0 + p_1 * 1 + p_2 * 2 + p_3 * 3 + ... + p_(n-1) * (n-1) + p_n * n = n-1
## b) By definition of expectation
##       f(n) = 1 + p_0 * f(0) + p_1 * f(1) + ... + p_n * f(n)
## c) If we asssume (inductive hypothesis) that f(k) = k for k < n, we have
##       f(n) = 1 + p_0 * 0 + p_1 * 1 + ... + p_(n-1) * (n-1) + p_n * f(n)
## d) Now we add and subtract n * f(n) from the right side
##       f(n) = 1 + (p_0 * 0 + p_1 * 1 + ... + p_(n-1) * (n-1) + p_n * n) - p_n * n + p_n * f(n)
##       f(n) = 1 + (n-1) - p_n * n + p_n * f(n)
##       (1-p_n) * f(n) = (1-p_n) * n
##       f(n) = n
##
## We still don't know if our assumption is perfect, but it is good enough for the contest and seems reasonable

def solve(inp) :
    (n,e) = inp
    se = sorted(e)
    ans = len([1 for x,y in zip(e,se) if x != y])
    return "%.8f" % ans

def getInputs(IN) :
    n = int(IN.input())
    e = tuple(IN.ints())
    return (n,e)
    
if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %s" % (tt,ans))
