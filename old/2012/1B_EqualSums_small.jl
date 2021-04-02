
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

function solvelarge(S::Vector{Int64})
    a::Vector{Int64} = [1,2]
    b::Vector{Int64} = [3]
    return (a,b)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        S = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = popfirst!(S)
        if N == 20
            (a,b) = solvesmall(S)
        else
            (a,b) = solvelarge(S)
        end
        astr = join(a," ")
        bstr = join(b," ")
        print("$astr\n")
        print("$bstr\n")
    end
end

main()
