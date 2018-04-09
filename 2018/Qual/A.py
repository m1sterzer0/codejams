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

def parse(p) :
    cnt = p.count('C')
    a = [0] * (cnt+1)
    idx = 0
    for c in p :
        if c == 'S' : a[idx] += 1
        else        : idx += 1
    return a

def solve(d,p) :
    if p.count('S') > d : return "IMPOSSIBLE"
    a = parse(p)
    mult = 1; dmg = 0
    for n in a : dmg += mult*n; mult *= 2
    mult /= 2
    swaps = 0
    for i in range(len(a)-1,-1,-1) :
        if dmg - mult // 2 * a[i] > d :
            dmg -= mult // 2 * a[i]
            swaps += a[i]
            a[i-1] += a[i]
            a[i] = 0
            mult = mult // 2
        else :
            mult =  mult //2
            while dmg > d : dmg -= mult; a[i] -= 1; a[i-1] += 1; swaps += 1
            return str(swaps)

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline(1)
    for tt in range(t) :
        (ds,p) = myin.getstringline(2)
        d = int(ds)
        ans = solve(d,p) 
        print("Case #%d: %s" % (tt+1,ans))
