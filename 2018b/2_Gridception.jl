
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

######################################################################################################
### Great title AND movie! (https://en.wikipedia.org/wiki/Inception)
###
### After a googol zoom-ins, there are only a few patterns that can show up.
### -- (1)*2         A full black(white) pattern (if there is a black(white) square in the initial grid)
### -- (C-1)*2       WB(BW) vertical walls (assuming there is a WB(BW) wall in the initial grid)
### -- (R-1)*2       WB(BW) horizontal walls (assuming there is a WB(BW) wall in the initial grid)
### -- (R-1)(C-1)*10 Corner patterns, assming the corner patern shows up in the initial grid
###
### For reference, here are the 16 patterns mentioned above
###           B W BB BB WB BW WW WW BW WB WB BW
### B W BW WB W B BW WB BB BB WB BW WW WW BW WB
###
### Note we can be sloppy and pad these out to 16 2x2 patterns, but we MUST do the checking not assuming 2x2
### BB WW BW WB BB WW BB BB WB BW WW WW BW WB WB BW
### BB WW BW WB WW BB BW WB BB BB WB BW WW WW BW WB
###
### What we can do is
### a) figure out which subset of these 16 patterns exist in the original grid.
### b) For the ones that do (16) 
###    -- Position them in the grid (say O(RC) of these)
###    --     Retain the squares in the original grid that match (O(RC))
###    --     Do a "union find" of the remaining cells with their neighbors to collect patterns (~O(RC)) -- some inverse ackerman.
###    --     Find the biggest one and set our running best as appropriate
### This appears to be around O(R^2C^2) which seem to fit comfortably in the time limits
######################################################################################################

###########################################################################
## BEGIN UnionFindFast -- Only works with integers, but avoids dictionaries
###########################################################################

mutable struct UnionFindFast
    parent::Vector{Int64}
    size::Vector{Int64}
    n::Int64
    UnionFindFast(n::Int64) = new(collect(1:n),[1 for i in 1:n],n)
end

function findset(h::UnionFindFast,x::Int64)::Int64
    if h.parent[x] == x; return x; end
    return h.parent[x] = findset(h,h.parent[x])
end

function getsize(h::UnionFindFast,x::Int64)::Int64
    a = findset(h,x)
    return h.size[a]
end

function joinset(h::UnionFindFast,x::Int64,y::Int64)
    a = findset(h,x)
    b = findset(h,y)
    if a != b
        (a,b) = h.size[a] < h.size[b] ? (b,a) : (a,b)
        h.parent[b] = a
        h.size[a] += h.size[b]
    end
end

################################################################
## END UnionFindFast
################################################################

function findpat(g::Array{Char,2},R::I,C::I,nw::Char,ne::Char,sw::Char,se::Char)::Bool
    for i::I in 1:R
        for j::I in 1:C
            if g[i,j] != nw; continue; end
            if ne != '.' && (j == C || g[i,j+1] != ne);             continue; end
            if sw != '.' && (i == R || g[i+1,j] != sw);             continue; end
            if se != '.' && (i == R || j == C || g[i+1,j+1] != se); continue; end
            return true
        end
    end
    return false
end

function check(g::Array{Char,2}, g2::Array{Char,2}, g3::Array{Int64,2},
               R::I, C::I, nw::Char, ne::Char, sw::Char, se::Char)::I
    best::I = 0
    for i::I in 1:R
        for j::I in 1:C
            fill!(g2,nw)
            if i+1<=R; g2[i+1:R,1:j] .= sw; end
            if j+1<=C; g2[1:i,j+1:C] .= ne; end
            if i+1<=R && j+1<=C; g2[i+1:R,j+1:C] .= se; end

            fill!(g3,-1)
            ptr::I = 0
            uf::UnionFindFast = UnionFindFast(R*C)
            for ii::I in 1:R
                for jj::I in 1:C
                    if g2[ii,jj] == g[ii,jj]
                        ptr += 1; g3[ii,jj] = ptr
                        if ii > 1 && g3[ii-1,jj] > 0; joinset(uf,ptr,g3[ii-1,jj]); end
                        if jj > 1 && g3[ii,jj-1] > 0; joinset(uf,ptr,g3[ii,jj-1]); end
                    end
                end
            end
            for xx::I in 1:ptr
                best = max(best,getsize(uf,xx))
            end
        end
    end
    return best
end

function solve(R::I,C::I,g::Array{Char,2})::I
    best::I = 0
    g2::Array{Char,2} = fill('.',R,C)
    g3::Array{Int64,2} = fill(-1,R,C)
    patterns = [
        ['W','.','.','.','W','W','W','W'],
        ['W','B','.','.','W','B','W','B'],
        ['W','.','B','.','W','W','B','B'],
        ['W','W','W','B','W','W','W','B'],
        ['W','W','B','W','W','W','B','W'],
        ['W','B','W','W','W','B','W','W'],
        ['W','B','B','B','W','B','B','B'],
        ['W','B','B','W','W','B','B','W']
    ]
    revpat = [ [x == 'W' ? 'B' : x == 'B' ? 'W' : '.' for x in p] for p in patterns]
    append!(patterns,revpat)
    for p in patterns
        if findpat(g,R,C,p[1],p[2],p[3],p[4]); best = max(best,check(g,g2,g3,R,C,p[5],p[6],p[7],p[8])); end
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        g::Array{Char,2} = fill('.',R,C)
        for i in 1:R; g[i,:] = [x for x in gs()]; end
        ans = solve(R,C,g)
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

