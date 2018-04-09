import fileinput
import sys
import string
from operator import itemgetter

class MyInput(object) :
    def __init__(self,default_file=None) :
        self.fh = sys.stdin
        if (len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
    def getintline(self,n=-1) : 
        ans = tuple(int(x) for x in self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans
    def getfloatline(self,n=-1) :
        ans = tuple(float(x) for x in self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d floats but got %d in MyInput.getfloatline'%(n,len(ans)))
        return ans
    def getstringline(self,n=-1) :
        ans = tuple(self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d strings but got %d in MyInput.getstringline'%(n,len(ans)))
        return ans
    def getbinline(self,n=-1) :
        ans = tuple(int(x,2) for x in self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d bins but got %d in MyInput.getbinline'%(n,len(ans)))
        return ans

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline(1)
    capLetters = [x for x in string.ascii_uppercase]
    for tt in range(t) :
        (n,) = myin.getintline(1)
        people = myin.getintline(n)
        s = sorted(zip(capLetters[0:n],people), reverse=True, key=itemgetter(1))
        ans = []
        totalPeople = sum([x[1] for x in s])
        (minorityIdx,minorityCnt) = (2,0) if n == 2 else (2,s[2][1])

        ## Step 1, remove from the majority party until matched with the 2nd place party
        ## Step 2, remove everyone that isn't from the first two parties.
        ## Step 3, remove the people from the top two parties in pairs
        for i in range(s[0][1]-s[1][1]) : ans.append(s[0][0])
        for i in range(2,n) :
            for j in range(s[i][1]) :
                ans.append(s[i][0])
        pairStr = s[0][0] + s[1][0]
        for i in range(s[1][1]) : ans.append(pairStr)
        print("Case #%d: %s" % (tt+1," ".join(ans)))
