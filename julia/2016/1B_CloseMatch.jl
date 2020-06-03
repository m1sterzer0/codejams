using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### We use a little dynamic programming.  We calulate the following three values from right to left
###     ## most positive difference we can make from the last N digits
###     ## most negative difference we can make from the last N digits
###     ## closest absolute value that we can make from the right digits
###
### We then make a pass from left to right to choose the digits, given the prioritization.
######################################################################################################

function solveit(pv,c,j,pos,neg,closest)
    ans = 10^18
    if c != -1 && j != -1
        adder = c > j ? neg : c < j ? pos : closest
        ans = abs(pv*(c-j) + adder)
    elseif j != -1
        c1 = j == 0 ? 10^18 : abs(-pv+pos)
        c2 = j == 9 ? 10^18 : abs(pv+neg)
        ans = min(c1,c2,closest)
    elseif c != -1
        c1 = c == 9 ? 10^18 : abs(-pv+pos)
        c2 = c == 0 ? 10^18 : abs(pv+neg)
        ans = min(c1,c2,closest)
    else
        ans = min(abs(pv+neg),abs(-pv+pos),closest)
    end 
    return ans
end

function solveit2(pv,c,j,myclosest,pos,neg,closest)
    ## Prority is to choose c < j, then c == j, then c > j
    if c != -1 && j != -1
        return (c < j ? 1 : c > j ? -1 : 0, c, j)
    elseif j != -1
        ## Priority here is for the lowest c
        if     j != 0 && myclosest == abs(-pv + pos); return (1,j-1,j)
        elseif closest == myclosest;                  return (0,j,j)
        else;                                         return (-1,j+1,j)            
        end
    elseif c != -1
        ## Priority here is for the lowest j
        if     c != 0 && myclosest == pv + neg;  return (-1,c,c-1)
        elseif closest == myclosest;             return (0,c,c)
        else;                                    return (1,c,c+1)            
        end
    else
        ## Priority here is for (c,j) = (0,0), then (0,1), and finally (1,0)
        if     closest == myclosest;             return (0,0,0)
        elseif myclosest == abs(-pv+pos);        return (1,0,1)
        else;                                    return (-1,1,0)
        end
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C,J = split(rstrip(readline(infile)))
        Cdig = [x == '?' ? -1 : parse(Int64,x) for x in C]
        Jdig = [x == '?' ? -1 : parse(Int64,x) for x in J]

        numdig = length(C)
        mostPos = zeros(Int64,numdig)
        mostNeg = zeros(Int64,numdig)
        closest = zeros(Int64,numdig)

        ### Pass from right to left
        pv = 1; runningPos = 0; runningNeg = 0; runningClosest = 0
        for i in numdig:-1:1
            runningClosest = solveit(pv,Cdig[i],Jdig[i],runningPos,runningNeg,runningClosest)
            runningPos += pv * (( Cdig[i] == -1 ? 9 : Cdig[i]) - (Jdig[i] == -1 ? 0 : Jdig[i]))
            runningNeg += pv * (( Cdig[i] == -1 ? 0 : Cdig[i]) - (Jdig[i] == -1 ? 9 : Jdig[i]))
            mostPos[i],mostNeg[i],closest[i] = runningPos,runningNeg,runningClosest
            pv *= 10
        end
        
        ### Now we pass from left to right to chose the digits
        Cans = zeros(Int64,numdig)
        Jans = zeros(Int64,numdig)
        dir = 0
        pv = 10^(numdig-1)
        for i in 1:numdig
            if dir == 1
                Cans[i] = Cdig[i] == -1 ? 9 : Cdig[i]
                Jans[i] = Jdig[i] == -1 ? 0 : Jdig[i]
            elseif dir == -1
                Cans[i] = Cdig[i] == -1 ? 0 : Cdig[i]
                Jans[i] = Jdig[i] == -1 ? 9 : Jdig[i]
            else
                dir,Cans[i],Jans[i] = solveit2(pv,Cdig[i],Jdig[i],closest[i],
                                               i == numdig ? 0 : mostPos[i+1],
                                               i == numdig ? 0 : mostNeg[i+1],
                                               i == numdig ? 0 : closest[i+1])
            end
            pv = pv ÷ 10
        end

        Cstr = join(Cans,"")
        Jstr = join(Jans,"")

        print("$Cstr $Jstr\n")
    end
end

main()