function solveLarge(N::Int64,S::Vector{Int64},E::Vector{Int64})::String
    tasks = [(S[i],E[i],i) for i in 1:N]
    sort!(tasks)
    assignments = ['X' for i in 1:N]
    cavail,javail = 0,0
    for (s,e,i) in tasks
        if     cavail <= s; assignments[i] = 'C'; cavail = e
        elseif javail <= s; assignments[i] = 'J'; javail = e
        else;  return "IMPOSSIBLE"
        end
    end
    return join(assignments,"")
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        S::Vector{Int64} = fill(0,N)
        E::Vector{Int64} = fill(0,N)
        for i in 1:N; S[i],E[i] = gis(); end
        ans = solveLarge(N,S,E)
        print("$ans\n")
    end
end

main()
