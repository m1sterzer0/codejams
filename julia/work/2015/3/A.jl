######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        solveit(infile)
        #@time solveit(infile)
    end
end

function solveit(infile)
    N,D = [parse(Int32,x) for x in split(readline(infile))]
    S0,As,Cs,Rs = [parse(Int32,x) for x in split(readline(infile))]
    M0,Am,Cm,Rm = [parse(Int32,x) for x in split(readline(infile))]

    ## A bit awkward to deal with one indexing, but not impossible
    S::Vector{Int32} = [S0]
    for i in 2:N; push!(S,(S[end]*As+Cs) % Rs); end
    M::Vector{Int32} = [M0]
    for i in 2:N; push!(M,(M[end]*Am+Cm) % Rm); end
    MM::Vector{Int32} = [(i == 1 ? -1 : (M[i] % (i-1))) + 1 for i in 1:N]

    ## Note that every persons manager has an ID less than them, so there is
    ## no need to create a dependency tree-based order.  We can just process the
    ## nodes in numerical order for a tops-down traversal.
    ranges::Vector{Tuple{Int32,Int32}} = fill((0,0),N)
    for i in 1:N
        if i == 1
            ranges[i] = (max(0,S[1] - D), S[1])
        else
            boss = ranges[MM[i]]
            ranges[i] = (max(0,S[i]-D,boss[1]), min(S[i],boss[2]))
        end
    end

    ## Filter out invalid ranges
    incEvents::Vector{Int32} = [x[1] for x in ranges if x[1] <= x[2]]
    decEvents::Vector{Int32} = [x[2] for x in ranges if x[1] <= x[2]]

    sort!(incEvents)
    sort!(decEvents)

    best,cur = 0,0
    while(!isempty(incEvents))
        if (isempty(decEvents) || incEvents[1] <= decEvents[1])
            cur += 1
            best = max(best,cur)
            popfirst!(incEvents)
        else
            cur -= 1
            popfirst!(decEvents)
        end
    end
    print("$best\n")
end

main()
        
