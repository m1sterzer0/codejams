
gg = []
gg.append("1")

for i1 in "012" :
    for i2 in "012" :
        if i1 != "0" or i2 != "0" :
            gg.append(f"{i1}{i2}")

for i1 in "0123" :
    for i2 in "0123" :
        for i3 in "0123" :
            if i1 != "0" or i2 != "0" or i3 != "0":
                gg.append(f"{i1}{i2}{i3}")

for i1 in "01234" :
    for i2 in "01234" :
        for i3 in "01234" :
            for i4 in "01234" :
                if i1 != "0" or i2 != "0" or i3 != "0" or i4 != "0" :
                    gg.append(f"{i1}{i2}{i3}{i4}")

for i1 in "012345" :
    for i2 in "012345" :
        for i3 in "012345" :
            for i4 in "012345" :
                for i5 in "012345" :
                    if i1 != "0" or i2 != "0" or i3 != "0" or i4 != "0" or i5 != "0":
                        gg.append(f"{i1}{i2}{i3}{i4}{i5}")

with open("A.in2","wt") as fp :
    print(len(gg),file=fp)
    for g in gg :
        print(g,file=fp)



