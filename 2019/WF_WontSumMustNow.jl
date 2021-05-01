
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

function preworkSmall()
    anss::VS = []
    for i in 1:99999
        x = "$i"; xr = reverse(x)
        push!(anss,x*xr)
        push!(anss,x*xr[2:end])
    end
    lpal::VI = sort([parse(Int64,x) for x in anss])
    spal::SI = SI(lpal)
    return (lpal,spal)
end

function solveSmall(preA::BigInt,working)::String
    (lpal::VI,spal::SI) = working
    #for x in lpal; print("$x\n"); end
    A = Int64(preA)
    if A in spal; return "$A"; end
    for x in lpal
        if A-x in spal; return "$x $(A-x)"; end
    end
    ## Ok, we know that 3 works
    cand = [x for x in lpal if x < A]
    while true
        s = rand(cand)
        for x in lpal
            if A-x-s in spal; return "$s $x $(A-x-s)"; end
        end
    end
end

function ispalindrome(x::String)
    l = length(x)
    for i in 1:l; if x[i] != x[l+1-i]; return false; end; end
    return true
end

function solveCase(AA,a::I,b::I,first::Bool)
    lf::I = 1
    ten = convert(typeof(AA),10)
    rt::I = typeof(ten) == BigInt ? 42 : typeof(ten) == Int128 ? 36 : 18
    while rt-lf > 1
        m::I = (lf+rt)>>1; if ten^(m-1) <= AA; lf = m; else; rt = m; end
    end
    l::I = lf; pv = ten^(lf-1)

    if b == 0
        sa::String = string(AA)
        return a != length(sa) ? ("","") : ispalindrome(sa) ? (sa,"") : ("","")
    end

    ## Here is where we take the opportunity for down-promotion
    if     l < 18; AA = Int64(AA); ten = Int64(10)
    elseif l < 36; AA = Int128(AA); ten = Int128(10)
    end
    A1::I   = Int64(AA ÷ pv); Aend::I = Int64(AA % 10)
    if a < l && A1 != 1; return ("",""); end
    if first && a == b == l && A1 == 1; return ("",""); end

    if a > b
        digtotry::VI = []
        if a < l; push!(digtotry,9)
        elseif a > l; push!(digtotry,0)
        else
            push!(digtotry,A1)
            if !first || A1 != 1; push!(digtotry,A1-1); end
        end
        for d in digtotry
            lastdig::I = Aend
            e::I = (10 + lastdig - d) % 10
            if e == 0 && first; continue; end
            si1 = d == 0 ? 0 : a == 1 ? d : d*ten^(a-1) + d
            si2 = e == 0 ? 0 : b == 1 ? e : e*ten^(b-1) + e
            left = AA - si1 - si2
            if left < 0; continue; end
            if left == 0
                s1::String = string(d)*"0"^(a-2)*string(d)
                s2::String = b == 1 ? "$e" : string(e)*"0"^(b-2)*string(e)
                return (s1,s2)
            end
            if a <= 2; continue; end
            if b == 1
                (x::String,y::String) = solveCase(left ÷ 10, a-2, 0, false)
                if x != ""
                    return ("$d$x$d","$e")
                end
            else
                (x,y) = solveCase(left ÷ 10, a-2, b-2, false)
                if x != ""
                    return ("$d$x$d","$e$y$e")
                end
            end
        end
    else
        ## Here we can allocate the sums as we see first
        lastdig = Aend
        sumstotry::VI = [lastdig,10+lastdig]
        for s::I in sumstotry
            d::I = s >> 1
            e::I = s - d
            if e > 9 || (first && d == 0) || (first && e == 0); continue; end
            if a == 1
                if AA == d + e
                    return ("$d","$e")
                end
            elseif a == 2
                if AA == 11 * (d + e)
                    return ("$d$d","$e$e")
                end
            else
                si1 = d == 0 ? 0 : d*ten^(a-1) + d
                si2 = e == 0 ? 0 : e*ten^(b-1) + e
                left = AA - si1 - si2
                if left < 0; continue; end
                if left == 0
                    s1::String = string(d)*"0"^(a-2)*string(d)
                    s2::String = string(e)*"0"^(b-2)*string(e)
                    return (s1,s2)
                end
                (x,y) = solveCase(left÷10,a-2,b-2,false)
                if x != ""
                    return ("$d$x$d","$e$y$e")
                end
            end
        end
    end
    #print(stderr,"LEAVE: solveCase AA:$AA a:$a b:$b first:$first\n")
    return ("","")
end

function solveDouble(A::BigInt)
    sa = string(A); l = length(sa)
    pvarr::Vector{BigInt} = fill(BigInt(1),42)
    for i in 2:42; pvarr[i] = pvarr[i-1] * 10; end
    cases::VPI = vcat([(l,x) for x in 1:l],[(l-1,x) for x in 1:l-1])
    for (a,b) in cases
        (c,d) = solveCase(A,a,b,true)
        if c != ""; return "$c $d"; end
    end
    return ""
end

function solveLarge(A::BigInt,working)::String
    (lpal::VI,spal::SI) = working
    s = string(A); n = length(s)
    pal = true
    for i in 1:n; if s[i] != s[n+1-i]; pal = false; end; end
    if pal; return s; end
    s2 = solveDouble(A)
    if s2 != ""; return s2; end
    ## For 3 folds, just pick a random palindrome from lpal
    lpal2::VI = [x for x in lpal if x < A]
    while (true)
        x = rand(lpal2)
        s2 = solveDouble(A-x)
        if s2 != ""; return "$x $s2"; end
    end
end

function test(ntc::I,Smax::BigInt,chkSmall=true)
    working = preworkSmall()
    pass::I = 0
    for ttt in 1:ntc
        S::BigInt = rand(BigInt(1):Smax)
        ans = solveLarge(S,working)
        vs::VS  = split(ans)
        vbi::Vector{BigInt} = [parse(BigInt,x) for x in vs]
        good = true
        for x in vs; if !ispalindrome(x); good = false; end; end
        if sum(vbi) != S; good = false; end
        if chkSmall
            ans2 = solveSmall(S,working)
            vi2::Vector{BigInt} = [parse(BigInt,x) for x in split(ans2)]
            if length(vi2) != length(vbi); good = false; end
        end
        if good
            pass += 1
        else
            if chkSmall
                print("ERROR: Case #$ttt: S:$S ans:$ans refans:$ans2\n")
            else
                print("ERROR: Case #$ttt: S:$S ans:$ans\n")
            end
            solveLarge(S,working)
        end
    end
    print("$pass/$ntc passed\n")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    working = preworkSmall()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S = parse(BigInt,gs())
        #ans = solveSmall(S,working)
        ans = solveLarge(S,working)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#for e in 1:40
#    print("e=$e\n")
#    test(100,BigInt(10)^e,e <= 10)
#end

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,BigInt(10))
#Profile.clear()
#@profilehtml test(200,BigInt(10)^40)

