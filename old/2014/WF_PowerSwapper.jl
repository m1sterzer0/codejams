######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function doit(L::Vector{Int64}, swapsSoFar::Int64, factorial::Vector{Int64})::Int64
    if length(L) == 2; return L[1] < L[2] ? factorial[swapsSoFar+1] : factorial[swapsSoFar+2]; end
    bi1,bi2 = 0,0
    for i in 1:2:length(L)
        if L[i] % 2 == 1 && L[i+1] == L[i] + 1; continue; end
        if bi2 > 0; return 0
        elseif bi1 > 0; bi2 = i
        else; bi1 = i
        end
    end
    if bi1 == 0 
        return doit([x ÷ 2 for x in L[2:2:end]],swapsSoFar,factorial)
    elseif bi2 == 0
        LL = L[:]
        LL[bi1],LL[bi1+1] = LL[bi1+1],LL[bi1]
        return doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1,factorial)
    else
        a,b,c,d = L[bi1],L[bi1+1],L[bi2],L[bi2+1]
        if d % 2 == 1 && c % 2 == 1 && b == d+1 && a == c+1 ## Case is [a,b] [c,d] --> [d,b] [c,a]
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = d,b,c,a
            return doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1,factorial)
        elseif a % 2 == 1 && b % 2 == 1 && c == a+1 && d == b+1 ## Case is [a,b] [c,d] --> [a,c] [b,d]
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = a,c,b,d
            return doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1,factorial) 
        elseif c % 2 == 1 && a % 2 == 1 && b == c+1 && d == a+1  ## Case is [a,b] [c,d] --> [c,b] [a,d] or [a,d] [c,b]
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = c,b,a,d
            ans1 = doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1,factorial)
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = a,d,c,b
            ans2 = doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1,factorial)
            return ans1 + ans2
        else
            return 0
        end
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    factorial::Vector{Int64} = fill(1,14)
    for i in 1:13; factorial[i+1] = i * factorial[i]; end
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        L::Vector{Int64} = [parse(Int64,x) for x in split(readline(infile))]
        ans = doit(L,0,factorial)
        print("$ans\n")
    end
end

main()
