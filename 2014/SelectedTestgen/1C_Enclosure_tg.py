tcs = []
for r in range(1,21) :
    cmax = 20 // r
    for c in range(1,cmax+1) :
        for k in range(1,r*c+1) :
            tcs.append((r,c,k))

with open("Ctc1.in","wt") as fp :
    T = len(tcs)
    print(T,file=fp)
    for (r,c,k) in tcs :
        print(f"{r} {c} {k}",file=fp)
