using Printf

######################################################################################################
### Greedy plan should work.
### 1) Take each ingredient and calculate a range of the number of packets it can make.  Put this range
###    in a vector for that ingredient and then sort.
### 2) Then we loop over the following procedure:
###    -- Check the bottom of the queues and see if those ingredient packets make a kit
###    -- If so remove them all and increment the kit counter
###    -- If not, there are one or more ingredinets whose maximum number of kits is less than the
###       minimum of some other ingredient.  Ditch those ingredients.
######################################################################################################

## min packages = floor( Qij / (1.1*Ri))

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        R = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        Q = zeros(Int64,N,P)
        for i in 1:N
            Q[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        ## Step 1
        QQ = [[] for i in 1:N]
        for i in 1:N
            for j in 1:P
                minElem = (10 * Q[i,j] + 11 * R[i] - 1) ÷ (11 * R[i])  ### All integer ceiling function
                maxElem = (10 * Q[i,j]) ÷ (9 * R[i])
                if minElem > maxElem; continue; end
                push!(QQ[i],(minElem,maxElem))
            end
            sort!(QQ[i])
        end
            
        ## Step 2
        ans = 0
        while(true)
            if any(isempty,QQ); break; end
            mymin = maximum(QQ[i][1][1] for i in 1:N)
            mymax = minimum(QQ[i][1][2] for i in 1:N)
            if mymin <= mymax
                ans += 1
                foreach(popfirst!,QQ)
            else
                for i in 1:N
                    if QQ[i][1][2] < mymin; popfirst!(QQ[i]); end
                end
            end
        end

        print("$ans\n")
    end
end

main()
