import fileinput
import sys

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
    for tt in range(t) :
        (a,b) = myin.getintline(2); b += 1
        (n,)  = myin.getintline(1)
        for i in range(n) :
            g = (a+b)//2
            print(g,flush=True)
            (res,) = myin.getstringline(1)
            if   res == "CORRECT"   : break
            elif res == "TOO_BIG"   : b = g
            elif res == "TOO_SMALL" : a = g
            else                    : raise Exception("Should not get here")
