
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

function simulate(numDebuf::I,numBuf::I,Hd::I,Ad::I,Hk::I,Ak::I,B::I,D::I)::I
    origHd::I = Hd
    lastHeal::Bool = false
    for turns in 1:1000000000
        nextAttack::I = (numDebuf > 0) ? Ak-D : Ak
        if Ad >= Hk; return turns; end
        if Hd <= nextAttack
            if lastHeal; return typemax(Int64); end
            Hd = origHd
            lastHeal = true
        else
            lastHeal = false
            if     numDebuf > 0; numDebuf -= 1; Ak -= D
            elseif numBuf   > 0; numBuf -= 1  ; Ad += B
            else ;                              Hk -= Ad
            end
        end
        Hd -= Ak  ## Knight move
        if Hd <= 0; return typemax(Int64); end
    end
    return typemax(Int64)
end

function solveSmall(Hd::I,Ad::I,Hk::I,Ak::I,B::I,D::I)::String
    maxd::I = D == 0 ? 0 : max(0,(Ak + D - 1) ÷ D)
    maxb::I = B == 0 ? 0 : max(0,(Hk-Ad+B-1) ÷ B)
    best::I = typemax(Int64)
    for d::I in 0:maxd
        for b::I in 0:maxb
            res = simulate(d,b,Hd,Ad,Hk,Ak,B,D)
            best = min(best,res)
        end
    end
    return best < typemax(Int64) ? "$best" : "IMPOSSIBLE"
end 

## So many "off by one" errors that we can make here
function solveEndgame(php::I,Ak::I,gapsize::I,numOffense::I)::I
    if gapsize <= 0; return typemax(Int64); end
    if Ak == 0; return numOffense; end
    prefixmoves::I = (php-1) ÷ Ak
    if prefixmoves+1 >= numOffense; return numOffense; end
    numHeals::I = 1 + (numOffense-prefixmoves-2) ÷ gapsize
    return numOffense + numHeals
end

## Do the no-debuf calc -- keeping in mind we don't have to heal right before a finishing move
function solveDefense(numOffense::I,D::I,Hd::I,Ak::I)::I
    gapSize::I = Ak == 0 ? typemax(Int64) : (Hd - 1) ÷ Ak - 1
    prefixmoves::I = 0
    php::I = Hd
    postfix::I = solveEndgame(php,Ak,gapSize,numOffense)
    bestmoves::I = postfix == typemax(Int64) ? typemax(Int64) : postfix + prefixmoves
    if D == 0; return bestmoves; end
    while (Ak > 0)
        AkTarget::I = (Hd-1) ÷ (gapSize+2)
        dsteps::I = (Ak - AkTarget + D - 1) ÷ D
        if dsteps > 3 * max(1,(gapSize+1))

            ## Prefix Moves
            lmoves::I = (php-1) ÷ (Ak - D)
            prefixmoves += lmoves; dsteps -= lmoves
            php -= lmoves * Ak - lmoves * (lmoves + 1) * D ÷ 2
            Ak -= lmoves * D
            while php - 1 >= Ak - D; prefixmoves += 1; dsteps -= 1; Ak -= D; php -= Ak; end
            php = Hd - Ak; prefixmoves += 1; ## Heal

            ## Middle Sets
            fullsets::I = (dsteps - 1) ÷ gapSize
            prefixmoves += fullsets * (gapSize+1); dsteps -= fullsets * gapSize; Ak -= D * fullsets * gapSize; php = Hd - Ak

            ## Postfix Sets
            php -= dsteps * Ak - dsteps * (dsteps + 1) * D ÷ 2
            Ak -= dsteps * D
            prefixmoves += dsteps

        else
            ### Simulation
            for i::I in 1:dsteps
                if php - 1 < Ak - D
                    prefixmoves += 2
                    php = Hd - Ak
                    Ak = max(0,Ak-D)
                    php -= Ak
                else
                    prefixmoves += 1
                    Ak = max(0,Ak-D)
                    php -= Ak
                end
            end
        end

        gapSize = Ak == 0 ? typemax(Int64) : (Hd - 1) ÷ Ak - 1 
        postfix = solveEndgame(php,Ak,gapSize,numOffense)
        moves::I = postfix == typemax(Int64) ? typemax(Int64) : postfix + prefixmoves
        bestmoves = min(moves,bestmoves)
    end
    return bestmoves
