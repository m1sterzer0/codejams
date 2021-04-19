
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

mutable struct UnsafeIntPerm; n::I; r::I; indices::VI; cycles::VI; end
Base.eltype(iter::UnsafeIntPerm) = Vector{Int64}
function Base.length(iter::UnsafeIntPerm)
    ans::I = 1; for i in iter.n:-1:iter.n-iter.r+1; ans *= i; end
    return ans
end
function unsafeIntPerm(a::VI,r::I=-1) 
    n = length(a)
    if r < 0; r = n; end
    return UnsafeIntPerm(n,r,copy(a),collect(n:-1:n-r+1))
end
function Base.iterate(p::UnsafeIntPerm, s::I=0)
    n = p.n; r=p.r; indices = p.indices; cycles = p.cycles
    if s == 0; return(n==r ? indices : indices[1:r],s+1); end
    for i in (r==n ? n-1 : r):-1:1
        cycles[i] -= 1
        if cycles[i] == 0
            k = indices[i]; for j in i:n-1; indices[j] = indices[j+1]; end; indices[n] = k
            cycles[i] = n-i+1
        else
            j = cycles[i]
            indices[i],indices[n-j+1] = indices[n-j+1],indices[i]
            return(n==r ? indices : indices[1:r],s+1)
        end
    end
    return nothing
end

######################################################################################################
### a) The trick here is to turn 15! orderings to 2^15 subsets and use dynamic programing.
### b) The observation is that if I have a set of prefix operations plus one "last" operation,
###    --- The maximum value is related to either the maximum or the minimum possible value of the
###        prefix operations.
### c) This leads to a rather naiive dyanmic programming solution
######################################################################################################

## Custom fracton code to avoid a ton of "reduce" checks
struct MyFrac; n::BigInt; d::BigInt; end
tadd(a::MyFrac,b::BigInt)::MyFrac = MyFrac(a.n+b*a.d,a.d)
tsub(a::MyFrac,b::BigInt)::MyFrac = MyFrac(a.n-b*a.d,a.d)
tmul(a::MyFrac,b::BigInt)::MyFrac = MyFrac(a.n*b,a.d)
tdiv(a::MyFrac,b::BigInt)::MyFrac = b < 0 ? MyFrac(-a.n,a.d*(-b)) : MyFrac(a.n,a.d*b)
tgt(a::MyFrac,b::MyFrac)::Bool = b.d*a.n > b.n*a.d
tlt(a::MyFrac,b::MyFrac)::Bool = b.d*a.n < b.n*a.d

function compressCards(O::VC,V::VI)
    possum::BigInt = BigInt(0)
    negsum::BigInt = BigInt(0)
    posmul::BigInt = BigInt(1)
    posdiv::BigInt = BigInt(1)
    negmul::Vector{BigInt} = []
    negdiv::Vector{BigInt} = []
    zeromul::Bool = false
    for (o,v) in zip(O,V)
        if v == 0
            if o == '*'; zeromul = true; end
        elseif v < 0
            if     o == '+'; negsum += v
            elseif o == '-'; possum -= v
            elseif o == '*'; push!(negmul,BigInt(v))
            elseif o == '/'; push!(negdiv,BigInt(v))
            end
        else
            if     o == '+'; possum += v
            elseif o == '-'; negsum -= v
            elseif o == '*'; posmul *= v
            elseif o == '/'; posdiv *= v
            end
        end 
    end
    O2::VC = []
    V2::Vector{BigInt} = []
    if possum > 0; push!(O2,'+'); push!(V2,possum); end
    if negsum < 0; push!(O2,'+'); push!(V2,negsum); end
    if posmul > 1; push!(O2,'*'); push!(V2,posmul); end
    if posdiv > 1; push!(O2,'/'); push!(V2,posdiv); end
    if zeromul;    push!(O2,'*'); push!(V2,zero(BigInt)); end
    sort!(negmul)
    sort!(negdiv)
    if !isempty(negmul); push!(O2,'*'); push!(V2,pop!(negmul)); end
    if !isempty(negmul); push!(O2,'*'); push!(V2,pop!(negmul)); end
    if !isempty(negmul); push!(O2,'*'); push!(V2,prod(negmul)); end
    if !isempty(negdiv); push!(O2,'/'); push!(V2,pop!(negdiv)); end
    if !isempty(negdiv); push!(O2,'/'); push!(V2,pop!(negdiv)); end
    if !isempty(negdiv); push!(O2,'/'); push!(V2,prod(negdiv)); end
    return O2,V2
