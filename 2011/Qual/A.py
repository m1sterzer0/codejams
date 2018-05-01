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

def solve(inp) :
    (tasks,robots,buttons) = (inp)
    lastPos = { "O" : 1, "B" : 1 }
    lastTime = { "O" : 0, "B" : 0 }
    score = 0
    for r,b in zip(robots,buttons) :
        candtime = lastTime[r] + abs(b-lastPos[r]) + 1
        if candtime < score + 1 : candtime = score + 1
        score = candtime; lastTime[r] = candtime; lastPos[r] = b
    return score

def getInputs(IN) :
    tokens = list(IN.input().rstrip().split())
    tasks = int(tokens[0])
    robots = tokens[1::2]
    buttons = [int(x) for x in tokens[2::2]]
    return (tasks,robots,buttons)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %d" % (tt,ans))
