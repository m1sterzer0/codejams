######################################################################################################
### There are two key insights
### * We can use binary search to figure out how much lead we can build
### * We build the lead "on credit" and then check to see if we can pay back the debt without
###   looping back on ourself.  In order to avoid overflow, we note that the starting material can'that
###   even make 10^10 of one element, so we can use that as a cutoff
######################################################################################################
function check(n::Int64,targ::Int64,R::Vector{Tuple{Int64,Int64}},visited::Set{Int64},inv::Vector{Int64})
    if inv[targ] >= n; inv[targ] -= n; return true; end
    if targ ∈ visited || n >= 10^11; return false; end
    d = n-inv[targ]
    inv[targ] = 0
    push!(visited,targ)
    if !check(d,R[targ][1],R,visited,inv); return false; end
    if !check(d,R[targ][2],R,visited,inv); return false; end
    delete!(visited,targ)
    return true
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        M = parse(Int64,rstrip(readline(infile)))
        R = Vector{Tuple{Int64,Int64}}()
        for i in 1:M
            x,y = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            push!(R,(x,y))
        end
        G = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        l,u = 0,10^10
        while (u-l > 1)
            m = (u+l) ÷ 2
            locG = copy(G)
            if check(m,1,R,Set{Int64}(),locG); l = m
            else ;                             u = m
            end
        end
        print("$l\n")
    end
end

main()
