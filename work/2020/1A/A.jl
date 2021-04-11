function solveLarge(N::Int64,P::Vector{String})::String
    prefix::Vector{Char} = []; lenpre = 0
    suffix::Vector{Char} = []; lensuf = 0
    middle::Vector{Char} = []
    for i in 1:N
        lp = length(P[i])
        i1,i2 = 1,lp
        while P[i][i1] != '*'
            c = P[i][i1]
            if i1 <= lenpre && c != prefix[i1]; return "*"; end
            if i1 > lenpre; push!(prefix,c); lenpre += 1; end
            i1 += 1
        end
        while P[i][i2] != '*'
            c = P[i][i2]
            invidx = lp+1-i2
            if invidx <= lensuf && c != suffix[invidx]; return "*"; end
            if invidx > lensuf; push!(suffix,c); lensuf += 1; end
            i2 -= 1
        end
        for i3 in i1+1:i2-1
            c = P[i][i3]
            if c != '*'; push!(middle,c); end
        end
    end
    ansarr = vcat(prefix,middle,reverse(suffix))
    return join(ansarr,"")
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
        P::Vector{String} = []
        for i in 1:N; push!(P,gs()); end
        ans = solveLarge(N,P)
        print("$ans\n")
    end
end

main()


