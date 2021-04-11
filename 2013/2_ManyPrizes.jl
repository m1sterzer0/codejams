
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

function could(m::I, N::I, P::I)
    numbetter = m
    numworse = 2^N-m-1
    for r in N-1:-1:0
        if (P-1) & (1<<r) == 0 ## This is win
            if numworse == 0; return false; end
            numworse = (numworse-1)÷2
        else  ## this is a loss
            if numworse > 0; return true; end
        end
    end
    return true
end

function guaranteed(m::Int64, N::Int64, P::Int64)
    numbetter = m
    numworse = 2^N-m-1
    for r in N-1:-1:0
        if (P-1) & (1<<r) == 0 ## This is win
            if numbetter > 0; return false; end
        else ## This is a loss
            if numbetter == 0; return true; end
            numbetter = (numbetter-1)÷2
        end
    end
    return true
end

function solve(N::I,P::I)
    ## Could search
    pc = 2^N-1
    if !could(pc,N,P)
        l,u = 0,pc
        while u-l > 1; 
            m = (u+l)>>1; if could(m,N,P); l = m; else; u = m; end
        end
        pc = l
    end

    pg = 2^N-1
    if !guaranteed(pg,N,P)
        l,u = 0,pg
        while u-l > 1
            m = (u+l)>>1; if guaranteed(m,N,P); l = m; else; u = m; end
        end
        pg = l
    end

    return (pg,pc)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = gis()
        ans = solve(N,P)
        print("$(ans[1]) $(ans[2])\n")
    end
end

Random.seed!(8675309)
main()

