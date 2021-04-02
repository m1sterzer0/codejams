
## Going to divide and conquer, which (I think) is O(N^2) in worst case.
## We can improve findmax if we need and make this O(NlogN)

function solve(ii::Int64,jj::Int64,enin::Int64,enout::Int64,E::Int64,R::Int64,V::Vector{Int64})::Int64
    if ii==jj; s = min(enin,enin+R-enout); return s*V[ii]; end
    budget = min(E,enin+R*(jj-ii+1)-enout)
    if budget == 0; return 0; end
    (m,kk) = findmax(V[ii:jj]); kk += (ii-1)
    inc = min(E,enin+R*(kk-ii))
    out = max(R,enout-(jj-kk)*R)
    spend = inc - (out-R)
    return spend*V[kk] + (kk==ii ? 0 : solve(ii,kk-1,enin,inc,E,R,V)) + (kk==jj ? 0 : solve(kk+1,jj,out,enout,E,R,V))
end


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        E,R,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        V::Vector{Int64} = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        R = min(R,E)
        ans = solve(1,N,E,R,E,R,V)
        print("$ans\n")
    end
end

main()

