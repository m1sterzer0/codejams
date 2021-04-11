function solveLarge(S::String)::String
    vans::Vector{Char} = []; cur = 0
    for c in S
        n = Int64(c - '0')
        if n < cur; for i in 1:cur-n; push!(vans,')'); end
        elseif n > cur; for i in 1:n-cur; push!(vans,'('); end
        end 
        push!(vans,c)
        cur=n
    end
    for i in 1:Int64(vans[end]-'0'); push!(vans,')'); end
    return join(vans,"")
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
        S = gs()
        ans = solveLarge(S)
        print("$ans\n")
    end
end

main()

