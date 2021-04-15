using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        N,D = [parse(Int64,x) for x in split(readline(infile))]
        Darr = [parse(Int64,x) for x in split(readline(infile))]

        if N == 1; print("0\n"); break; end

        ## First, we check to make sure we are periodic at 2*D
        done = false
        for i in 1:N-2*D
            if Darr[i] != Darr[i+2*D]
                print("CHEATERS!\n")
                done = true
                break
            end
        end
        if done; continue; end

        ## We note the following
        ## [1,1,1,1,0,0,0,0] . [1,0,0,1,-1,0,0,-1] = 2
        ## [0,1,1,1,1,0,0,0] . [1,0,0,1,-1,0,0,-1] = 0
        ## [0,0,1,1,1,1,0,0] . [1,0,0,1,-1,0,0,-1] = 0
        ## [0,0,0,1,1,1,1,0] . [1,0,0,1,-1,0,0,-1] = 0
        ## [a,b,c,d,a,b,c,d] . [1,0,0,1,-1,0,0,-1] = 0

        ## This gives rise to the following idea
        ## Assume max period is 2^k
        ## For i in k downto 1
        ##    Calculate the 2^(k-1) coefficients with the dot product scheme above
        ##    Adjust the sequence
        ##    Confirm it now has periodicity 2^(k-1) (not really needed)

        maxperiod = 2
        while 2*maxperiod <= 2*D; maxperiod *= 2; end
        w::Vector{Int64} = Darr[1:maxperiod]
        ans = 0
        done = false
        while maxperiod > 1
            hp = maxperiod ÷ 2
            for i in 1:hp
                x = w[i] + w[i+hp-1] - w[i+hp] - w[i == 1 ? maxperiod : i-1]
                if x % 2 == 1
                    done = true
                elseif x > 0
                    inc = x ÷ 2
                    ans += inc
                    for j in i+hp:i+2*hp-1
                        ii = j > maxperiod ? j - maxperiod : j
                        w[ii] += inc ## Add the water diverted by the farmers back into the river
                    end
                elseif x < 0
                    inc = -x ÷ 2
                    ans += inc
                    for j in i:i+hp-1
                        w[j] += inc ## Add the water diverted by the farmers back into the river
                    end
                end
            end
            for i in 1:hp
                if w[i] != w[i+hp]; done=true; end
            end
            if done; print("CHEATERS!\n"); break; end
            maxperiod ÷= 2
        end
        ## Final check, need to ensure that the total amount of water in the river is >= number of farmers
        ## For example 5 0 1 0 5 0 1 0 ... requires 7 farmers to balance, but after balancing river only has
        ##     5 units of water, so it doesn't work
        if !done; print(w[1] >= ans ? "$ans\n" : "CHEATERS!\n"); end
    end
end

main()
