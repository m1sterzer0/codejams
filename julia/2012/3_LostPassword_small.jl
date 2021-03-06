
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    leet = Dict('o'=>'0','i'=>'1','e'=>'3','a'=>'4','s'=>'5','t'=>'7','b'=>'8','g'=>'9')
    for qq in 1:tt
        print("Case #$qq: ")
        k = gi()
        S = gs()
        if k != 2; print("0\n"); continue; end
        indeg = Dict{Char,Int64}()
        outdeg = Dict{Char,Int64}()
        for c in "abcdefghijklmnopqrstuvwxyz01345789"; indeg[c] = 0; outdeg[c] = 0; end
        edges = Set{Tuple{Char,Char}}()
        for i in 1:length(S)-1
            a,b = S[i],S[i+1]
            push!(edges,(a,b))
            if haskey(leet,a); push!(edges,(leet[a],b)); end 
            if haskey(leet,b); push!(edges,(a,leet[b])); end
            if haskey(leet,a) && haskey(leet,b); push!(edges,(leet[a],leet[b])); end
        end
        for (a,b) in edges; outdeg[a] += 1; indeg[b] += 1; end
        totedges = sum(indeg[c] for c in keys(indeg))
        neededEdges = 0
        ## Only count blocks w/ indegee > outdegree to avoid the doublecount
        for c in keys(indeg); if indeg[c] > outdeg[c]; neededEdges += indeg[c]-outdeg[c]; end; end
        if neededEdges > 1; neededEdges -= 1; end ## Difference between a path and a cycle
        totlen = 1 + totedges + neededEdges
        print("$totlen\n")
    end
end

main()

