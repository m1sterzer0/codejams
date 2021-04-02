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
        
## KEY INSIGHT:
##  The BAD permuation has a propensity to push high numbered cards to earlier spots in the permutation
##  Experimenting, we see that the mean number of cards greater than their position value is around 530 for the BAD
##  algorithm and is around 500 for the good algorithm, this should be good enough to solve the problem.

def classifier1(deck,N) :
    score = 0
    for j in range(N) :
        if deck[j] > j : score += 1
    if score >= 515 : return "BAD"
    else            : return "GOOD"
    
if __name__ == "__main__" :
    myin = MyInput("C.test.in")
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,) = myin.getintline(1)
        deck = myin.getintline(n)
        myType = classifier1(deck,n)
        print("Case #%d: %s" % (tt+1,myType))
