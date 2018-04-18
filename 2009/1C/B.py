import sys
import math
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

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        n, = IN.ints()
        x,y,z,vx,vy,vz = [],[],[],[],[],[]
        arrs = (x,y,z,vx,vy,vz)
        for i in range(n) :
            nn = tuple(IN.ints())
            for arr,val in zip(arrs,nn) :
                arr.append(val)
        x0 = sum(x) / n
        y0 = sum(y) / n
        z0 = sum(z) / n
        a = sum(vx) / n
        b = sum(vy) / n
        c = sum(vz) / n

        ## Distance squared is x0^2 + y0^2 + z0^2 + 2(ax0 + by0 + cz0)*t + (a^2+b^2+c^2)*t^2
        ## Derivative at 0 is 2(ax0 + by0 + cz0)
        ## If derivative at zero is positive or 0, then minimum is at zero
        ## Otherwise, minimum is at t = -(ax0+by0+cz0) / (a^2+b^2+c^2)
        deriv_at_0 = 2 * (a * x0 + b * y0 + c * z0)
        if deriv_at_0 >= 0 :
            d_at_0 = math.sqrt(x0*x0+y0*y0+z0*z0)
            print("Case #%d: %.8f %.8f" % (tt,d_at_0,0.00))
        else :
            tmin = -1.0*(a * x0 + b * y0 + c * z0) / (a*a + b*b + c*c)
            d2min = (x0 + a * tmin)**2 + (y0 + b * tmin)**2 + (z0 + c * tmin)**2
            print("Case #%d: %.8f %.8f" % (tt,math.sqrt(d2min),tmin))
            
