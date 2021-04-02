######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function presolvePow10()
    sarr = zeros(Int64,15)
    sarr[1] = 1
    sarr[2] = 10
    for i in 3:15; sarr[i] = sarr[i-1] + (i%2==1 ? 10^((i-1)÷2) + 10^((i-1)÷2) - 1 : 10^(i÷2) + 10^(i÷2-1) - 1); end
    return sarr
end

function solveit(lhalf,rhalf)
    if parse(Int64,rhalf) == 0
        newlhalf = string(parse(Int64,lhalf)-1)  ## Will still have the same number of digits, since we already filtered out the 10^n case 
        return parse(Int64,reverse(newlhalf)) - 1 + 1 + 10^length(rhalf) ## We have to roll it over
    else
        return parse(Int64,reverse(lhalf)) - 1 + 1 + parse(Int64,rhalf)
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    sarr = presolvePow10()
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        ans = 0
        if N < 10  ## Do single digit case separately
            ans = N
        else
            strN = string(N)
            ndig = length(strN)
            baseans = sarr[ndig]
            ans = baseans
            if rstrip(strN,['0']) != "1" ## we need to do more moves if we are not a power of 10
                hndig = ndig ÷ 2
                ans = baseans + (N-10^(ndig-1))  ## option if we just count up to the number
                ans = min(ans, baseans + solveit(strN[1:hndig],strN[hndig+1:ndig]))
                if ndig % 2 == 1
                    ans = min(ans, baseans + solveit(strN[1:hndig+1],strN[hndig+2:ndig]))
                end
            end
        end
        print("$ans\n")
    end
end

main()
    