end

function optimizeOff(n::I,Ad::I,B::I)::TI
    best::TI = (0,n,n*Ad)
    if B == 0; return 0,n,n*Ad; end
    if Ad >= B * n; return 0,n,n*Ad; end
    bmax2::I = n - Ad ÷ B
    bmax::I = min(n,(bmax2 + 1) ÷ 2)
    bmin::I = max(0,bmax-3)
    for b in bmin:bmax
        dmg::I = (Ad+b*B)*(n-b)
        if dmg > best[3]; best=(b,n-b,dmg); end
    end
    return best
end

function solveOffense(Hk::I,Ad::I,B::I)::PI
    lb::I,ub::I = 1,(Hk+Ad-1) ÷ Ad
    numBuff::I,numAttack::I = 0,ub 
    while (ub-lb > 1)
        mid::I = (ub+lb) ÷ 2
        (nb::I,na::I,tot::I) = optimizeOff(mid,Ad,B)
        if tot >= Hk
            numBuff,numAttack = nb,na
            lb,ub = lb,mid
        else
            lb,ub = mid,ub
        end
    end
    return numBuff,numAttack
end

function solveLarge(Hd::I,Ad::I,Hk::I,Ak::I,B::I,D::I)::String
    ## Preliminaries
    if Ad >= Hk; return "1"; end
    if Hd > Ak && max(2*Ad,Ad+B) >= Hk; return "2"; end
    if Hd <= (Ak - D); return "IMPOSSIBLE"; end
    if Hd <= 2Ak - 3D; return "IMPOSSIBLE"; end
    numBuff,numAttack = solveOffense(Hk,Ad,B)
    ans = solveDefense(numBuff+numAttack,D,Hd,Ak)
    return "$ans"
end

function gencase(Hdmin::I,Hdmax::I,Hkmin::I,Hkmax::I,Akmin::I,Akmax::I,
                 Bmin::I,Bmax::I,Dmin::I,Dmax::I,Admin::I,Admax::I)
    Hd = rand(Hdmin:Hdmax)
    Hk = rand(Hkmin:Hkmax)
    Ak = rand(Akmin:Akmax)
    B  = rand(Bmin:Bmax)
    D  = rand(Dmin:Dmax)
    Ad = rand(Admin:Admax)
    return (Hd,Hk,Ak,B,D,Ad)
end

function test(ntc::I,Hdmin::I,Hdmax::I,Hkmin::I,Hkmax::I,Akmin::I,Akmax::I,
                     Bmin::I,Bmax::I,Dmin::I,Dmax::I,Admin::I,Admax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (Hd,Hk,Ak,B,D,Ad) = gencase(Hdmin,Hdmax,Hkmin,Hkmax,Akmin,Akmax,Bmin,Bmax,Dmin,Dmax,Admin,Admax)

        ans2 = solveLarge(Hd,Hk,Ak,B,D,Ad)
        if check
            ans1 = solveSmall(Hd,Hk,Ak,B,D,Ad)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(Hd,Hk,Ak,B,D,Ad)
                ans2 = solveLarge(Hd,Hk,Ak,B,D,Ad)
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
        Hd,Ad,Hk,Ak,B,D = gis()
        #ans = solveSmall(Hd,Ad,Hk,Ak,B,D)
        ans = solveLarge(Hd,Ad,Hk,Ak,B,D)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#for ntc in (1,10,100,1000,10000) 
#    test(ntc,1,100,1,100,1,100,0,2,0,2,1,3)
#    test(ntc,1,1000,1,1000,1,1000,0,2,0,2,1,3)
#    test(ntc,1,10000,1,10000,1,10000,0,2,0,2,1,3)
#end
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

