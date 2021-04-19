using Printf

######################################################################################################
### Not hard
### --- We make horizontal cuts that make sure every row with characters is in its own multirow piece.
### --- After that, we slice multirow piece with vertical cuts such that each name gets a piece
######################################################################################################

function processRow(cake2,ri,rj,charrow,C)
    lastCol = 1
    for j in 1:C
        if charrow[j] != '?'; cake2[ri:rj,lastCol:j] .= charrow[j]; lastCol = j+1; end
    end
    cake2[ri:rj,lastCol:C] .= charrow[lastCol-1]
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        cake1 = fill('.',R,C); cake2 = fill('.',R,C)
        for i in 1:R; cake1[i,:] = [x for x in rstrip(readline(infile))]; end
        lastRow = 1
        for i in 1:R
            p = [x for x in cake1[i,:] if x != '?']
            if length(p) > 0; processRow(cake2,lastRow,i,cake1[i,:],C); lastRow = i+1; end
        end
        for i in lastRow:R; cake2[i,:] = cake2[lastRow-1,:]; end
        for i in 1:R; println(join(cake2[i,:],"")); end
    end
end

main()
