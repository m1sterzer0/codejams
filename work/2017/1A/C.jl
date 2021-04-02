using Printf

############################################################################################################
### We focus on the small problem first.  Several observations
### -- The optimal number of attack moves can be calculated independent of the defense moves
###
### -- Preliminaries: Survival.  Checking for near instant win and ability to avoid healing loop. In priority order.
###    * If our first attack kills, we win.
###    * If we can survive one full hit and our second attack kills, we win
###    * If we can't survive one debuffed hit, we lose
###    * If we can't survive two hits (with debuffs), we lose.
###      
### -- Attack strategy
###    * Lets first think about the simpler problem of maximizing my damage given that we have n moves
###      for buffing/attacking
###    * Our total damage = (Ad + b * B) * (n-b)
###    * Assume b is a continuous quantity.  to maximize this, we set the derivative equal to zero.
###    * Using sympy (because I'm lazy), we get b = 1/2 (n - Ad/B)
###    * Thus, for fixed n, we calculate the floor of this value and check from floor-2 to floor+2 and
###      find the maximum.
###    * Now we can binary search on n to find the minimum number of moves that we need.
###
### -- Defense strategy
###    * This is a bit tougher (both logistically and strategicly)
###    * It only makes sense to debuf to a "breaking point" where we get another turn between heals.
###    * What case am I worried about? Hk=1e9, Hd=1e9, Ak=500e6, Ad=1, B=0, and D in [1,2,3,4,5,6,7,8,9,10]
###    * I think we just have to deal with the tedious endpoint bookkeeping 
### 
############################################################################################################

function optimizeOff(n,Ad,B)
    best = (0,n,n*Ad)
    if B == 0
        return 0,n,n*Ad
    elseif Ad >= B * n
        return 0,n,n*Ad
    else
        bmax2 = n - Ad ÷ B
        bmax = min(n,(bmax2 + 1) ÷ 2)
        bmin = max(0,bmax-3)
        for b in bmin:bmax
            dmg = (Ad+b*B)*(n-b)
            if dmg > best[3]; best=(b,n-b,dmg); end
        end
    end
    return best
end

function solveOffense(Hk,Ad,B)
    lb,ub = 1,(Hk+Ad-1) ÷ Ad
    numBuff,numAttack = 0,ub 
    while (ub-lb > 1)
        mid = (ub+lb) ÷ 2
        (nb,na,tot) = optimizeOff(mid,Ad,B)
        if tot >= Hk
            numBuff,numAttack = nb,na
            lb,ub = lb,mid
        else
            lb,ub = mid,ub
        end
    end
    return numBuff,numAttack
end

## So many "off by one" errors that we can make here
function solveEndgame(php,Ak,gapsize,numOffense)
    if gapsize <= 0; return typemax(Int64); end
    if Ak == 0; return numOffense; end
    prefixmoves = (php-1) ÷ Ak
    if prefixmoves+1 >= numOffense; return numOffense; end
    numHeals = 1 + (numOffense-prefixmoves-2) ÷ gapsize
    return numOffense + numHeals
end

## Do the no-debuf calc -- keeping in mind we don't have to heal right before a finishing move
function solveDefense(numOffense,D,Hd,Ak)
    gapSize = Ak == 0 ? typemax(Int64) : (Hd - 1) ÷ Ak - 1
    prefixmoves = 0
    php = Hd
    postfix = solveEndgame(php,Ak,gapSize,numOffense)
    bestmoves = postfix == typemax(Int64) ? typemax(Int64) : postfix + prefixmoves
    if D == 0; return bestmoves; end
    while (Ak > 0)
        AkTarget = (Hd-1) ÷ (gapSize+2)
        dsteps = (Ak - AkTarget + D - 1) ÷ D
        if dsteps > 3 * max(1,(gapSize+1))

            ## Prefix Moves
            lmoves = (php-1) ÷ (Ak - D)
            prefixmoves += lmoves; dsteps -= lmoves
            php -= lmoves * Ak - lmoves * (lmoves + 1) * D ÷ 2
            Ak -= lmoves * D
            while php - 1 >= Ak - D; prefixmoves += 1; dsteps -= 1; Ak -= D; php -= Ak; end
            php = Hd - Ak; prefixmoves += 1; ## Heal

            ## Middle Sets
            fullsets = (dsteps - 1) ÷ gapSize
            prefixmoves += fullsets * (gapSize+1); dsteps -= fullsets * gapSize; Ak -= D * fullsets * gapSize; php = Hd - Ak

            ## Postfix Sets
            php -= dsteps * Ak - dsteps * (dsteps + 1) * D ÷ 2
            Ak -= dsteps * D
            prefixmoves += dsteps

        else
            ### Simulation
            for i in 1:dsteps
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
        moves = postfix == typemax(Int64) ? typemax(Int64) : postfix + prefixmoves
        bestmoves = min(moves,bestmoves)
    end
    return bestmoves
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        Hd,Ad,Hk,Ak,B,D = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        
        ## Preliminaries
        if Ad >= Hk;                         print("1\n"); continue; end
        if Hd > Ak && max(2*Ad,Ad+B) >= Hk;  print("2\n"); continue; end
        if Hd <= (Ak - D);                   print("IMPOSSIBLE\n"); continue; end
        if Hd <= 2Ak - 3D;                   print("IMPOSSIBLE\n"); continue; end

        numBuff,numAttack = solveOffense(Hk,Ad,B)
        ans = solveDefense(numBuff+numAttack,D,Hd,Ak)
        print("$ans\n")
    end
end

main()
