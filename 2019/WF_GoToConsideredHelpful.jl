
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function dobfs(gr::Array{Char,2},resarr::Array{I,2},inf::I,si::I,sj::I)::Bool
    if gr[si,sj] == '#'; return false; end
    q::VPI = [(si,sj)]; fill!(resarr,inf); resarr[si,sj] = 0
    while !isempty(q)
        (i::I,j::I) = popfirst!(q); d::I = resarr[i,j]
        for (ci::I,cj::I) in ((i+1,j),(i-1,j),(i,j+1),(i,j-1))
            if gr[ci,cj] == '#'; continue; end
            if resarr[ci,cj] == inf; resarr[ci,cj] = d+1; push!(q,(ci,cj)); end
        end
    end
    return true
end

function addBoardCopy(gr::Array{Char,2},targ::Array{Char,2},di::I,dj::I,R,C)
    for i in 1:R; for j in 1:C
        i2 = i+di; j2 = j+dj
        if gr[i,j] != '#'; continue; end
        if i2 < 1 || i2 > R || j2 < 1 || j2 > C; continue; end
        targ[i2,j2] = '#'
    end; end
end


## There are 3 parts to the path
## * The "pre-loop" part.  That one we have solved in Mdist[x,y]
## * The N "loop prefixes" -- these we can solve by moving the copies of the board along with the displacements
## * The N-1 "loop suffixes" -- these we can solve by oring copies of the board against the displacement and 
##   Further displacing the N square.


function solveSmall(R::I,C::I,gr::Array{Char,2})::String
    inf::I = 10^18; ans::I = inf; 

    ## first, we ring the board with danger to avoid having to do the range checks.  This also prevents
    ## us from falling off the board once we start translating and ORing
    gr2::Array{Char,2} = fill('#',R+2,C+2)
    gr2[2:R+1,2:C+1] .= gr; R += 2; C += 2

    Mcoord::PI = (0,0); Ncoord::PI = (0,0)
    for i in 1:R; for j in 1:C
        if gr2[i,j] == 'M'; Mcoord = (i,j); end
        if gr2[i,j] == 'N'; Ncoord = (i,j); end
    end; end

    Mdist::Array{I,2} = fill(inf,R,C)
    dobfs(gr2,Mdist,inf,Mcoord[1],Mcoord[2])
    if Mdist[Ncoord[1],Ncoord[2]] == inf; return "IMPOSSIBLE"; end
    ans = Mdist[Ncoord[1],Ncoord[2]]

    Ndist::Array{I,2} = fill(inf,R,C)
    dobfs(gr2,Ndist,inf,Ncoord[1],Ncoord[2])

    bd1::Array{Char,2} = fill('#',R,C); bd2::Array{Char,2} = fill('#',R,C)
    res1::Array{I,2}   = fill(0,R,C);   res2::Array{I,2}   = fill(0,R,C)
    for rdis in -R:R
        for cdis in -C:C
            if rdis == cdis == 0; continue; end
            bd1 .= gr2; bd2 .= gr2
            good = true
            for ndis in 1:max(R,C)
                ## Check to see if we have any takers
                if rdis * ndis >= R || cdis * ndis >= C; break; end  ## Key pruning step!!
                nc1,nc2,nc3,nc4 = Ncoord[1], Ncoord[2], Ncoord[1] - ndis*rdis, Ncoord[2] - ndis*cdis
                if nc3 < 1 || nc3 > R || nc4 < 1 || nc4 > C; break; end
                addBoardCopy(gr2,bd1,ndis*rdis,ndis*cdis,R,C)
                addBoardCopy(gr2,bd2,(ndis-1)*(-rdis),(ndis-1)*(-cdis),R,C)
                good &= dobfs(bd1,res1,inf,nc1,nc2)
                good &= dobfs(bd2,res2,inf,nc3,nc4)
                if !good; break; end
                ## Look for the answers
                for i in 1:R; for j in 1:C
                    if gr2[i,j] == '#'; continue; end
                    if Mdist[i,j] == inf; continue; end
                    i2 = i + rdis*ndis; j2 = j + cdis*ndis
                    if i2 < 1 || i2 > R || j2 < 1 || j2 > C; continue; end
                    i3 = i + rdis; j3 = j + cdis  ## No range check -- should be between i & i2/j & j2
                    if res1[i2,j2] == inf; continue; end
                    if res2[i3,j3] == inf; continue; end
                    cand::I = Mdist[i,j] + res1[i2,j2] + res2[i3,j3] + 1
                    ans = min(ans,cand)
                end; end
            end
        end
    end
    return "$ans"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        gr::Array{Char,2} = fill('.',R,C)
        for i in 1:R; gr[i,:] = [x for x in gs()]; end
        ans = solveSmall(R,C,gr)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

