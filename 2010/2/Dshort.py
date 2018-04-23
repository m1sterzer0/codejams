import sys
import math
import heapq
from operator import itemgetter
class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

class pt(object) :
    def __init__(self,x=0,y=0) : self.x = x; self.y = y
    def length(self)    : math.sqrt(self.x*self.x+self.y*self.y)

    @staticmethod
    def dist2(a,b) : return (b.x-a.x)**2 + (b.y-a.y)**2

    @staticmethod
    def dist(a,b) : return math.sqrt(pt.dist2(a,b))

    @staticmethod
    def add(a,b)     : z = pt(); z.x = a.x + b.x; z.y = a.y + b.y; return z

    @staticmethod
    def sub(a,b)     : z = pt(); z.x = a.x - b.x; z.y = a.y - b.y; return z
        
    @staticmethod
    def scale(c,p)   : z = pt(); z.x = c * p.x; z.y = c * p.y; return z

    @staticmethod
    def dot(a,b)     : return a.x * b.x + a.y * b.y

    @staticmethod
    def project(b,a)  : ll = a.x*a.x + a.y*a.y; return pt.scale(pt.dot(a,b)/ll,a)

    @staticmethod
    def reflect(b,a1,a2) :
        a = pt.sub(a2,a1)
        v = pt.sub(b,a1)
        v1 = pt.project(v,a); v2 = pt.sub(v,v1); d = pt.sub(v1,v2)
        z = pt.add(a1,d) 
        return z

def calcRegionArea(r,d) :
    cosTheta = (2 * r * r - d * d) / (2 * r * r) 
    theta    = math.acos(cosTheta)
    arcArea  = 0.5 * r * r * theta
    triArea  = 0.5 * r * r * math.sin(theta)
    return arcArea-triArea

def oppositeSide(a,b,p,q) :
    v1 = (p.y-q.y)*(a.x-p.x) + (q.x-p.x)*(a.y-p.y)
    v2 = (p.y-q.y)*(b.x-p.x) + (q.x-p.x)*(b.y-p.y)
    return True if v1 * v2 < 0 else False

## Special for n == 2
def solvecase2(n,ps,q) :
    assert n == 2
    p0 = pt(ps[0][0],ps[0][1])
    p1 = pt(ps[1][0],ps[1][1])
    qq = pt(q[0],q[1])
    r0,r1 = pt.dist(p0,qq),pt.dist(p1,qq)

    q2 = pt.reflect(qq,p0,p1)
    tdist = pt.dist(qq,q2)

    reg0 = calcRegionArea(r0,tdist)
    reg1 = calcRegionArea(r1,tdist)

    ## This is sloppy, we need to figure a better way
    if oppositeSide(p0,p1,qq,q2) : ans = reg0 + reg1
    elif r0 < r1                 : ans = math.pi * r0 * r0 - reg0 + reg1
    else                         : ans = math.pi * r1 * r1 - reg1 + reg0
    return ans

def solve(inp) :
    (n,m,ps,qs) = inp
    areas = [solvecase2(n,ps,x) for x in qs]
    answers = [ "%.8f" % x for x in areas ]
    return " ".join(answers)

def getInputs(IN) :
    n,m = IN.ints()
    ps = [ tuple(IN.ints()) for x in range(n) ]
    qs = [ tuple(IN.ints()) for x in range(m) ]
    return (n,m,ps,qs)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %s" % (tt,ans))
