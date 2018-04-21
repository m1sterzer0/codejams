import sys
import math
from operator import itemgetter
from multiprocessing import Pool
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

def doMulti(IN,inputs) :
    with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
    for tt,ans in enumerate(outputs,1) :
        print("Case #%d: %d" % (tt,ans))

def evalPosition(x,y) :
    x,y = max(x,y),min(x,y)
    if x == y     : return False ## (a,a) is losing position
    if x >= 2 * y : return True ## (ky+c,y) forks to (ky+c,y) --> (y+c,y) --> (c,y) via forced move or directly to (c,y).
                                ## since (c,y) is either winning or losing and we have the option of giving that ot either us or our opponent, we win.
    return not evalPosition(y,x-y)
    
def solve(inp) :
    (a1,a2,b1,b2) = inp
    ans = 0
    for x in range(a1,a2+1) :
        for y in range(b1,b2+1) :
            if evalPosition(x,y) : ans += 1
    return ans

def getInputs(IN) :
    a1,a2,b1,b2 = IN.ints()
    return (a1,a2,b1,b2)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t)]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %d" % (tt,ans))
    #doMulti(IN,inputs)