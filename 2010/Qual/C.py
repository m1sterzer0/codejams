import sys
import math
import fractions
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

def rcSolve(n,gs,k,idx) :
    riders = 0
    for i in range(n) :
        nextidx = (idx+i) % n
        if riders + gs[nextidx] <= k : riders += gs[nextidx]
        else                         : return riders,nextidx
    return riders,idx

def solve(inp) :
    (r,k,n,gs) = inp
    sb = [ None ] * n 
    rr,riders,idx = 0,0,0
    remainderFlag = False
    while rr < r :
        if remainderFlag or sb[idx] is None :
             sb[idx] = (rr,riders)
             rr += 1
             numRiders,idx = rcSolve(n,gs,k,idx)
             riders += numRiders
        else :
            numRidesInCycle  = rr - sb[idx][0]
            numRidersInCycle = riders - sb[idx][1]
            numCycles = (r - rr) // numRidesInCycle
            rr += numCycles * numRidesInCycle
            riders += numCycles * numRidersInCycle
            remainderFlag = True
    return "%d" % riders

def getInputs(IN) :
    r,k,n = IN.ints()
    gs = tuple(IN.ints())
    return (r,k,n,gs)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %s" % (tt,ans))