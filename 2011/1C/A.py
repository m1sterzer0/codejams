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
    (r,c,board) = inp
    for i in range(r) :
        for j in range(c) :
            if board[i][j] != '#' : continue
            if i == r-1 or j == c-1 : return [ "Impossible" ]
            if board[i][j+1] != '#' or board[i+1][j] != '#' or board[i+1][j+1] != '#' : return [ "Impossible" ]
            board[i][j] = '/'; board[i][j+1] = '\\'; board[i+1][j] = '\\'; board[i+1][j+1] = '/'
    return [ ''.join(x) for x in board ]

def getInputs(IN) :
    r,c = IN.ints()
    board = [ list(IN.input().rstrip()) for x in range(r) ]
    return (r,c,board)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d:" % (tt,))
        for l in ans : print(l)
