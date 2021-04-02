
using Random
function main(infn="")
    Random.seed!(8675309)
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
        N,W,L = gis()
        R::Vector{Int64} = gis()
        X::Vector{Int64} = fill(0,N)
        Y::Vector{Int64} = fill(0,N) 
        indices = collect(1:N)
        function check(i::Int64)::Bool
            i1 = indices[i]
            for j in 1:i-1
                i2 = indices[j]
                if (X[i1]-X[i2])^2+(Y[i1]-Y[i2])^2 < (R[i1]+R[i2])^2; return false; end
            end
            return true
        end
            
        good = false
        while !good
            shuffle!(indices)
            for i in 1:N; X[i] = rand(0:W); Y[i] = rand(0:L); end
            ## Fixing code
            good = true
            for i in 2:N
                goodbit = false
                for k in 1:2000
                    if check(i); goodbit = true; break; end
                    X[indices[i]] = rand(0:W)
                    Y[indices[i]] = rand(0:L)
                end
                if !goodbit; good = false; break; end
            end
        end

        ans = []
        for i in 1:N; push!(ans,X[i]); push!(ans,Y[i]); end
        ansstr = join(ans," ")
        print("$ansstr\n")
    end
end

main()

