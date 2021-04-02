function prework()
    s1a = "ejp mysljylc kd kxveddknmc re jsicpdrysi"
    s2a = "rbcpc ypc rtcsra dkh wyfrepkym veddknkmkrkcd"
    s3a = "de kr kd eoya kw aej tysr re ujdr lkgc jv"
    s4a = "yeq"
    s5a = "z"
    
    s1b = "our language is impossible to understand"
    s2b = "there are twenty six factorial possibilities"
    s3b = "so it is okay if you want to just give up"
    s4b = "aoz"
    s5b = "q"

    d::Dict{Char,Char} = Dict{Char,Char}()
    for (sa,sb) in [(s1a,s1b),(s2a,s2b),(s3a,s3b),(s4a,s4b),(s5a,s5b)]
        for (x,y) in zip(sa,sb)
            d[x] = y
        end
    end
    return d
end

function translate(d::Dict{Char,Char},s::AbstractString)::String
    a::Vector{Char} = [d[x] for x in s]
    ans::String = join(a,"")
    return ans
end


function main(infn="")
    d::Dict{Char,Char} = prework()
    translate(d,"abcdefghijklmnopqrstuvwxyz ")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S = rstrip(readline(infile))
        ans = translate(d,S)
        print("$ans\n")
    end
end

main()

