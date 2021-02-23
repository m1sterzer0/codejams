function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        X,Y = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        needed,tot,inc = abs(X) + abs(Y),0,0
        while tot < needed || tot % 2 != needed % 2; inc += 1; tot += inc; end
        a = ['.' for i in 1:inc]
        for i in inc:-1:1
            if abs(X) >= abs(Y)
                (cc,ii) = X > 0 ? ('E',-i) : ('W',i)
                a[i] = cc; X += ii
            else
                (cc,ii) = Y > 0 ? ('N',-i) : ('S',i)
                a[i] = cc; Y += ii
            end
        end
        ans = X==0 && Y==0 ? join(a,"") : "ERROR"
        print("$ans\n")
    end
end

main()

