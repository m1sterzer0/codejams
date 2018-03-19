import fileinput
import sys
import functools
from statistics import median

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
        (a,b,k) = myin.getintline(3)
        ways = 0
        for i in range(a) :
            for j in range(b) :
                if i & j < k : ways += 1
        print("Case #%d: %d" % (tt+1,ways))
