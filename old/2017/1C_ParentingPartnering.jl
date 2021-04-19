using Printf

#########################################################################################################
### 1) Because the time of the day is just a circle, we can start counting at the earliest apppointment
### 2) All intervals break down into 5 possibilities
###    -- C must have baby
###    -- J must have baby
###    -- C|J can have baby with no change to the answer (i.e. this interval is between a "C must have baby" and "J must have baby")
###    -- prefer for C to have baby (costs 2 transitions to give baby to J)
###    -- prefer for J to have baby (costs 2 transitions to give baby to C)
### 3) This leads to the following algorithm
###    -- Construct all of the intervals and calculate the minimum number of forced transitions
###    -- For each of C & J (in the example below, lets assume C)
###       * Start with the minimum number of transitions
###       * Count the "C must have baby" time + "Prefer C" time + "C|J" time
###       * While that is < 720 minutes
###         Add 2 transitions
###         Add the largest element left from the "prefer J" list
###    -- The answer is the maximum of running that algorithm with C vs. running it with J
#########################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        ## Parse Input
        Ac,Aj = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        C,D = fill(0,Ac),fill(0,Ac)
        for i in 1:Ac
            C[i],D[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        J,K = fill(0,Aj),fill(0,Aj)
        for i in 1:Aj
            J[i],K[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        ## Special case out no appointmnets
        if Ac == 0 && Aj == 0; print("2\n"); continue; end
       
        ## Intervals
        intervals = vcat([(C[i],D[i],'c') for i in 1:Ac],[(J[i],K[i],'j') for i in 1:Aj])
        sort!(intervals)

        cpref = Vector{Int64}()
        jpref = Vector{Int64}()
        csum = 0
        jsum = 0
        minTransitions = 0
        for (i,ii1) in enumerate(intervals)
            if ii1[3] == 'c'; csum += (ii1[2]-ii1[1]); end
            if ii1[3] in 'j'; jsum += (ii1[2]-ii1[1];) end
            ii2 = (i == length(intervals)) ? intervals[1] : intervals[i+1]
            gapTime = (ii2[1] + 1440 - ii1[2]) % 1440
            if      ii1[3] != ii2[3]; csum += gapTime; jsum += gapTime; minTransitions += 1
            elseif  ii1[3] == 'c'; csum += gapTime; push!(cpref,gapTime)
            elseif  ii1[3] == 'j'; jsum += gapTime; push!(jpref,gapTime)
            end
        end
        sort!(cpref); sort!(jpref)
        best = minTransitions
        for (xsum,xpref) in [(csum,jpref),(jsum,cpref)]
            current = minTransitions
            while(xsum < 720)
                current += 2
                xsum += pop!(xpref)
            end
            best = max(best,current)
        end
        print("$best\n")
    end
end

main()
