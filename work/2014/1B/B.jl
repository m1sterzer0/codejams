######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################


function solveplace(Alim::Int64,Blim::Int64,Klim::Int64,p::Int64,cache::Dict{Tuple{Int64,Int64,Int64,Int64},Int64})::Int64
    pv = 1 << p
    maxgen = 2*pv-1
    if Alim >= maxgen && Blim >= maxgen && Klim >= maxgen; return 2^(2*p+2); end
    Alim = min(Alim,maxgen)
    Blim = min(Blim,maxgen)
    Klim = min(Klim,maxgen)
    if haskey(cache,(Alim,Blim,Klim,p)); return cache[(Alim,Blim,Klim,p)]; end
    ans::Int64 = 0
    if p == 0
        ans += 1
        if Alim >= pv; ans += 1; end
        if Blim >= pv; ans += 1; end
        if Alim >= pv && Blim >= pv && Klim >= pv; ans += 1; end
    else
        ans += solveplace(Alim,Blim,Klim,p-1,cache)
        if Alim >= pv;                             ans += solveplace(Alim-pv,Blim,Klim,p-1,cache); end
        if Blim >= pv;                             ans += solveplace(Alim,Blim-pv,Klim,p-1,cache); end
        if Alim >= pv && Blim >= pv && Klim >= pv; ans += solveplace(Alim-pv,Blim-pv,Klim-pv,p-1,cache); end
    end
    cache[(Alim,Blim,Klim,p)] = ans
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B,K = [parse(Int64,x) for x in split(readline(infile))]
        cache = Dict{Tuple{Int64,Int64,Int64,Int64},Int64}()
        ans = solveplace(A-1,B-1,K-1,31,cache)
        print("$ans\n")
    end
end

main()
