
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

##########################################################################################
## Ok, the dumb solution seems to be to build towers as quickly as possible up to N-1
## and then divert 9s to the tops of the towers.  We'll try that (guessing there is
## a bit more to the endgame then that, but we will start with this.).
##########################################################################################

function solveSmall(N::I,B::I)
    used::VI = fill(0,N)
    for i in 1:N*B
        d = gi()
        found = false
        ## Priority 1 -- stick a 9 at the top of a towers
        if d == 9
            for i in 1:N
                if used[i] == B-1; print("$i\n"); flush(stdout); used[i] += 1; found = true; break; end
            end
                
        ## Priority 2 -- build up towers from left to right up to N-1
        else
            for i in 1:N
                if used[i] < B-1; print("$i\n"); flush(stdout); used[i] += 1; found = true; break; end
            end
        end
        ## Priority 3 -- stick something on the top of the tower
        if !found
            for i in 1:N
                if used[i] < B; print("$i\n"); flush(stdout); used[i] += 1; found = true; break; end
            end
        end
    end
end

##########################################################################################
## Actually, the dumb solution is not so dumb -- it appears there are two deficiencies
## -- End game is weak.  Need some math on when to "settle" on the final towers if the
##    numbers aren't coming.
## -- Need to optimize the 2nd digit
##########################################################################################

function doeq(N,used,v)
    for i in 1:N; if used[i] == v; print("$i\n"); flush(stdout); used[i] += 1; return; end; end
end

function dole(N,used,v)
    for i in 1:N; if used[i] <= v; print("$i\n"); flush(stdout); used[i] += 1; return; end; end
end

function dolastcol(N,used)
    print("$N\n"); flush(stdout); used[N] += 1
end

## OK, we can make this way better, but i just want a sense of settling
function commit(d,N,left,numbm1)
    if numbm1 == 0; return false; end
    if left == numbm1; return true; end
    if numbm1/left >= 0.2 && d >= 8; return true; end
    if numbm1/left >= 0.3 && d >= 7; return true; end
    if numbm1/left >= 0.4 && d >= 6; return true; end
    if numbm1/left >= 0.5 && d >= 5; return true; end
    return false
end

function solveLarge(N::I,B::I)
    used::VI = fill(0,N)
    for i in 1:N*B
        d = gi()
        if d < 0; exit(0); end
        found = false
        numbm1::I = count(x->x==B-1,used)
        numbm2::I = count(x->x==B-2,used)
        if d == 9 && numbm1 > 0
            doeq(N,used,B-1)
        elseif (d >= 8 || (d>=5 && numbm1 < 1)) && numbm2 > 0
            doeq(N,used,B-2)
        elseif used[N] == 0
            dole(N,used,B-3)
        elseif numbm2 > 0
            doeq(N,used,B-2)
        elseif commit(d,N,B-used[N]+numbm1,numbm1)
            doeq(N,used,B-1)
        else
            dolastcol(N,used)
        end
    end
end

##########################################################################################
## OK, lets work on maximizing our remaining EV.  We consider the following state Vector
## (d,numused,numbm,numbm1,numbm2,numbm3)
## This is bounded by 10*150*10626 = 16M (10626 is the number of non-negative ordered quads (i,j,k,l)
## with sum less than or equal to 20). For each number, we have (up to) 4 choices
## -- Place it on a B-1 tower
## -- Place it on a B-2 tower
## -- Place it on a B-3 tower
## -- Default algorithm of building towers up to B-3 and moving onto the next one.
## We can just do this with prework and use to choose
##########################################################################################

## d is 4 bits
## numused is 9 bits
## numbm is 5 bits
## numbm1 is 5 bits
## numbm2 is 5 bits
## numbm3 is 5 bits
## Means we can use a 64 bit key
function prework()
    cache::Dict{I,Tuple{F,I}} = Dict{I,Tuple{F,I}}()
    calcEV(cache,10,0,0,0,0,0,15)
    return (cache,)
end

function solveGoodLarge(N::I,B::I,working)
    (cache::Dict{I,Tuple{F,I}},) = working
    used::VI = fill(0,N)
    for i in 1:N*B
        d = gi()
        if d < 0; exit(0); end
        found = false
        numbm::I =  count(x->x==B,used)
        numbm1::I = count(x->x==B-1,used)
        numbm2::I = count(x->x==B-2,used)
        numbm3::I = count(x->x==B-3,used)
        (ev,strat) = calcEV(cache,d,i-1,numbm,numbm1,numbm2,numbm3,B)
        if strat == 1; doeq(N,used,B-1)
        elseif strat == 2; doeq(N,used,B-2)
        elseif strat == 3; doeq(N,used,B-3)
        else; dole(N,used,B-4); end
    end
end

function calcEV(cache::Dict{I,Tuple{F,I}},d::I,numused::I,numbm::I,numbm1::I,numbm2::I,numbm3::I,B::I)::Tuple{F,I}
    key::I = d | (numused<<4) | (numbm<<13) | (numbm1<<18) | (numbm2) << 23 | (numbm3) << 28 
    if !haskey(cache,key)
        ## Use d == 10 to aggregate values
        if numused == 300
            cache[key] = (0.00,0)
        elseif d == 10
            val::F = 0.0
            for dd in 0:9; val += calcEV(cache,dd,numused,numbm,numbm1,numbm2,numbm3,B)[1]; end
            cache[key] = (0.1 * val,0)
        else
            val1::F = numbm1 == 0 ? 0.0 : 1.0 * d * 10^(B-1) + calcEV(cache,10,numused+1,numbm+1,numbm1-1,numbm2,numbm3,B)[1]
            val2::F = numbm2 == 0 ? 0.0 : 1.0 * d * 10^(B-2) + calcEV(cache,10,numused+1,numbm,numbm1+1,numbm2-1,numbm3,B)[1]
            val3::F = numbm3 == 0 ? 0.0 : 1.0 * d * 10^(B-3) + calcEV(cache,10,numused+1,numbm,numbm1,numbm2+1,numbm3-1,B)[1]
            val4::F = 0.00
            if (numbm+numbm1+numbm2+numbm3) < 20 
                towerht = numused - B*numbm - (B-1)*numbm1 - (B-2)*numbm2 - (B-3)*numbm3
                if towerht == B-4
                    val4 = 1.0 * d * 10^(towerht) + calcEV(cache,10,numused+1,numbm,numbm1,numbm2,numbm3+1,B)[1]
                else
                    val4 = 1.0 * d * 10^(towerht) + calcEV(cache,10,numused+1,numbm,numbm1,numbm2,numbm3,B)[1]
                end
            end
            best = max(val1,val2,val3,val4)
            cache[key] = (best, val1 == best ? 1 : val2 == best ? 2 : val3 == best ? 3 : 4)
        end
    end
    return cache[key]
end

function main(infn="")
    working = prework()
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,N::I,B::I,P::I = gis()
    for qq in 1:tt
        #solveSmall(N,B)
        #solveLarge(N,B)
        solveGoodLarge(N,B,working)
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

