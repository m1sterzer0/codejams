
function docasem(rolls::Array{Int64,2},left::Int64,m::Int64,right::Int64,D::Int64,k::Int64)
    good::Vector{Int64} = []

    function isgood(idx::Int64)::Bool
        for g::Int64 in good
            for i::Int64 in 1:D
                if g == rolls[idx,i]; return true; end
            end
        end
        return false
    end

    best = 0; resl = m; resr = m;
    for i1 in 1:D
        push!(good,rolls[m,i1])
        l1,r1 = m,m
        while l1-1 >= left && isgood(l1-1); l1 -= 1; end
        while r1+1 <= right && isgood(r1+1); r1 += 1; end
        if r1-l1 > best || r1-l1 == best && l1 < resl; best = r1-l1; resl = l1; resr = r1; end
        cand1 = []
        if l1 > left;  for ii in 1:D; push!(cand1,rolls[l1-1,ii]); end; end
        if r1 < right; for ii in 1:D; push!(cand1,rolls[r1+1,ii]); end; end
        for c2 in cand1
            push!(good,c2)
            l2,r2 = l1,r1
            while l2-1 >= left && isgood(l2-1); l2 -= 1; end
            while r2+1 <= right && isgood(r2+1); r2 += 1; end
            if r2-l2 > best || r2-l2 == best && l2 < resl; best = r2-l2; resl = l2; resr = r2; end
            if k == 3
                cand2 = []
                if l2 > left;  for ii in 1:D; push!(cand2,rolls[l2-1,ii]); end; end
                if r2 < right; for ii in 1:D; push!(cand2,rolls[r2+1,ii]); end; end
                for c3 in cand2
                    push!(good,c3)
                    l3,r3 = l2,r2
                    while l3-1 >= left && isgood(l3-1); l3 -= 1; end
                    while r3+1 <= right && isgood(r3+1); r3 += 1; end
                    if r3-l3 > best || r3-l3 == best && l3 < resl; best = r3-l3; resl = l3; resr = r3; end
                    pop!(good)
                end
            end
            pop!(good)
        end
        pop!(good)
    end
    return (resl,resr)    
end

function divandconq(rolls::Array{Int64,2},left::Int64,right::Int64,D::Int64,k::Int64)::Tuple{Int64,Int64}
    if right-left <= 1; return (left,right); end
    m = (left+right) >> 1
    l1,r1 = docasem(rolls,left,m,right,D,k)
    l2,r2 = divandconq(rolls,left,m-1,D,k)
    l3,r3 = divandconq(rolls,m+1,right,D,k)
    d1 = r1-l1; d2 = r2-l2; d3 = r3-l3
    dmax = max(d1,d2,d3)
    if r2-l2 == dmax; return (l2,r2); end
    if r1-l1 == dmax; return (l1,r1); end
    return (l3,r3)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    rolls::Array{Int64,2} = fill(0,100000,4)
    for qq in 1:tt
        print("Case #$qq: ")
        N,D,k = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        rawrolls = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        for i in 1:N
            rolls[i,1:D] = rawrolls[1+(i-1)*D:i*D]
        end
        (left::Int64,right::Int64) = divandconq(rolls,1,N,D,k)
        print("$(left-1) $(right-1)\n")
    end
end

#main()

using Profile, StatProfilerHTML
Profile.clear()
@profile main("D.in")
Profile.clear()
@profilehtml main("Dtc1.in")
