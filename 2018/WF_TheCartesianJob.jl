struct Myang
    x1::Int64
    y1::Int64
    x2::Int64
    y2::Int64
end

## This works for sorting angles between 2 vectors (0-180deg)
## Tangents are guaranteed to be rational, so we can use those
## We first ensure the two angles are in the same quadrant before we apply
Base.:(==)(a::Myang,b::Myang) = cmp(a,b) == 0
Base.isless(a::Myang,b::Myang) = cmp(a,b) == -1
Base.:(<=)(a::Myang,b::Myang) = cmp(a,b) <= 0

function deg(a::Myang)::Float64
    l1 = sqrt(a.x1*a.x1+a.y1*a.y1)
    l2 = sqrt(a.x2*a.x2+a.y2*a.y2)
    mycos = (a.x1*a.x2+a.y1*a.y2)/l1/l2
    return acos(mycos)*180.0/pi
end

function Base.cmp(a::Myang,b::Myang)::Int64
    dp1::Int64 = a.x1*a.x2+a.y1*a.y2
    xp1::Int64 = abs(a.x1*a.y2-a.x2*a.y1)
    dp2::Int64 = b.x1*b.x2+b.y1*b.y2
    xp2::Int64 = abs(b.x1*b.y2-b.x2*b.y1)
    q1::Int64 = xp1 == 0 ? (dp1 > 0 ? 0 : 4) : dp1 == 0 ? 2 : dp1 > 0 ? 1 : 3
    q2::Int64 = xp2 == 0 ? (dp2 > 0 ? 0 : 4) : dp2 == 0 ? 2 : dp2 > 0 ? 1 : 3
    if q1 != q2
        return cmp(q1,q2)
    elseif q1 == 0 || q1 == 2 || q1 == 4
        return 0
    else  ## Note multiplying both sides by dp1*dp2 is POSITIVE in either quadrant
        return cmp(Int128(dp2)*Int128(xp1),Int128(dp1)*Int128(xp2))
    end
end

## Ray line intersection w/o floating point
## Points on segent given by (x1+a*(x2-x1),y1+a*(y2-y1))
## Points on ray given by (b*dx,b*dy)
## For valid intersection, need a betweeen 0 and 1 inclusive and need b to be positive
## (x2-x1)*a - dx*b = -x1
## (y2-y1)*a - dy*b = -y1
## Using cramers rule, we have that
## den = (x2-x1)*(-dy)-(y2-y1)*(-dx) = dx*(y2-y1)-dy*(x2-x1)
## numa = (-x1)*(-dy)-(-y1)*(-dx) = dy*x1-dx*y1
## numb = (x2-x1)*(-y1)-(y2-y1)*(-x1) = x1*(y2-y1)-y1*(x2-x1)
## In this routine, we're not considering intersecting at the endpoints.
function isintersecting(dx,dy,x1,y1,x2,y2)::Bool
    den = dx*(y2-y1)-dy*(x2-x1)
    if den == 0; return false; end
    numa = dy*x1-dx*y1
    numb = (y2-y1)*x1-(x2-x1)*y1
    if sign(numb)*sign(den) < 0; return false; end
    if sign(numa)*sign(den) <= 0; return false; end
    if abs(numa) >= abs(den); return false; end
    return true
end

