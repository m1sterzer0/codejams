######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        inp = split(readline(infile))
        N = parse(Int64,inp[1])
        V,X = [parse(Float64,x) for x in inp[2:3]]
        ds = Vector{Tuple{Float64,Float64}}()
        for i in 1:N
            R,C = [parse(Float64,x) for x in split(readline(infile))]
            push!(ds,(C,R)) ## Ordered for the singletonRowSet
        end
        sort!(ds)
        
        ## Check for IMPOSSIBLE
        if ds[1][1] > X || ds[end][1] < X  ## Target temp is outside the range achievable with the faucets
            print("IMPOSSIBLE\n")
            continue
        elseif  ds[1][1] == X || ds[end][1] == X ## Requested temperatuire matches exactly
            ds2 = [x for x in ds if x[1] == X]
            newR = sum(x[2] for x in ds2)
            ans = V / newR
            print("$ans\n")
            continue
        end


        lastT = ds[1][1]
        lastR = ds[1][2]
        done = false
        for i in 2:N
            newR = sum(x[2] for x in ds[1:i])
            newT = sum(x[1]*x[2] for x in ds[1:i]) / newR
            if newT > X
                T0,R0,T1 = lastT,lastR,ds[i][1]
                newR = R0 + R0 * (X - T0) / (T1 - X)
                ans = V / newR
                print("$ans\n")
                done = true
                break
            end
            lastR,lastT = newR,newT
        end

        if !done
            for i in 1:N-1
                newR = sum(x[2] for x in ds[i+1:end])
                newT = sum(x[1]*x[2] for x in ds[i+1:end]) / newR
                if newT > X
                    T0,R0,T1 = newT,newR,ds[i][1]
                    newR = R0 + R0 * (T0 - X) / (X - T1)
                    ans = V / newR
                    print("$ans\n")
                    done = true
                    break
                end
                lastR,lastT = newR,newT
            end
        end

        if !done; print("-1.0000\n"); end
    end
end

main()
    