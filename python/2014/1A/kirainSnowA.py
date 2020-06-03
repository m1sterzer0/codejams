import sys
import fileinput

class MyInput(object) :
    def __init__(self) :
        #if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.in")]
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.short")]
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

def solve(case,n,l,o,d) :
    MAX = 1<<32
    c = MAX
    for i in range(n):
        x = d[i]^o[0]
        s = [x^o[j] for j in range(n)]
        if set(s) == set(d):
            c = min(c, bin(x).count('1'))
    ans = c if c < MAX else "NOT POSSIBLE"
    print("Case #%d: %s" % (case+1, ans))

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,l) = myin.getintline(2)
        o = myin.getbinline(n)
        d = myin.getbinline(n)
        solve(tt,n,l,o,d)
