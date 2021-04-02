using Printf

######################################################################################################
### We first catalog which letters appear in which numbers
### A                            N 1799
### B                            O 0124
### C                            P
### D                            Q
### E 013357789                  R 034
### F 45                         S 67
### G 8                          T 238
### H 38                         U 4
### I 5689                       V 57
### J                            W 2
### K                            X 6
### L                            Y
### M                            Z 0
###
### Let c0, c1, ... c9 represent the counts of each of those digits
### 1) 5 digits can be read off from letters which only appear in one of the digits' names:
###    c0 = Z, c2 = W, c4 = U, c6 = X, c8 = G
### 2) 3 more digits can be deduced from letters which appear in exactly two of the digits' names:
###    c5 = F - c4, c3 = H - c8, c7 = S - c6
### 3) Now we just have two remaining
###    c1 = O - c0 - c2 - c4, c9 = I - c5 - c6 - c8
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S = rstrip(readline(infile))
        myCounts = Dict{Char,Int64}()
        for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; myCounts[c] = 0; end
        for c in S; myCounts[c] += 1; end
        digCounts = Dict{Int64,Int64}()  ## Using a dict to get around zero index
        for c in 0:9; digCounts[c] = 0; end
        for (x,c) in zip([0,2,4,6,8],['Z','W','U','X','G']); digCounts[x] = myCounts[c]; end
        digCounts[5] = myCounts['F'] - digCounts[4]
        digCounts[3] = myCounts['H'] - digCounts[8]
        digCounts[7] = myCounts['S'] - digCounts[6]
        digCounts[1] = myCounts['O'] - digCounts[0] - digCounts[2] - digCounts[4]
        digCounts[9] = myCounts['I'] - digCounts[5] - digCounts[6] - digCounts[8]
        ans = prod(string(x)^digCounts[x] for x in 0:9)
        print("$ans\n")
    end
end

main()