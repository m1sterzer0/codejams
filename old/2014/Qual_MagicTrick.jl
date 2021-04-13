######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        board1 = zeros(Int64,4,4)
        board2 = zeros(Int64,4,4)
        ans1 = parse(Int64,readline(infile))
        for i in 1:4; board1[i,:] = [parse(Int64,x) for x in split(readline(infile))]; end
        ans2 = parse(Int64,readline(infile))
        for i in 1:4; board2[i,:] = [parse(Int64,x) for x in split(readline(infile))]; end
        s1 = Set(board1[ans1,:])
        s2 = Set(board2[ans2,:])
        s3 = intersect(s1,s2)
        if length(s3) == 0
            print("Volunteer cheated!\n")
        elseif length(s3) > 1
            print("Bad magician!\n")
        else
            ans = [x for x in s3][1]
            print("$ans\n")
        end
    end
end

main()
