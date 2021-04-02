import sys

def doit(arr) :
    ans = []
    if len(arr) == 1 :
        for i in range(10) :
            if arr[0] >= 0 and arr[0] != i : continue
            ans.append(i)
    elif len(arr) == 2 :
        for i in range(10) :
            if arr[0] >= 0 and arr[0] != i : continue
            for j in range(10) :
                if arr[1] >= 0 and arr[1] != j : continue
                ans.append(10*i+j)
    else:
        for i in range(10) :
            if arr[0] >= 0 and arr[0] != i : continue
            for j in range(10) :
                if arr[1] >= 0 and arr[1] != j : continue
                for k in range(10) :
                    if arr[2] >= 0 and arr[2] != k : continue
                    ans.append(100*i+10*j+k)
    return ans

def main(fn=None) :
    fp = open(fn,'rt') if fn != None else open(sys.argv[1],'rt') if len(sys.argv) >= 2 else sys.stdin
    tt = int(fp.readline())
    for qq in range(1,tt+1) :
        print("Case #%d: " % qq, end="")
        C,J = fp.readline().rstrip().split()
        Cdig = [-1 if x == '?' else int(x) for x in C]
        Jdig = [-1 if x == '?' else int(x) for x in J]
        qmarks = Cdig.count(-1) + Jdig.count(-1)
        if qmarks == 6 :
            print("000 000")
            continue
        best = (9999,0,0)
        cpos = doit(Cdig)
        jpos = doit(Jdig)
        for c in cpos :
            for j in jpos :
                best = min(best,(abs(c-j),c,j))
        if len(Cdig) == 1 :
            print("%d %d" % (best[1],best[2]))
        elif len(Cdig) == 2 :
            print("%02d %02d" % (best[1],best[2]))
        else :
            print("%03d %03d" % (best[1],best[2]))

if __name__ == "__main__" :
    main()