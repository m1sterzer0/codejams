import sys

class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        n,k = IN.ints()

        ## Do full tiers
        amts = [n,n+1]
        cnts = [1,0]
        tiercnt = 1
        while k > tiercnt :
            ## two cases, amt[0] is even, and amt[0] is odd
            if amts[0] % 2 == 0 :
                newamt1 = amts[0]//2 - 1
                newamt2 = newamt1 + 1
                newcnt1 = cnts[0]
                newcnt2 = cnts[0] + 2 * cnts[1]
                amts = [newamt1,newamt2]; cnts = [newcnt1,newcnt2]
            else :
                newamt1 = amts[0]//2
                newamt2 = newamt1 + 1
                newcnt1 = 2 * cnts[0] + cnts[1]
                newcnt2 = cnts[1]
                amts = [newamt1,newamt2]; cnts = [newcnt1,newcnt2]
            k -= tiercnt
            tiercnt *= 2

        mymin,mymax = 0,0        
        if k <= cnts[1] :
            mymin = (amts[1]-1)//2; mymax = amts[1] - 1 - mymin
        else :
            mymin = (amts[0]-1)//2; mymax = amts[0] - 1 - mymin

        print("Case #%d: %d %d" % (tt,mymax, mymin))

