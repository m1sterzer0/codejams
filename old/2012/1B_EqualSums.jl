using Random

function solveit(d::Dict{Int64,Int64}, a::Vector{Int64}, s::Int64)
    while s != 0; v = d[s]; push!(a,v); s -= v; end
end

function solvesmall(S::Vector{Int64})
    d::Dict{Int64,Int64} = Dict{Int64,Int64}()
    a::Vector{Int64} = []
    b::Vector{Int64} = []

    for s in S
        if haskey(d,s); push!(a,s); solveit(d,b,s); return (a,b); end
        ss = []
        for (k,v) in d
            if haskey(d,k+s); push!(ss,k); end
        end
        if length(ss) > 0
            sort!(ss); k = ss[1]
            push!(a,s); solveit(d,a,k); solveit(d,b,k+s)
            return (a,b)
        end
        kk = [x for x in keys(d)]  ## Snapshot the keys -- don't modify dict while using (k,v) iterator
        for k in kk; d[s+k] = s; end
        d[s] = s
    end
    push!(a,1); push!(b,2); push!(b,3); return (a,b)
end

issame(a,b) = for x in a; if x in b; continue; end; return false; end; return true

function main(infn="")
    Random.seed!(8675309)
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    SS::Vector{Int16} = [Int16(x) for x in 1:500]
    sb::Array{Int16,2} = fill(Int16(0),1_000_000,6)
    d::Dict{Int64,Int32} = Dict{Int64,Int32}()

    for qq in 1:tt
        print("Case #$qq:\n")
        S = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = popfirst!(S)
        if N == 20
            (a,b) = solvesmall(S)
        else
            found=false
            while(!found)
                empty!(d)
                fill!(sb,Int16(0))
                for iter::Int32 in 1:1_000_000
                    for i in 1:6; x = rand(i:500); SS[i],SS[x] = SS[x],SS[i]; end
                    x = sum(S[i] for i in SS[1:6])
                    if haskey(d,x)
                        if issame(SS[1:6],sb[d[x],:]); continue; end
                        a = [S[xx] for xx in SS[1:6]]
                        b = [S[xx] for xx in sb[d[x],:]]
                        found=true
                        break
                    else
                        d[x] = iter
                        sb[iter,:] = SS[1:6]
                    end
                end
            end
        end
        astr = join(a," ")
        bstr = join(b," ")
        print("$astr\n")
        print("$bstr\n")
    end
end

main()
