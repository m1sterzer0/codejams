
gs()::String = rstrip(readline(stdin))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function trycoord(X::Int64,Y::Int64)::Int64
    print("$X $Y\n"); flush(stdout)
    ans = gs()
    res = ans == "MISS" ? 0 : ans == "HIT" ? 1 : ans == "CENTER" ? 2 : 3
    return res
end

function dosearch(xflag::Bool,rightflag::Bool,minval::Int64,maxval::Int64,otherval::Int64)::Int64
    l,r = minval,maxval
    while(r-l > 1)
        m = (r+l)÷2
        (x,y) = xflag ? (m,otherval) : (otherval,m)
        a = trycoord(x,y); if a == 2; return 1_000_000_001; end
        if rightflag
            if a == 1; r = m; else; l = m; end
        else
            if a == 1; l = m; else; r = m; end
        end
    end
    return rightflag ? r : l
end

function solvecase()
    coord1 = [-1_000_000_000,-500_000_000,0,500_000_000,1_000_000_000]
    coord2 = [-750_000_000,-250_000_000,250_000_000,750_000_000]
    initialPoints = Vector{Tuple{Int64,Int64}}()
    for x in coord1; for y in coord1; push!(initialPoints,(x,y)); end; end
    for x in coord2; for y in coord2; push!(initialPoints,(x,y)); end; end

    ## Part 1 -- look for a HIT
    hx,hy = 0,0
    for (x,y) in initialPoints
        a = trycoord(x,y); if a == 2; return; end
        if a == 1; hx=x; hy=y; break; end
    end

    ## Part 2a -- look for left, right, top, bot edge
    left  = dosearch(true,true,-1_000_000_000,hx,hy);  if left  == 1_000_000_001; return; end
    right = dosearch(true,false,hx,1_000_000_000,hy);  if right == 1_000_000_001; return; end
    bot   = dosearch(false,true,-1_000_000_000,hy,hx); if bot   == 1_000_000_001; return; end
    top   = dosearch(false,false,hy,1_000_000_000,hx); if top   == 1_000_000_001; return; end

    x = (left+right) ÷ 2
    y = (bot+top) ÷ 2
    a = trycoord(x,y)
    if a != 2; print(stderr,"ERROR!!!\n"); exit(); end
    return
end

function main()
    tt,A,B = gis()
    for qq in 1:tt; solvecase(); end
end

main()

