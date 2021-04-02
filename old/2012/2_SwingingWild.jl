
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        DD::Vector{Int64} = fill(0,N)
        LL::Vector{Int64} = fill(0,N)
        for i in 1:N; DD[i],LL[i] = gis(); end
        D = gi()
        ## Add a vine at the end 
        if DD[N] < D; N += 1; push!(DD,D); push!(LL,1); end
        sb::Vector{Int64} = fill(0,N)  ## Keeps track of the maximum distance down from the top we can reach the vine.  0 means we can't reach Int64
        sb[1] = DD[1]
        for i in 1:N
            l = sb[i]
            if l == 0; continue; end
            for j in i+1:N
                if DD[j]-DD[i] > l; break; end
                l2 = min(DD[j]-DD[i],LL[j])
                sb[j] = max(sb[j],l2)
            end
        end
        ans = sb[N] == 0 ? "NO" : "YES"
        print("$ans\n")
    end
end

main()
