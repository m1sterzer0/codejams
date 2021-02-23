function tryit(stidx::Int64,rolls::Array{Int64,2},N::Int64,D::Int64,k::Int64)
    best = 0
    enidx = stidx
    bad::Vector{Int64} = stidx == 1 ? [] : [x for x in rolls[stidx-1,1:D]]
    good::Vector{Int64} = []

    function isgood(idx::Int64)::Bool
        for g::Int64 in good
            for i::Int64 in 1:D
                if g == rolls[idx,i]; return true; end
            end
        end
        return false
    end

    for i1 in 1:D
        if rolls[stidx,i1] ∈ bad; continue; end
        push!(good,rolls[stidx,i1])
        enidx1 = stidx
        while enidx1+1 <= N && isgood(enidx1+1); enidx1 += 1; end
        if enidx1 == N; return enidx1-stidx+1; end
        for i2 in 1:D
            if rolls[enidx1+1,i2] ∈ bad; continue; end
            push!(good,rolls[enidx1+1,i2])
            enidx2 = enidx1
            while enidx2+1 <= N && isgood(enidx2+1); enidx2 += 1; end
            if enidx2 == N; return enidx2-stidx+1; end
            if enidx2-stidx+1 > best; best = enidx2-stidx+1; end
            if k == 3
                for i3 in 1:D
                    if rolls[enidx2+1,i3] ∈ bad; continue; end
                    push!(good,rolls[enidx2+1,i3])
                    enidx3 = enidx2
                    while enidx3+1 <= N && isgood(enidx3+1); enidx3 += 1; end
                    if enidx3 == N; return enidx3-stidx+1; end
                    if enidx3-stidx+1 > best; best = enidx3-stidx+1; end
                    pop!(good)
                end
            end
            pop!(good)
        end
        pop!(good)
    end
    return best
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
        best,left,right = -1,-1,-1
        for i in 1:N
            b = tryit(i,rolls,N,D,k)
            if b > best; best = b; left=i-1; right=left+b-1; end
        end
        print("$left $right\n")
    end
end

main()