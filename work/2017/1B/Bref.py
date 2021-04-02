def solve(c0, c1, c2):
    if c0 > c1 + c2:
        return None
    surplus = c1 + c2 - c0
    result = []
    for i in range(surplus):
        result.extend((0, 1, 2))
    for i in range(c1 - surplus):
        result.extend((0, 1))
    for i in range(c2 - surplus):
        result.extend((0, 2))
    return result

for i in range(int(input())):
    N, R, O, Y, G, B, V = [int(x) for x in input().split(" ")]
    
    colors = []
    arr = []
    if R < G or Y < V or B < O:
        arr = None
    elif R == G != 0 and N > R + G:
        arr = None
    elif Y == V != 0 and N > Y + V:
        arr = None
    elif B == O != 0 and N > B + O:
        arr = None
    else:
        R -= G
        Y -= V
        B -= O
        if R >= Y and R >= B:
            colors = ["R", "Y", "B"]
            arr = solve(R, Y, B)
        elif Y >= B and Y >= R:
            colors = ["Y", "B", "R"]
            arr = solve(Y, B, R)
        elif B >= R and B >= Y:
            colors = ["B", "R", "Y"]
            arr = solve(B, R, Y)

    result = ""
    if arr == None:
        result = "IMPOSSIBLE"
    else:
        if len(arr) == 0:
            if G > 0 and V == O == 0:
                result = "GR" * G
            elif V > 0 and O == G == 0:
                result = "VY" * V
            elif O > 0 and G == V == 0:
                result = "OB" * O
        else:
            result = "".join([colors[x] for x in arr])
            for j in range(G):
                result = result.replace("R", "RGR", 1)
            for j in range(V):
                result = result.replace("Y", "YVY", 1)
            for j in range(O):
                result = result.replace("B", "BOB", 1)
    if result != "IMPOSSIBLE":
        assert(len(result) == N)
    print("Case #%d: %s" % (i + 1, result))