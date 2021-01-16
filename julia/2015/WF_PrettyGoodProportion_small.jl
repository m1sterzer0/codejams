using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        temp = split(readline(infile))
        N = parse(Int64,temp[1])
        num = temp[2][1] == '1' ? 1000000 : parse(Int64,temp[2][3:end])
        digits::Vector{Int8} = [parse(Int8,x) for x in readline(infile)]
        onesCount = zeros(Int32,N)
        c::Int32 = 0
        for i in 1:N; c += digits[i]; onesCount[i] = c; end
        bestnum::Int128   = 10
        bestdenom::Int128 = 1
        targnum::Int128 = num
        targdenom::Int128 = 1000000
        best = 1
        for start in 1:N
            prevOnes = start == 1 ? 0 : onesCount[start-1]
            for j in start:N
                num::Int128 = onesCount[j]-prevOnes
                den::Int128 = j - start + 1
                diffnum::Int128   = den * targnum - num * targdenom
                diffdenom::Int128 = targdenom * den
                if diffnum < 0; diffnum = -diffnum; end
                if bestdenom * diffnum < bestnum * diffdenom
                    bestnum = diffnum
                    bestdenom = diffdenom
                    best = start
                end
            end
        end
        print("$(best-1)\n")
    end
end

main()

