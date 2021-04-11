function countzeros(NN::Int64)::Int64
    res,pv = 0,1
    while (NN > pv)
        if NN & pv == 0; res += 1; end
        pv = pv << 1
    end
    return res
end

function solveLarge(N::Int64)
    NN = N
    while (NN + countzeros(NN) > N); NN -= 1; end
    K,left,ans::Vector{Tuple{Int64,Int64}} = 0,true,[]
    for i in 1:60
        if (1 << (i-1)) & NN != 0;
            K += (1<<(i-1))
            if left; for j in 1:i; push!(ans,(i,j)); end
            else; for j in i:-1:1; push!(ans,(i,j)); end
            end
            left = !left
        else
            K += 1
            if left; push!(ans,(i,1)); else; push!(ans,(i,i)); end
        end
        if K == N; break; end
    end
    return ans
end

function test()
    for N in 1:1000; print("$N\n"); solveLarge(N); end
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
        print("Case #$qq:\n")
        N = gi()
        ans = solveLarge(N)
        for (x,y) in ans; print("$x $y\n"); end
    end
end

main()
#test()


