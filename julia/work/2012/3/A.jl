
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
        N = gi(); L = gis(); P = gis()
        function myisless(a::Int64,b::Int64)::Bool
            x1 = 100*L[a] + (100-P[a])*L[b]
            x2 = 100*L[b] + (100-P[b])*L[a]
            return x1 < x2 || x1 == x2 && a < b
        end
        ans = collect(1:N)
        sort!(ans,lt=myisless)
        ansstr = join([x-1 for x in ans]," ")
        print("$ansstr\n")
    end
end

main()
