using Printf

###########################################################################################################
### We focus on the small problem first.  We need a few observations first.
### -- We are incentivized to do all of our buffs before our attacks, and we are incentivised to
###    frontload our debuffs to minimize the required amount of healing
### -- It doesn't make sense to buff beyond that which will enable a single attack to kill the Knight
### -- It doesn't make sense to debuff beyond that which makes the Knight's attack zero.
### -- In the small, we should be healing at worst every other turn, and we should be doing 1 damage
###    in the off turns.  This means that for the small, we shouldn't be running much more than 200 turns.
### Thus, we just sweep the number of buffs/debuffs and simulate.
###########################################################################################################

function simulate(numDebuf,numBuf,Hd,Ad,Hk,Ak,B,D)
    origHd = Hd
    lastHeal = false
    for turns in 1:1000000000
        nextAttack = (numDebuf > 0) ? Ak-D : Ak
        if Ad >= Hk
            return turns
        elseif Hd <= nextAttack
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

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        Hd,Ad,Hk,Ak,B,D = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        maxd = D == 0 ? 0 : max(0,(Ak + D - 1) ÷ D)
        maxb = B == 0 ? 0 : max(0,(Hk-Ad+B-1) ÷ B)
        best = typemax(Int64)
        for d in 0:maxd
            for b in 0:maxb
                res = simulate(d,b,Hd,Ad,Hk,Ak,B,D)
                best = min(best,res)
            end
        end
        print(best < typemax(Int64) ? "$best\n" : "IMPOSSIBLE\n")
    end
end

main()
