import fileinput
import sys

class MyInput(object) :
    def __init__(self,default_file="A.in") :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input(default_file)]
        #if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.short")]
        else                   : self.lines = [x for x in fileinput.input()]
        self.lineno = 0
    def getintline(self,n=-1) : 
        ans = tuple(int(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans
    def getfloatline(self,n=-1) :
        ans = tuple(float(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getfloatline'%(n,len(ans)))
        return ans
    def getstringline(self,n=-1) :
        ans = tuple(self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getstringline'%(n,len(ans)))
        return ans
    def getbinline(self,n=-1) :
        ans = tuple(int(x,2) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getbinline'%(n,len(ans)))
        return ans

if __name__ == "__main__" :
    myin = MyInput("B.in")
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,m) = myin.getintline(2)
        board = [ list(myin.getintline(m)) for x in range(n) ]
        rowmax = [ max(board[x]) for x in range(n)]
        colmax = [ max( [board[x][y] for x in range(n)]) for y in range(m) ]
        ans = "YES"
        for i in range(n) :
            for j in range(m) :
                if board[i][j] < rowmax[i] and board[i][j] < colmax[j] :
                    ans = "NO"; break
        print("Case #%d: %s" % (tt+1,ans))

