
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

function tryit(stidx::I,rolls::Array{I,2},N::I,D::I,k::I)
    best = 0
    enidx = stidx
    bad::VI = stidx == 1 ? [] : [x for x in rolls[stidx-1,1:D]]
    good::VI = []

    function isgood(idx::I)::Bool
        for g::I in good
            for i::I in 1:D
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

function solve(N::I,D::I,k::I,rawrolls::VI,working)::String
    (rolls,) = working
    for i in 1:N
        rolls[i,1:D] = rawrolls[1+(i-1)*D:i*D]
    end
    best,left,right = -1,-1,-1
    for i in 1:N
        b = tryit(i,rolls,N,D,k)
        if b > best; best = b; left=i-1; right=left+b-1; end
    end
    return "$left $right"
end

function gencase(Nmin::I,Nmax::I,Dmin::I,Dmax::I,k::I,maxroll::I)
    N = rand(Nmin:Nmax)
    D = rand(Dmin:Dmax)
    rawrolls::VI = rand(1:maxroll,N*D)
    return (N,D,k,rawrolls)
end

function test(ntc::I,Nmin::I,Nmax::I,Dmin::I,Dmax::I,k::I,maxroll::I,check::Bool=true)
    rolls::Array{I,2} = fill(0,100000,4)
    pass = 0
    for ttt in 1:ntc
        (N,D,k,rawrolls) = gencase(Nmin,Nmax,Dmin,Dmax,k,maxroll)
        ans = solve(N,D,k,rawrolls,(rolls,))
        print("Case #$ttt: $ans\n")
    end
end

function main(infn="")
    rolls::Array{I,2} = fill(0,100000,4)
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,D,k = gis()
        rawrolls::VI = gis()
        ans = solve(N,D,k,rawrolls,(rolls,))
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#for nmax in (5,100,1000,100000)
#    for rollmax in (5,10,25)
#        test(100,1,nmax,1,4,2,rollmax)
#    end
#end

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

