import sys
import math
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
        print("Case #%d: %.8f" % (tt,0))
        ac,aj = IN.ints()
        cameron,jaime = [],[]
        for _ in range(ac) : ci,di = IN.ints(); cameron.append((ci,di))
        for _ in range(aj) : ji,ki = IN.ints(); jaime.append((ji,ki))
        cameron.sort(); jaime.sort()
        
        ## If cameron has an activity at 0, then we swap cameron and jaime
        if ac > 0 and cameron[0][0] == 0 : ac,aj = aj,ac; cameron,jaime = jaime,cameron
        
        ## We can probably do this better, but this is what we're going to try
        ## value of 'J' means that 'J' has to watch here
        ## value of 'C' means that 'C" has to watch here
        ## value of 'j' means we are scheduling jaime 
        ## value of 'c' means we are scheduling cameron
        schedule = ['c'] * (24 * 60)
        for t in range(aj) :
            for x in range(t[0],t[1]) : schedule[x] = 'J'
        for t in range(ac) :
            for x in range(t[0],t[1]) : schedule[x] = 'C'

        transitions,last = 0,0
        for t in range(ac) :
            if t[0] != last : transitions += 1
            last = t[1]

        last = 'x'; gapStart = False; gapleft = 0; gaps = []
        for i in range(24 * 60) :
            if last == 'J' and schedule[i] == 'c' :
                gapStart = True; gapLeft = i
            elif schedule[i] == 'C' : gapStart = False
            elif gapStart and schedule[i] == 'J' :
                

        ## Now we look to find strings of Js without any intervening C's

