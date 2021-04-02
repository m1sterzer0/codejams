
tcs = []
for r in range(1,5+1) :
    for c in range(1,5+1) :
        for m in range(r*c) :
            tcs.append((r,c,m))
with open("Dtc1.in","wt") as fp :
    n = len(tcs)
    print(f"{n}",file=fp)
    for (r,c,m) in tcs :
        print(f"{r} {c} {m}",file=fp)