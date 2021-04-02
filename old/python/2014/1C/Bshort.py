import fileinput
import sys
import functools
from string import ascii_lowercase
from itertools import permutations

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

def checkPerm(p) :
    p2 = myreduce("".join(p))
    used = set()
    for c in p2 :
        if c in used : return False
        used.add(c)
    return True

def myreduce(t) :
    ans = []; last = '-'
    for c in t :
        if c != last : ans.append(c)
        last = c
    return "".join(ans)


if __name__ == "__main__" :
    myin = MyInput("B.in")
    (t,) = myin.getintline(1)
    for tt in range(t) :
        (n,) = myin.getintline()
        trains = myin.getstringline(n)
        rtrains = map(myreduce,trains)
        ans = 0
        for p in permutations(rtrains) :
            if checkPerm(p) : ans += 1
        print("Case #%d: %d" % (tt+1,ans))
