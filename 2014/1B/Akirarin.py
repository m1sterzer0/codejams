import sys
import fileinput

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
    myin = MyInput("A.short")
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,) = myin.getintline(1)
        z = [ myin.getstringline(1)[0] for i in range(n)]

        p = True

        a = []
        b = []
        for i in range(n):
            a.append([])
            b.append([])
            for j, c in enumerate(z[i]):
                if j == 0 or c != a[i][-1][0]:
                    a[i].append([c, 1])
                    b[i].append(c)
                else:
                    a[i][-1][1] += 1
            if i > 0 and b[i] != b[i-1]:
                p = False
                ans = "Fegla Won"
                break

        if p:
            s = 0
            t = zip(*a)
            for u in t:
                m = 1<<32
                for k in range(1, 101):
                    m = min(m, sum(map(lambda x: abs(k-x[1]), u)))
                s += m
            ans = s

        print("Case #%d: %s" % (tt+1, ans))


