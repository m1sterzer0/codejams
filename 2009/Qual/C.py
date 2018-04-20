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

def solve(instr) :
    ts = list("welcome to code jam")[::-1]
    for i,c in enumerate(ts) :
        if (i == 0) :
            ## Here, we need to do a from scatch search
            dp = [0] * len(instr)
            dp[-1] = 1 if instr[-1] == c else 0
            for i in range(len(instr)-2,-1,-1) :
                dp[i] = dp[i+1] + (1 if instr[i] == c else 0)
        else :
            dpold = dp
            dp = [0] * len(instr)
            for i in range(len(instr)-2,-1,-1) :
                dp[i] = (dp[i+1] + (dpold[i+1] if instr[i] == c else 0)) % 10000
    return dp[0]
            
def getInputs(IN) :
    return(IN.input().rstrip())

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t)]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %04d" % (tt,ans))