end

function solveBruteForce(S::I,C::I,O::VC,V::VI)
    first = true
    best::MyFrac  = MyFrac(BigInt(0),BigInt(1))
    start::MyFrac = MyFrac(BigInt(S),BigInt(1))
    for p in unsafeIntPerm(collect(1:C))
        running::MyFrac = start
        for i in p
            op::Char = O[i]
            val::BigInt = BigInt(V[i])
            running = op == '+' ? tadd(running,val) :
                      op == '-' ? tsub(running,val) :
                      op == '*' ? tmul(running,val) : tdiv(running,val)
        end
        if first || tgt(running,best); best = running; first = false; end
    end
    ansfrac = best.n // best.d
    return (numerator(ansfrac),denominator(ansfrac))
end

function solve(S::I,C::I,O::VC,V::VI)
    O2,V2 = compressCards(O,V)
    C2 = length(O2)
    minvals::Vector{MyFrac} = fill(MyFrac(BigInt(0),BigInt(1)),2^C2)
    maxvals::Vector{MyFrac} = fill(MyFrac(BigInt(0),BigInt(1)),2^C2)
    minvals[1] = maxvals[1] = MyFrac(BigInt(S),BigInt(1))
    for i::I in 2:2^C2
        first::Bool = true
        bitmask::I = i-1
        for j::I in 1:C2
            bm::I = 1 << (j-1)
            if bitmask & bm == 0; continue; end
            residual::I = bitmask & ~bm + 1
            op::Char = O2[j]
            val1a::MyFrac = maxvals[residual]
            val1b::MyFrac = minvals[residual] 
            val2::BigInt  = V2[j]
            v1::MyFrac = op == '+' ? tadd(val1a,val2) : op == '-' ? tsub(val1a,val2) :
                         op == '*' ? tmul(val1a,val2) :             tdiv(val1a,val2)
            v2::MyFrac = op == '+' ? tadd(val1b,val2) : op == '-' ? tsub(val1b,val2) :
                         op == '*' ? tmul(val1b,val2) :             tdiv(val1b,val2)
            if first; minvals[i] = v1; maxvals[i] = v1; first = false; end
            if tgt(v1,maxvals[i]); maxvals[i] = v1; end
            if tgt(v2,maxvals[i]); maxvals[i] = v2; end
            if tlt(v1,minvals[i]); minvals[i] = v1; end
            if tlt(v2,minvals[i]); minvals[i] = v2; end
        end
    end
    ansfrac = maxvals[2^C2].n // maxvals[2^C2].d
    return (numerator(ansfrac),denominator(ansfrac))
end

function gencase(Smin::I,Smax::I,Cmin::I,Cmax::I,Vmin::I,Vmax::I)
    S = rand(Smin:Smax)
    C = rand(Cmin:Cmax)
    O::VC = rand(['+','-','*','/'],C)
    V::VI = rand(Vmin:Vmax,C)
    for i in 1:C
        while O[i] == '/' && V[i] == 0; V[i] = rand(Vmin:Vmax); end
    end
    return (S,C,O,V)
end

function test(ntc::I,Smin::I,Smax::I,Cmin::I,Cmax::I,Vmin::I,Vmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (S,C,O,V) = gencase(Smin,Smax,Cmin,Cmax,Vmin,Vmax)
        ans2 = solve(S,C,O,V)
        if check
            ans1 = solveBruteForce(S,C,O,V)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt S:$S C:$C O:$O V:$V ans1:$ans1 ans2:$ans2\n")
                ans1 = solveBruteForce(S,C,O,V)
                ans2 = solve(S,C,O,V)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S,C = gis()
        O::VC = fill('.',C)
        V::VI = fill(0,C)
        for i in 1:C
            xx::VS = gss()
            O[i] = xx[1][1]
            V[i] = parse(Int64,xx[2])
        end
        ans = solve(S,C,O,V)
        print("$(ans[1]) $(ans[2])\n")
    end
end

Random.seed!(8675309)
main()
#for ntc in (1,10,100,1000)
#    test(ntc,-10,10,2,8,-10,10)
#    test(ntc,-1000,1000,2,8,-1000,1000)
#end
#test(200,-1000,1000,990,1000,-1000,1000,false)
