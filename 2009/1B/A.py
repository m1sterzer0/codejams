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
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

def tokenize(s) :
    prefix,suffix = [],[]
    ## Take off any prefix characters
    i = 0
    while i < len(s) and s[i] == "(" : prefix.append('('); i += 1
    if i == len(s) : return prefix
    j = len(s) - 1
    while j >= 0 and s[j] == ")" : suffix.append(')'); j -= 1
    if i > j : return prefix + suffix
    return prefix + [s[i:j+1]] + suffix

def parseTree(tokens,idx) :
    assert tokens[idx] == "("
    weight = float(tokens[idx+1])
    if tokens[idx+2] == ")" : return [weight],idx+2
    attribute = tokens[idx+2]
    dt1,i1 = parseTree(tokens,idx+3)
    dt2,i2 = parseTree(tokens,i1+1)
    assert tokens[i2+1] == ")"
    return [weight, attribute, dt1, dt2],i2+1

def evalAnimal(dtree,animal, p) :
    p *= dtree[0]
    if len(dtree) == 1 : return p
    else :
        trait = dtree[1]
        if trait in animal[2:] : p = evalAnimal(dtree[2], animal, p)
        else                   : p = evalAnimal(dtree[3], animal, p)
        return p

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        l, = IN.ints()
        tokens = []
        for i in range(l) :
            s = IN.input().rstrip().lstrip().split()
            for ss in s :
                t = tokenize(ss)
                tokens.extend(t)
        tr,_ = parseTree(tokens,0)
        a, = IN.ints()
        print("Case #%d:" % tt)

        for i in range(a) :
            animal = tuple(IN.strs())
            ans = evalAnimal(tr,animal, 1.0)
            print("%.8f" % ans)
