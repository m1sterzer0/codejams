
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

function solve(B::I)
    diffidx::I,sameidx::I = 0,0
    invdiff::Bool,invsame::Bool = false,false
    ans::VC = fill('0',B)
    idx::I = 0
    ## Iterate through pairs
    for i::I in 1:71
        if i % 5 == 1
            if diffidx > 0; print("$diffidx\n"); flush(stdout); a = gs(); invdiff = ans[diffidx] != a[1]
            else; print("1\n"); flush(stdout); a = gs()
            end

            if sameidx > 0; print("$sameidx\n"); flush(stdout); a = gs(); invsame = ans[sameidx] != a[1]
            else; print("1\n"); flush(stdout); a = gs()
            end
        elseif idx < B÷2
            idx += 1
            jidx = B+1-idx
            print("$idx\n$jidx\n"); flush(stdout); a = gs(); b = gs();
            if a[1] == b[1]; sameidx = idx; else; diffidx = idx; end
            invflag::Bool = a[1] == b[1] ? invsame : invdiff
            ans[idx]  = invflag ? (a[1] == '0' ? '1' : '0') : a[1]
            ans[jidx] = invflag ? (b[1] == '0' ? '1' : '0') : b[1]
        else
            print("1\n1\n"); flush(stdout); a = gs(); b = gs()
        end
    end

    fans = fill('0',B)
    for i in 1:B÷2
        j = B+1-i
        invflag = ans[i] == ans[j] ? invsame : invdiff 
        if invflag; fans[i] = ans[i] == '0' ? '1' : '0'; fans[j] = ans[j] == '0' ? '1' : '0'
        else ; fans[i] = ans[i]; fans[j] = ans[j]
        end
    end
    ansstr = join(fans,"")
    print("$ansstr\n"); flush(stdout)
    res = gs(); if res == "N"; exit(0); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,B::I = gis()
    for qq in 1:tt
        solve(B)
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

