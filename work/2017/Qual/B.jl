using Printf

######################################################################################################
### We think of the following relatively straightforward process that works for long digits
### Step1) Work from left to right until we find two consecutive digits i,j with j>i
### Step2) Change i --> i-1 and all digits >= j to 9
### Step3) Work back from right to left and if we find j,j+1 with c[j] > c[j+1], tranform to (c[j]-1,9)
### Step4) Strip off any leading zero as needed
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        S = "$N"
        carr = [x for x in S]
        for i in 1:length(carr)-1
            if carr[i] <= carr[i+1]; continue; end
            carr[i] -= 1
            for j in i+1:length(carr); carr[j] = '9'; end
            for j in i-1:-1:1
                if carr[j] > carr[j+1]; carr[j+1] = '9'; carr[j] -= 1; end
            end
            break
        end
        ans = carr[1] == '0' ? join(carr[2:end],"") : join(carr[1:end],"")
        print("$ans\n")
    end
end

main()
