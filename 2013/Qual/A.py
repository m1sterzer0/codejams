import fileinput
import sys
import fractions

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
    myin = MyInput("A.in")
    (t,) = myin.getintline()
    xwins = set(("XXXX", "XXXT", "XXTX", "XTXX", "TXXX"))
    owins = set(("OOOO", "OOOT", "OOTO", "OTOO", "TOOO"))
    for tt in range(t) :
        (l1,)  = myin.getstringline(1)
        (l2,)  = myin.getstringline(1)
        (l3,)  = myin.getstringline(1)
        (l4,)  = myin.getstringline(1)
        _   = myin.getstringline()
        l5  = l1[0] + l2[0] + l3[0] + l4[0]
        l6  = l1[1] + l2[1] + l3[1] + l4[1]
        l7  = l1[2] + l2[2] + l3[2] + l4[2]
        l8  = l1[3] + l2[3] + l3[3] + l4[3]
        l9  = l1[0] + l2[1] + l3[2] + l4[3]
        l10 = l1[3] + l2[2] + l3[1] + l4[0]
        lines = (l1,l2,l3,l4,l5,l6,l7,l8,l9,l10)
        board = l1 + l2 + l3 + l4

        ## Check if X wins
        state = "Game has not completed"
        for l in lines :
            if l in xwins : state = "X won"; break
            if l in owins : state = "O won"; break
        if state == "Game has not completed" and '.' not in board:
            state = "Draw"
        
        print("Case #%d: %s" % (tt+1,state))