function convertAngsToInts(angs::Vector{Tuple{Myang,Myang}},topBound::Myang,botBound::Myang)
    allangs::Vector{Myang} = []
    push!(allangs,topBound)
    push!(allangs,botBound)
    for (a,b) in angs; push!(allangs,a); push!(allangs,b); end
    sort!(allangs)
    ang2::Vector{Myang} = []
    push!(ang2,allangs[1])
    for a in allangs[2:end]
        if a == ang2[end]; continue; end
        push!(ang2,a)
    end
    maxval = length(ang2)

    function dosearch(a::Myang)
        if a == ang2[1]; return 1; end
        l,u = 1,maxval
        while (u-l > 1)
            m = (u+l)÷2
            if ang2[m] < a; l = m; else; u=m; end
        end
        return u
    end

    angt::Vector{Tuple{Int64,Int64}} = []
    for (a,b) = angs
        n1 = dosearch(a)
        n2 = dosearch(b)
        push!(angt,(n1,n2))
    end
    return angt,maxval
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        topang::Vector{Tuple{Myang,Myang}} = []
        midang::Vector{Tuple{Myang,Myang}} = []
        botang::Vector{Tuple{Myang,Myang}} = []
        for i in 1:N
            x1,y1,x2,y2 = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            if x1 == 0; continue; end  ##Don't need to process lasers that only hit the segemet at one point in time.
            a = Myang(x2-x1,y2-y1,0-x1,0-y1)
            b = Myang(x2-x1,y2-y1,0-x1,1000-y1)
            if b < a; (a,b) = (b,a); end
            if isintersecting(x2-x1,y2-y1,-x1,-y1,-x1,1000-y1)
                push!(topang,(a,b))
            elseif isintersecting(x1-x2,y1-y2,-x1,-y1,-x1,1000-y1)
                push!(botang,(a,b))
            else
                push!(midang,(a,b))
            end
        end
        ##print("DBG\n")
        ##for (a,b) in topang; print("DBG TOP: $(deg(a)),$(deg(b))\n"); end
        ##for (a,b) in midang; print("DBG MID: $(deg(a)),$(deg(b))\n"); end
        ##for (a,b) in botang; print("DBG BOT: $(deg(a)),$(deg(b))\n"); end

        ## Process top and bottom piece
        topBound = Myang(1,0,1,0)
        botBound = Myang(1,0,-1,0)
        for (a,b) in topang
            if a > topBound; topBound = a; end
        end
        for (a,b) in botang
            if b < botBound; botBound = b; end
        end

        ##print("DBG TOPBOUND: $(deg(topBound))\n")
        ##print("DBG BOTBOUND: $(deg(botBound))\n")
        if botBound <= topBound; print("0.0\n"); continue; end

        for (a,b) in topang
            if b > topBound; push!(midang,(topBound,b)); end
        end
        for (a,b) in botang
            if a < botBound; push!(midang,(a,botBound)); end
        end

        #for (a,b) in midang; print("DBG MID2: $(deg(a)),$(deg(b))\n"); end

        newmidang::Vector{Tuple{Myang,Myang}} = []
        for (a,b) in midang
            if b ≤ topBound || botBound ≤ a; continue; end
            if a ≤ topBound; a = topBound; end
            if botBound ≤ b; b = botBound; end
            if a < b; push!(newmidang,(a,b)); end
        end
        sort!(newmidang)
        midangtuples::Vector{Tuple{Int64,Int64}},maxval::Int64 = convertAngsToInts(newmidang,topBound,botBound)

        state = Dict{Tuple{Int64,Int64},Float64}()
        state[(1,1)] = 1.000
        pthresh = 1e-20
        for (a,b) in midangtuples
            newstate = Dict{Tuple{Int64,Int64},Float64}()
            for ((c,d),v) in state
                if (a > c); continue; end
                ns1 = (c,max(b,d))
                ns2 = b >= d ? (d,b) : (max(c,b),d)
                for ns in (ns1,ns2)
                    if !haskey(newstate,ns); newstate[ns] = 0.000; end
                    newstate[ns] += 0.5*v
                end
            end
            ## To get the runtime under control, we have to prune low prob states
            badkeys::Vector{Tuple{Int64,Int64}} = []
            for ((c,d),v) in newstate
                if v < pthresh; push!(badkeys,(c,d)); end
            end
            for k in badkeys; delete!(newstate,k); end
            state = newstate
        end

        ans = haskey(state,(maxval,maxval)) ? 1.0 - state[(maxval,maxval)] : 1.00
        print("$ans\n")
    end
end

main()
