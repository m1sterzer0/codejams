
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

function solve(N::I,Q::I,A::VS,S::VI)::String
    ## Here we just
    num::Int128 = 0
    denom::Int128 = 0
    resarr::Vector{Char} = [] 
    if N == 1
        if 2 * S[1] >= Q
            resarr = [x for x in A[1]]
            num = S[1]
            denom = 1
        else
            resarr = [A[1][i] == 'T' ? 'F' : 'T' for i in 1:Q]
            num = Q - S[1]
            denom = 1
        end
    elseif N == 2
        ## For the questions where we are the same, the choice is copy or anticopy
        ## For the questions where we are different, the choice is between the smart person and the dumb person
        samecnt = count(x->x,[A[1][i] == A[2][i] for i in 1:Q])
        diffcnt = Q - samecnt
        
        ## Let a == number of samecnt correct
        ## Let b1 == number of diffcnt correct by player 1
        ## Let b2 == number of diffcnt correct by player 2 == (diffcnt- b1)
        ## a + b1 = S[1]
        ## a + b2 = S[2]
        ## Summing --> 2a + diffcnt = S[1] + S[2] --> 2a = S[1] + S[2] - diffcnt --> a = 1/2 (S[1] + S[2] - diffcnt)
        a = (S[1] + S[2] - diffcnt) ÷ 2
        b1 = S[1] - a
        b2 = S[2] - a

        diffplayer = S[1] > S[2] ? 1 : 2
        oppflag = S[1] + S[2] - diffcnt < samecnt
        expected = max(a,samecnt-a) + max(b1,b2)
        for i in 1:Q
            if A[1][i] != A[2][i]; push!(resarr,A[diffplayer][i]); continue; end
            if oppflag; push!(resarr, A[1][i] == 'T' ? 'F' : 'T'); continue; end
            push!(resarr,A[1][i])
        end
        num = expected
        denom = 1
    elseif N == 3
        ## Four types of question
        ##    acnt: questions where all 3 players answer the same way
        ##    bcnt: questions where p1 & p2 agree and p3 differs
        ##    ccnt: questions where p1 & p3 agree and p2 differs
        ##    dcnt: questions where p2 & P3 agree and p1 differs
        acnt = count(x->x,[A[1][i] == A[2][i] && A[1][i] == A[3][i] for i in 1:Q])
        bcnt = count(x->x,[A[1][i] == A[2][i] && A[1][i] != A[3][i] for i in 1:Q])
        ccnt = count(x->x,[A[1][i] != A[2][i] && A[1][i] == A[3][i] for i in 1:Q])
        dcnt = count(x->x,[A[1][i] != A[2][i] && A[1][i] != A[3][i] for i in 1:Q])

        ## This leads to 4 independent choices we can make for our solution:  going with the majority/aginst the majority on the 4 buckets
        ## Four bounds, note there are <= 2^120 tests, each of which has 120 questions, so total question is just under 2^127 which means we
        ## can use Int128 for the storage
        witha::Int128 = Int128(0); againsta::Int128 = Int128(0)
        withb::Int128 = Int128(0); againstb::Int128 = Int128(0)
        withc::Int128 = Int128(0); againstc::Int128 = Int128(0)
        withd::Int128 = Int128(0); againstd::Int128 = Int128(0)
        totways::Int128 = Int128(0)

        ## Now let player 1 get a,b,c,(dcnt-d) problems from acnt,bcnt,ccnt,dcnt right, then we have three equations
        ## a + b        + c        + (dcnt-d) = S[1]
        ## a + b        + (ccnt-c) + d        = S[2]
        ## a + (bcnt-b) + c        + d        = S[3]
        ## Our strategy is to iterate through possible values of a from 0 to acnt. Summing all of the equations, we see that
        ## 3a + b + c + d + bcnt + ccnt + dcnt = S[1] + S[2] + S[3]
        ## --> b + c + d = S[1] + S[2] + S[3] - 3a - bcnt - ccnt - dcnt
        ## Let K = b + c + d.  Finally, some more equation maipulation gives 
        ## d = a + b + c + dcnt - S[1] --> 2d = a + b + c + d + dcnt - S[1] = a + K + dcnt - S[1] --> d = 1/2 * (a + K + dcnt - S[1])
        ## c = a + b + d + ccnt - S[2] --> 2c = a + b + c + d + ccnt - S[2] = a + K + ccnt - S[2] --> c = 1/2 * (a + K + ccnt - S[2])
        ## b = a + c + d + bcnt - S[3] --> 2b = a + b + c + d + bcnt - S[3] = a + K + bcnt - S[3] --> b = 1/2 * (a + K + bcnt - S[3])
        for a in 0:min(acnt,S[1],S[2],S[3])
            K = S[1] + S[2] + S[3] - 3a - bcnt - ccnt - dcnt
            td = a + K + dcnt - S[1]
            tc = a + K + ccnt - S[2]
            tb = a + K + bcnt - S[3]
            if tb < 0 || tb > 2bcnt || tb % 2 == 1; continue; end
            if tc < 0 || tc > 2ccnt || tc % 2 == 1; continue; end
            if td < 0 || td > 2dcnt || td % 2 == 1; continue; end
            b = tb ÷ 2; c = tc ÷ 2; d = td ÷ 2

            ## Now we need to sum the way this can happen
            ways::Int128 = binomial(Int128(acnt),Int128(a)) * binomial(Int128(bcnt),Int128(b)) * 
                           binomial(Int128(ccnt),Int128(c)) * binomial(Int128(dcnt),Int128(d))
            totways += ways
            witha += ways * a; againsta += ways * (acnt-a)
            withb += ways * b; againstb += ways * (bcnt-b)
            withc += ways * c; againstc += ways * (ccnt-c)
            withd += ways * d; againstd += ways * (dcnt-d)
        end

        num = max(witha,againsta) + max(withb,againstb) + max(withc,againstc) + max(withd,againstd)
        denom = totways
        g::Int128 = gcd(num,denom); num ÷= g; denom ÷= g
        for i in 1:Q
            if A[1][i] == A[2][i] && A[1][i] == A[3][i]
                x = A[1][i]; nx = x == 'T' ? 'F' : 'T'
                push!(resarr, witha >= againsta ? x : nx)
            elseif A[1][i] == A[2][i] && A[1][i] != A[3][i]
                x = A[1][i]; nx = x == 'T' ? 'F' : 'T'
                push!(resarr, withb >= againstb ? x : nx)
            elseif A[1][i] != A[2][i] && A[1][i] == A[3][i]
                x = A[1][i]; nx = x == 'T' ? 'F' : 'T'
                push!(resarr, withc >= againstc ? x : nx)
            else
                x = A[2][i]; nx = x == 'T' ? 'F' : 'T'
                push!(resarr, withd >= againstd ? x : nx)
            end
        end
    else ## Shouldn't get here
        resarr = ['F' for i in 1:Q]
        num = 0
        denom = 1
    end
    resstr = join(resarr,"")
    return "$resstr $num/$denom"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,Q = gis()
        A::VS = []
        S::VI = []
        for i in 1:N
            xx = gss()
            push!(S,parse(Int64,xx[2]))
            push!(A,xx[1])
        end
        ans = solve(N,Q,A,S)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()