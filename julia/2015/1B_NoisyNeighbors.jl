######################################################################################################
### Greedy solution --> Maximally fill array and then remove best options sensibly
### * WLOG R <= C
### * Full unhappiness is (R-1)*C + (C-1)*R (simple interior wall count)
### * R == 1 and C even
###   First C/2-1 are worth 2, next is worth 1, then we are at zero unhappiness
### * R == 1 and C odd
###   (C-1)/2 are worth 2, then we are at zero unhappiness
### * R == 2
###   C-2 are worth 3, 2 are worth 2, and then we are at zero unhappiness
##  * R >= 3 and at least one of R or C are even
##    - half of (R-2)*(C-2) are worth 4 
##    - R-2 + C-2 are worth 3
##    - 2 are worth 2
##  * R >= 3 and both R and C are odd.  Here we check both checkerboard cases
##    - Case 1 -- leave the corners out
##      - ((R-2)*(C-2)-1) ÷ 2 are worth 4
##      - R-1 + C-1 are worth 3
##    - Case 4 -- corners are in
##      - ((R-2)*(C-2)+1) ÷ 2 are worth 4
##      - R-3 + C-3 are worth 3
##      - 4 are worth 2
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,N = [parse(Int64,x) for x in split(readline(infile))]
        if R > C; (R,C) = (C,R); end
        unh = (R-1)*C + (C-1)*R
        gaps = R*C - N
        #print("R:$R C:$C\n")
        if R == 1 && C % 2 == 0
            v = min(gaps,C ÷ 2 - 1); unh -= 2 * v; gaps -= v
            unh -= gaps
        elseif R == 1 && C % 2 == 1
            v = min(gaps,(C-1) ÷ 2); unh -= 2 * v; gaps -= v
            unh -= gaps
        elseif R == 2
            v = min(gaps,C-2); unh -= 3 * v; gaps -= v
            v = min(gaps,2);   unh -= 2 * v; gaps -= v
            unh -= gaps
        elseif R*C % 2 == 0
            v = min(gaps,(R-2)*(C-2)÷2); unh -= 4 * v; gaps -= v
            v = min(gaps,R+C-4);         unh -= 3 * v; gaps -= v
            v = min(gaps,2);             unh -= 2 * v; gaps -= v
            unh -= gaps
        else
            unh1,unh2 = unh,unh
            v = min(gaps,((R-2)*(C-2)-1)÷2); unh1 -= 4 * v; gaps -= v
            v = min(gaps,R+C-2);             unh1 -= 3 * v; gaps -= v
            unh1 -= gaps
            gaps = R*C - N
            v = min(gaps,((R-2)*(C-2)+1)÷2); unh2 -= 4 * v; gaps -= v
            v = min(gaps,R+C-6);             unh2 -= 3 * v; gaps -= v
            v = min(gaps,4);                 unh2 -= 2 * v; gaps -= v            
            unh2 -= gaps
            unh = min(unh1,unh2)
        end

        unh = max(0,unh)
        print("$unh\n")
    end
end

main()
    
