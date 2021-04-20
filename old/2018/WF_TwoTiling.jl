
function reduceTile(tile::UInt64)::UInt64
    if tile == 0; return 0; end
    while tile & 7 == 0; tile = tile >> 3; end
    while tile & 73 == 0; tile = tile >> 1; end
    return tile
end

function rotateTile(tile::UInt64)::UInt64
    rbpos = [2,5,8,1,4,7,0,3,6]
    ans::UInt64 = 0
    for b in [2,5,8,1,4,7,0,3,6]
        ans = (ans << 1) | ((tile >> b) & 1)
    end
    return ans
end

function mirrorTile(tile::UInt64)::UInt64
    return (tile & 56) | ((tile & 7) << 6) | (tile >> 6)
end

function validTile(tile::UInt64)::Bool
    if tile == 0; return false; end
    start = 1; while start & tile == 0; start = start << 1; end
    lstart = 0;
    ##Inefficient, but this is pretty short, and we only do this up front
    while start != lstart  
        lstart = start
        for i in 0:8
            if lstart & (1 << i) == 0; continue; end
            if i >= 3 && (tile & (1 << (i-3)) != 0); start |= 1 << (i-3); end
            if i <= 5 && (tile & (1 << (i+3)) != 0); start |= 1 << (i+3); end
            if i % 3 != 0 && (tile & (1 << (i-1)) != 0); start |= 1 << (i-1); end
            if i % 3 != 2 && (tile & (1 << (i+1)) != 0); start |= 1 << (i+1); end
        end
    end
    return start == tile
end

function genCopies(tile::UInt64)::Set{UInt64}
    ans = Set{UInt64}()
    push!(ans,tile)
    for i in 1:3; tile = reduceTile(rotateTile(tile)); push!(ans,tile); end
    tile = reduceTile(mirrorTile(tile)); push!(ans,tile)
    for i in 1:3; tile = reduceTile(rotateTile(tile)); push!(ans,tile); end
    return ans
end

function genBoardTilings(tile::UInt64,boardDb::Vector{Vector{Tuple{Int64,UInt64}}})
    ## Assume the tiles coming in have been reduced
    w = tile & 0b001001001 == tile ? 1 : tile & 0b011011011 == tile ? 2 : 3
    h = tile & 7 == tile ? 1 : tile & 63 == tile ? 2 : 3
    for r in 7-h+1:-1:0
        for c in 7-w+1:-1:0
            bstart = 8*r+c
            bval::UInt64 = ((tile & 7) << bstart) | (((tile & 0b111000)>>3) << (bstart+8)) | (((tile & 0b111000000)>>6) << (bstart+16))
            while bval & (1 << bstart) == 0; bstart += 1; end
            for i in 0:63
                if bval & (1 << i) != 0; push!(boardDb[1+i],(i-bstart,bval)); end
            end
        end
    end
end

function createTileDb()::Dict{UInt64,Set{UInt64}}
    ans::Dict{UInt64,Set{UInt64}} = Dict{UInt64,Set{UInt64}}()
    for tile::UInt64 in 1:511
        if tile != reduceTile(tile); continue; end
        if !validTile(tile); continue; end
        c = genCopies(tile)
        mt = minimum(c)
        if tile != mt; continue; end
        ans[tile] = c
    end
    return ans
end

function solveguts(p1::UInt64,p2::UInt64,pos::Int64,
                   bp1::Vector{Vector{Tuple{Int64,UInt64}}},
                   bp2::Vector{Vector{Tuple{Int64,UInt64}}})::Tuple{Bool,Char,Char,Vector{Char},Vector{Char}}
    if p1 == p2; return (true,'a','a',['.' for i in 1:64],['.' for i in 1:64]); end
    mask::UInt64 = UInt64(1) << pos
    while (p1 & mask == p2 & mask); pos += 1; mask <<= 1; end
    targ::Int64 = p1 & mask == 0 ? 1 : 2
    (targmask::UInt64,bpm::Vector{Vector{Tuple{Int64,UInt64}}}) = targ == 1 ? (p1,bp1) : (p2,bp2)
    uint0 = UInt64(0)
    for (off::Int64,bp::UInt64) in bpm[pos+1] 
        if bp & targmask != uint0; continue; end
        (newp1,newp2) = targ == 1 ? (p1|bp,p2) : (p1,p2|bp)
        (res,c1,c2,carr1,carr2) = solveguts(newp1,newp2,pos-off,bp1,bp2)
        if res
            if targ == 1
                place(c1,carr1,bp);
                return (true, (c1=='z' ? 'A' : c1+1),c2,carr1,carr2)
            else
                place(c2,carr2,bp);
                return (true, c1, (c2=='z' ? 'A' : c2+1),carr1,carr2)
            end
        end
    end
    return (false,'a','a',[],[])
end

function solveit(sa::Set{UInt64},sb::Set{UInt64})::Tuple{Bool,Vector{Char},Vector{Char}}
    bp1::Vector{Vector{Tuple{Int64,UInt64}}} = [Vector{Tuple{Int64,UInt64}}() for i in 1:64]
    bp2::Vector{Vector{Tuple{Int64,UInt64}}} = [Vector{Tuple{Int64,UInt64}}() for i in 1:64]
    for a in sa; genBoardTilings(a,bp1); end
    for b in sb; genBoardTilings(b,bp2); end
    #for i in 1:64; sort!(bp1[i]); sort!(bp2[i]); end
    for i in 1:64; sort!(bp1[i],rev=true); sort!(bp2[i],rev=true); end

    startingpos = []
    for pos in 0:7
        for (off,a) in bp1[pos+1]
            push!(startingpos,a)
        end
    end
    unique!(sort!(startingpos))
    for a in startingpos
        (res,c1,c2,carr1,carr2) = solveguts(a,UInt64(0),0,bp1,bp2)
        if res
            place(c1,carr1,a) 
            return (true,carr1,carr2)
        end
    end
    return (false,[],[])
end

function place(c::Char,carr::Vector{Char},pattern::UInt64)
    for i in 0:63
        if pattern & (1 << i) != 0
            carr[i+1] = c
        end
    end
end

function gendata()
    tilesb = createTileDb()
    stridx = 1
    strmap = Dict{String,Int64}()
    strtab = []
    anslines = []

    karr = sort([x for x in keys(tilesb)])
    for k1 in karr
        for k2 in karr
            if k1 >= k2; continue; end
            (ans,carr1,carr2) = solveit(tilesb[k1],tilesb[k2])
            if ans
                strs = [k1,k2]
                for a in 1:8:64
                    str1 = join(carr1[a:a+7],"")
                    str2 = join(carr2[a:a+7],"")
                    if !haskey(strmap,str1) 
                        strmap[str1] = stridx; 
                        stridx+=1;
                        push!(strtab,str1)
                    end
                    if !haskey(strmap,str2)
                        strmap[str2] = stridx
                        stridx+=1
                        push!(strtab,str2)
                    end
                    push!(strs,strmap[str1])
                    push!(strs,strmap[str2])
                end
                push!(anslines,join(strs," "))
            end
        end
    end
    print("STRTAB\n")
    for w in strtab; print("$w\n"); end
    print("DATA PAIRS\n")
    for a in anslines; print("$a\n"); end
    print("END")
end


function processString(sa)
    va::UInt64 = 0
    for i in 1:9
        if sa[i] == '@'; va |= (1<<(i-1)); end
    end
    va = reduceTile(va)
    ca = genCopies(va)
    m1 = minimum(ca)
    return m1
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    strtab,m = getdata()

    for qq in 1:tt
        print("Case #$qq: ")
        s1 = readline(infile)
        s2 = readline(infile)
        s3 = readline(infile)
        readline(infile) ## Should be blank
        sa = s1[1:3]*s2[1:3]*s3[1:3]
        sb = s1[5:7]*s2[5:7]*s3[5:7]
        m1 = processString(sa)
        m2 = processString(sb)
        if haskey(m,(m1,m2))
            l = m[(m1,m2)]
            print("POSSIBLE\n")
            for i in 1:2:16
                s1,s2 = strtab[l[i]],strtab[l[i+1]]
                print("$s1 $s2\n")
            end
        elseif haskey(m,(m2,m1))
            l = m[(m2,m1)]
            print("POSSIBLE\n")
            for i in 1:2:16
                s1,s2 = strtab[l[i]],strtab[l[i+1]]
                print("$s2 $s1\n")
            end
        else
            print("IMPOSSIBLE\n")
        end
    end
end        

function getdata()
    data1="""b.......
a.......
........
c.......
ba......
aa......
d.......
cb......
dc......
.a......
e.......
ed......
.c......
fe......
cba.....
aaa.....
.ba.....
.aa.....
f.......
e.d.....
a.a.....
edc.....
.b......
dcb.....
.d......
g.......
fed.....
.e......
.dc.....
gf......
.ed.....
hg......
g.f.....
gfe.....
h.g.....
hgf.....
ihg.....
cc......
llk.....
hgg.....
jik.....
hhg.....
jih.....
fee.....
gfh.....
ffe.....
dcc.....
dce.....
ddc.....
baa.....
aab.....
bba.....
zzyttsrj
mlljiiid
x.yuqsrj
m.ljjjid
xwvuqkki
mmlkhedd
.wvpolhi
.kkkheee
nnmpolh.
fggghhc.
gfme.dd.
fbbg.ac.
gfcebbaa
ffbaaacc
..c.....
..b.....
BBAzwp..
nmmmlg..
yxAzwpon
nnmllggf
yx.vvqon
nk.jlgff
.utsrqmm
.kkjjhef
hutsrlkj
dkijhhee
hiigdlkj
ddiiahec
feegdccb
dbiaaacc
faa....b
bbb....c
hh......
dd......
bb......
zzyvuts.
mllkkjj.
xwyvutsr
mmllkkjj
xw..pqqr
im..gghh
onmmplkh
iifgghhc
onji.lkh
eiff.dcc
ggjifed.
eebfddc.
.ccbfed.
.ebbdaa.
...b..aa
eedc....
baaa....
badc....
bbaa....
yyrrkk..
jjggcc..
.x.q.jhh
.j.g.cbb
wxsqlj.g
jjggcc.b
wvspliig
iihhddbb
.v.pf...
.i.hd...
uttofmbb
iihhddaa
u.no.m.a
f.fe.e.a
eenddcca
fffeeeaa
yyxxkkl.
jiiiccc.
w..vjmli
j..icddd
wutvjm.i
jjjice.d
sut..hgg
hhh..ebd
s.rnfheb
g.heeeba
q.rnfdeb
g.hfbbba
qpoc.daa
gggf.aaa
.poc....
.fff....
yyxutsr.
jiihhgg.
wvxutsrq
jjiihhgg
wvponn.q
fjjieh.g
mlpokj..
ffddee..
mliikjhe
cffddeea
gg.ff.he
cc.bd.aa
.ddccbb.
.ccbbaa.
....aa..
....bb..
xxwv.onm
hggg.ddd
utwv.onm
hhgg.edd
utsrlk.j
hhhgee.d
qpsrlk.j
fffeee.c
qpigfhhe
bffaaacc
dcigfbbe
bbfaaccc
dcaa....
bbba....
uuts....
gfff....
rqtsll..
gfgfdd..
rqpo.k..
gggf.d..
nmpojkh.
eeedddb.
nmi.j.h.
cce.b.b.
gfieedd.
ceeabbb.
gfcc.b..
ccca.a..
...aab..
...aaa..
tts.qlkk
hhh.gccc
.rspqlj.
.hgggdc.
.r.poij.
.h.fgdc.
mmnnoih.
eeefddd.
.gfee.h.
.efff.b.
.gf.ddc.
.ea.bbb.
..baa.c.
..aaa.b.
..a.....
ttrqpo..
hhggff..
.srqpon.
.hhggff.
.smmlln.
.hegdfc.
.kjihgg.
.eeddcc.
.kjihfee
.beeddcc
dd...f..
bb...a..
.cc.bb..
.bb.aa..
.....aa.
ccb.....
.ab.....
tt.qp...
hh.ff...
.srqpml.
.hggfee.
.sronml.
.hhgffe.
...onkkj
...ggdee
.ddffiij
.aabbddd
..c.gghh
..a.bccd
..ceebb.
..aabbc.
......aa
......cc
xx.tsr..
hh.fff..
.wutsrq.
vwuponq.
hhhgffe.
vmlponkj
ddgggeee
.mlihgkj
.dcccbbb
ffeihgd.
dddcaab.
..ecbad.
..ccabb.
...cba..
xxvuts..
.wvutsr.
mwqponr.
ehhggff.
mlqponk.
eeeddcc.
glj.iikh
bee.ddcc
gfjeeddh
bbbaddcc
.fccba..
.bbaaa..
....ba..
BBxxwq..
hhgggd..
Azyvwqpo
hhgggddd
Azyvurpo
hhhfgddd
sstturih
eeefffbb
.nmlkjih
.eefffbb
dnmlkjgg
aeeccbbb
dccff...
aaacc...
bbeeaa..
aaaccc..
..o.....
..f.....
.nomk...
.fffd...
.nlmkj..
.efddd..
iil.hj..
eee.dc..
.ge.hff.
.eb.ccc.
.geddc..
.bbbac..
..bbac..
..baaa..
....a...
xx..rr..
hh..ff..
wwvtsqp.
hhhgfff.
.uvtsqp.
.hgggfe.
ou.nmllk
dd.ggeee
ojinm.hk
dddcc.ee
.jigfeh.
.dbccca.
.ddgfecb
.bbbcaaa
..aa..cb
..bb..aa
qwponnr.
hhggffe.
qmpo.lkk
ddcc.eee
.mjihl.g
.ddcce.e
ffjihedg
ddccbbaa
...cced.
...bbaa.
....bbaa
uu..oon.
ff..ddd.
tsrqpmn.
fffeddd.
tsrqpm..
ffeeed..
klljigf.
cceeeaa.
khhjigf.
cccbaaa.
eedcbaa.
ccbbbaa.
..dcb...
..bbb...
gg......
f.e.....
b.b.....
fde.....
bbb.....
cd......
c.b.....
.fe.....
.bb.....
dfe.....
.cb.....
.de.....
ggf.....
uuttsr..
fffeee..
.q..srpp
.f..eddd
oqnmmlk.
fffeeed.
ojn..lki
ccc..ddd
.jgfhhei
.caaabbb
ddgf..e.
ccca..b.
..ccbbaa
..aaabbb
.fg.....
efd.....
f.g.....
ced.....
iih.....
ddd.....
ppplkji.
lkkhggg.
o.nlkji.
l.khhhg.
omnlkji.
llkifee.
omnhhhg.
jiiifde.
fmeeedg.
jccffde.
fccc.dg.
jjcb.dd.
f.bbbd..
a.cbbb..
pppokjih
lkkkjiii
nmlokjih
llkjjjih
lgfffehh
nmlgefff
gggfdeeh
..cgedb.
..cddeb.
..ccdbb.
..c..db.
..c..ab.
....aaa.
lllk....
iihh....
jihk....
ggff....
jihg....
fffg....
ddee....
edcg....
edcbbb..
ccbbaa..
edcaaa..
ppplk...
lkkjj...
onmlkjih
llkkjjff
ilhggffe
onmgfjih
iihhggee
.e.gfcd.
.i.hdbe.
.c.ddbb.
.ebbbcd.
.ccdaab.
..aaa...
..caa...
ttts.nml
lkkk.hhh
rqpsonml
llkkiihh
lljiiigg
rqpkojjj
ffjjeegg
iiikhhhg
ffjjeedg
cf.k.edg
bf.c.edd
cfbbbedg
bbccaadd
cfaaaed.
bbccaaa.
jjji....
ffee....
.h.i....
.f.e....
ghfi....
ghfeee..
ddccbb..
g.f.d...
d.c.b...
cccbda..
...bda..
...b.a..
...a.a..
eedd....
hgfi....
hgfe....
ccbb....
dcbe....
feee....
h..i....
f..e....
fffe....
hgfbbb..
dddaaa..
.gfc....
.cda....
eeec....
bcda....
dddc....
bccc....
jjj.....
ihgf....
dffe....
ddcc....
.edcb...
.ddcc...
.baac...
.bbaa...
..bba...
hhhg....
dccc....
fedg....
fedc....
bbbc....
aaac....
dcdc....
baba....
ooo.k..i
iii.g..f
.nm.kjhi
.ih.gfff
.nmlkjhi
.ihgggef
.nmlgjh.
.hhheee.
.felg.d.
.dddc.e.
.fe.g.d.
.bd.c.a.
.fecccd.
.bdccca.
bbb..aaa
jjjife..
ffeedd..
.hgifed.
.ffeedd.
.fcebda.
.hgcccd.
..bbbaaa
pppmlkj.
.onmlkj.
ionmlkj.
dhgggfe.
iongfhhh
dddcccee
ie.gfddd
dd.cceee
ce.gf...
bb.ac...
cebbb...
bbbaa...
c.aaa...
b.aaa...
ooonk...
iihhg...
.m.nkji.
.i.hggg.
hmlnkji.
eiihhfg.
hmlgfji.
eeefffd.
helgfdc.
ccefddd.
.e.gfdc.
.c.bdaa.
.ebbbdc.
.ccbbba.
.....aaa
.....baa
lll.k...
ffe.e...
.jjjk...
.feee...
ihhhk...
fffde...
i.gggf..
c.cddd..
ieee.fb.
cccd.da.
.cdddfb.
.bcbaaa.
.caaa.b.
.bbba.a.
lllkhg..
.jikhgf.
.jieeef.
.ccaabb.
..dddccc
..ccaabb
nnnml...
ffeee...
kj.ml...
ff.ee...
kjiml...
fffee...
kji.....
.hifff..
.ddbbb..
.hgggeba
.ddcbbaa
.hdddeba
.cccbbaa
.ccc.eba
.ccc.aaa
.nnnm...
.ggff...
lllkmjjj
gggfffee
.ihkmggg
.gddfeee
.ihkfff.
.dddcce.
.ih.eee.
.bd.ccc.
ddd.ac..
bbb.ac..
....ac..
.dddccc.
bbbaaa..
nnn.i...
fff.d...
mmmjih..
fffddd..
.lkjihgf
.fedddcc
.lkj.hgf
.eee.ccc
.lkedcgf
.eeebbcc
.baedc..
.aabbb..
.aaabb..
nnn.kkk.
fff.ddd.
mmmlll..
.jjjiii.
hhhggg.f
cceeeb.b
.eeedddf
.ccaabbb
ccc.bbbf
ccc.aabb
ppp..gfe
fff..bbb
ooo..gfe
.nm.hgfe
.ff.ccbb
lnmihd..
eeeccc..
lkji.dc.
eedd.aa.
.kjbbbc.
.dddaaa.
.kjaaac.
nnn.g.f.
fff.a.a.
..m.g.f.
..f.a.a.
lkm.ghf.
fff.aaa.
lkm..hie
eee..bbb
lkjjjhie
edddcbcb
dddcccie
eeedcbcb
.bbbaaa.
hhh.....
ccc.....
.ggg.f..
.ccb.b..
edcccf..
cccbbb..
edbbbf..
aaabbb..
fff.....
pponnmll
lkkjihhh
p.oonmml
l.kjiiih
kjjihh..
llkjjg..
kkjiih..
feeddg..
g.feedcc
f.ecdggb
ggffeddc
ffecdbbb
..acc...
..baa...
pponnlkk
lkkkjhhh
pmoonllk
llkijjhg
jmmihhgg
lfiijegg
jj.iihfg
ff.ideeg
ee.ddff.
cf.ddeb.
cea.d.bb
cca.d.bb
ccaa..b.
caaa..b.
ddcbaa..
dccbba..
ppo..lk.
lkk..hh.
pnoollkk
.nnmjii.
.ljiigf.
ffmmjjih
eejjggff
.fgge.hh
.eejg.df
..dgeecc
..ccbadd
.ddbbaac
.ccbbaad
...b..a.
ttsrrpoo
tqssrppo
llkkjjii
nqq.mll.
llh.jjg.
nnkkmmlj
ffhheegg
ihhkggjj
iih.cgaa
dfc.beaa
feedccba
ffeddbb.
ddccbba.
oo.ml...
ii.gg...
onmmllhh
ihhgffee
nnkjji.h
iihggf.e
.kk.jiig
.hh.ffee
..d.e.gg
..b.b.dd
..ddeeff
..bbbccd
..b.ccaf
..a.acdd
..bbcaa.
..aaacc.
llkjii..
lkkjji..
hggfee..
hhgffe..
dccbaa..
ddcbba..
oonnjji.
ihhhggg.
o..nkjii
i..hgfff
mllkk.hh
iiihg.ef
mmlffggh
dddcccef
.eedfcg.
.bdceee.
.beddcc.
.bdcaaa.
.bbba...
oon.kkj.
ihh.gff.
omnnlkjj
iihhggff
.mmllihh
.iiheggf
.fggeiih
.ddeeccb
ffgeedcc
ddeeccbb
bb..ddc.
da..cbb.
..aa....
hgggfeee
hhggffee
hhhgfffe
jjfiiheg
dcccbaaa
dffcbeea
dddcbbba
hghgfefe
dcdcbaba
oon.m..l
iii.h..g
.onnmmll
.ihhhggg
kk.jj.ii
fi.eh.dg
hkggjfi.
hhegffd.
fceeebd.
.ceebbdd
ccaa.b..
ccca.b..
...a....
oonmml..
iihhgg..
.onnmll.
.iihhgg.
kk.jiif.
fi.hegd.
hkgjjiff
fffeeddd
hhggeedd
cfbbeead
ccbbe.ad
cccbb.aa
.c.b.aa.
rrqoonn.
iiihggg.
rpqqomn.
iihhggf.
.ppllmmk
.ihhhgff
ijjhlgkk
ddeeefff
iijhhggf
dddeeccc
e.ddbbff
d.beaacc
eecdbaa.
bbbaaac.
.cc..a..
.bb..a..
oo.mll..
ii.ggf..
.onmmlkk
.ihhgfff
.nnjii.k
.iihgg.f
..ejjih.
..bhhee.
feegghh.
bbbcdde.
ffddgcbb
bcccadee
.aadccb.
.caaadd.
pp.mll..
.pnmmlk.
onnjjkk.
ooiijhgg
.feidhhg
ffeeddc.
...bbacc
...ccabb
....baa.
ppo.nm..
hhg.ff..
poonnmm.
hhgggff.
llkjjii.
hlkkjgi.
hhffgge.
beeddcc.
ddcfbbee
.dccab..
nnmlkk..
nmmllkjj
ffeeeddd
ihhggffj
fffceddd
iihegf..
bbbccc..
.ddeec..
.bbccc..
.dbbcc..
...baa..
.....a..
.j......
.f......
jji.g...
.hiigg..
.feddd..
.hhffd..
.eeedb..
.ee.fdd.
.ce.bbb.
cce.bb..
ccc.ab..
.c.aab..
.c.aaa..
ll.ji...
lkjjii..
.kk.hee.
.fd.ecc.
.gffhhe.
.ggfdd..
.bddac..
ccbbad..
.cb.aa..
llkjji..
.lkkjii.
.dcbbaa.
ddccba..
nn...ii.
ff...dd.
nmlljji.
kmmljhh.
ffeeedd.
kkggffh.
cceeebb.
eddg.fcc
ccca.bbb
eedbaac.
ccaaabb.
nn.mll..
ff.eee..
n.mm.l..
f.fe.e..
kjj.iihh
fff.eecc
kkj..i.h
ddd..c.c
g.f..edd
d.d..ccc
ggff.eed
ddbb.aaa
..c.bb.a
..b.ba.a
..ccb.aa
..bbb.aa
nnm...ii
fff...dd
nlmm.ji.
ffee.dd.
.llkjjhh
.ffeeddd
fggkke.h
ffg..eed
ccc..bbb
ccbb..dd
caca..bb
.cab....
.aaa....
gg.ed...
cc.bb...
gfeedd..
.cc.bbaa
.....cab
pp.nm...
ponnmm..
lookjj..
llikkj..
dddccc..
hhiigg..
hffeegbb
ddbbccaa
..fdecab
..ddccaa
nnm.iih.
nlmmjihh
feeedccc
llkjjgff
fffedddc
.ekk.ggf
dee.....
bbac....
.baa....
nnmm.l..
fffe.e..
.n.mll..
.f.eee..
kkjjiih.
fffeded.
.k.jihh.
.c.cddd.
.gffe.d.
.cccd.d.
.ggfeedd
.cbcbaaa
..ccb.a.
..bbb.a.
..c.bbaa
..b.baaa
ppo..m.l
fff..d.d
pnoommll
nnkjjihh
..kkjiih
..eeeccc
..ffgge.
..bbbcc.
ddfccgee
aaabbccc
bdaac...
aabbb...
ljkkii..
hjjggi..
hhffge..
dccfee..
...bba..
lllki..h
lkkkj..h
ljjkiiih
llkjjihh
ggjkkfhh
lgggjiih
.gj.ef.d
.fg.ei.c
.geeeffd
.ffdeecc
.cccb.dd
.fdde.bc
...cbaaa
...dabbb
jjii....
jhhi.ee.
jjii.ff.
.ghiife.
.ghfffe.
.hhggee.
.ggdddc.
.ddccee.
.baaadc.
.ba..cc.
.aa..bb.
lllkj..i
lkkjj..i
hh.gjjf.
hl.ggfi.
ehdgfff.
hhggeff.
ehdggcc.
dhcceef.
eeddbbc.
ddbccea.
.aaa.bc.
.dbb.aa.
...a.b..
ooon..k.
lkkk..h.
ommnkkkj
llmnniij
lljiiihh
hlmggijj
ggjjfeee
hlfegidd
ggjjffee
hhfegccd
dgccffbb
bffeeacd
ddccaabb
ddcaaab.
eeedaa..
e..d.a..
d..c.b..
cbbdda..
ooonkjjj
llmnnihh
glmffieh
fffeeedd
gldfiieh
ggdf..ee
cddbaaa.
ccbbaaa.
cccbbba.
jjjif...
hgggf...
j..ifffe
h..gfeee
hhgiieee
dhg...cc
ddd...ce
dhgg..c.
dbbb..c.
dd.bbbc.
da.bccc.
.a.b....
jjjih...
hggff...
jiiihg..
fffhhg..
ehhgdf..
eefdgg..
eeccdd..
eccdbbb.
beeccdd.
ecddb...
bbaac...
.caaa...
lllkhggg
ljjkhhhg
iijkkfff
eij....f
ddd....c
eiddcbbb
bddaaacc
eeadcccb
bbdaaccc
aaad....
iijkkfee
.ij..fde
.dd..ccc
.i.cffde
.d.bbaac
.cccbadd
.dddbacc
.jjjif..
.hggge..
.j.hifff
.h.gfeee
ggghiic.
hhhgfec.
eeghhdc.
dddfffc.
.ea.bdcc
.da.bccc
.ea.bdd.
.da.bbb.
.aabb...
.aaab...
.jjj.h..
.hgg.f..
ij.hhhgg
hh.ggfff
iffedddg
ehhgddfc
iifeeedg
eeeddccc
.cf.bbb.
.eb.dac.
.ccc.ab.
.bbb.aa.
lllkhhg.
hhhgeee.
lkkkihg.
hhggeed.
jjiiihgg
fhgggedd
fje..dcc
fff..ddd
fje..dc.
ffc..bb.
cccabbb.
.ccaaab.
...ba...
...aa...
.jjji...
.hhgg...
.jhgi...
.hffg...
hhhgii..
hhefgg..
ffeggc..
eeeffb..
fdeccc..
eddbbb..
fdeeaa..
ccdbaa..
.ddba...
.cdda...
.ccaa...
.fffe...
.f..e...
.d..c...
dccbee..
d.cbbb..
b.baaa..
ddc.a...
bbb.a...
lll.ji..
lkjjjih.
.kggiih.
fkkg..hh
eedd..cc
fffgeedd
aaccbed.
aaeddcb.
.ac.bed.
.aa.bbb.
.ac.bb..
.aa.bb..
nnnmli..
hhgggf..
nk.mliii
jkmmllhh
hhhggfff
jkkgfffh
eedddccc
jjegddfh
cceggdb.
eeebdca.
.ceeadb.
.caaabb.
..fffe..
..ddcc..
.dfeeec.
.db..ac.
.bd..ca.
ddb..acc
.bb..aa.
iiih....
.gihhh..
.ffeed..
fgggedd.
ffeeddd.
f.c.e.d.
c.c.d.d.
ffcee.d.
cccbb.a.
.ccb.aaa
.cbb.aaa
...bbb.a
...bba.a
gggfe...
dddcc...
gfffed..
.c.eed..
.d.ccb..
bc..add.
aa..bbb.
bcc.aaa.
aaa.bbb.
gggeee..
g.ff.e..
d.dc.c..
.ddfc...
..dfc...
..d.ccb.
..b.baa.
..bba.a.
....abb.
gggddd..
gf..ed..
dd..cc..
cff.....
cccb....
lllkj...
lkkkji..
.hhjjiff
.ffeeecc
ggh..iif
ddd..ccc
geh..ddf
gecccbd.
ddaabbb.
.eeacbd.
.aaabbb.
.aaa.bb.
ggg..e.d
ddd..b.b
g.feee.d
d.cccb.b
fff.ccdd
ddd.cbbb
..bbc...
..ccc...
..b.c...
..a.a...
..b.a...
lllihg..
lk.ihggg
ff.eeddd
jkiihhff
jkk..eef
jjcdddef
ccaaabbb
cccdb.ea
cccaa.bb
d.c.....
bbc.....
.bcc....
.b.a....
.a.a....
llkk....
jlkk....
jjikfffe
jjiiffee
jhiigfee
hhigggde
hhggddcc
chbbbddd
ccab....
caaa....
jjjhg...
jiihh...
ijhhgg..
jjiihh..
iifhge..
gjffee..
iffdeee.
ggdffee.
.cfddb..
.gddcc..
cc.dbbb.
bb.dacc.
jjji.g..
hggg.e..
hjiiggf.
hhggfee.
hh.iegff
hh.ffeed
hd.ee.fc
cc.ff.dd
dd.be.cc
cc.bb.dd
.d.bb.ac
.c.bb.aa
......a.
hhgg....
.j.iih..
.h.gff..
gggifhh.
.geffhd.
.dddffe.
.eeefdd.
.dcdcee.
..cbbbd.
..cccbb.
..ccba..
..aaab..
..c.aaa.
..a.abb.
jjik....
jhiigfff
hhigggfe
dh....ee
ff....cc
ddcaaabe
bbbaaacc
dcccabbb
jjjfff..
hhhfff..
.jigf...
.ghfe...
.iigg...
.higeee.
.gggeee.
hhhdce..
..dbac..
..bdca..
.jhii..e
.hhgg..d
.hhig.ee
.fheg.dd
.fhgggde
.ffeeddc
ffcbbbdd
bbffeecc
.fccbad.
.bbaacc.
..c.aa..
..b.aa..
dfee....
ddce....
.bc.....
lllji...
hhhff...
kljjiih.
gghfeee.
kkgjihh.
ghhfffe.
kgg..fh.
ggg..ee.
.eg..ffd
.eecbfdd
.dbbbaac
.eccbbad
...bbaaa
eee.c...
ddd.c...
.edcc...
.dccc...
.dd.c...
.db.c...
..d.....
abbb....
.jhii.b.
.hhgg.b.
.hhia.bb
.hfga.bb
.ghaacb.
.ffaabb.
.ggfacc.
.effaac.
.gfffcd.
.eeedcc.
..eeeddd
..edddcc
...e....
...d....
lllk.ji.
hhhg.ff.
.lkkjjii
.hhggfff
hhhkgji.
ehgggfd.
fhe.ggd.
eee.cdd.
ffeegddd
eecccddd
fcebbb..
bbbcca..
.cc.ba..
.c..aaa.
.b..aaa.
.hjii...
hh.gifff
hh.fggee
.hgge.f.
.ddff.e.
.d.geec.
.d.ccee.
dddbe.cc
ddbbc.aa
...bbac.
...bcca.
...baaa.
llliii..
.lkjifff
.hggfeee
.kkjjhf.
..kjghh.
..gggee.
cccggh..
bbbddd..
.cdegaaa
.bccdaaa
.ddeeba.
.bbcdda.
..debbb.
..cccaa.
lllk...h
hhgg...f
.ljkkihh
fjjkiigh
dhhggffe
ffj..igg
ddd..eee
fed..cg.
cdd..ee.
eeddbcc.
cccbbaa.
.edbbca.
....baaa
ggg.....
.gfeddd.
.ffeedc.
..febccc
..cccbbb
..e.....
.eee....
.ddd....
.cd.b...
ccddbb..
.ca.b...
.eddd...
eeedca..
bbccca..
bbbccaa.
bbbcaaa.
.b..ca..
.b..aa..
lllk.j.i
hhgg.f.f
hhhk.jgi
hhgg.efe
.h...ggg
.d...eee
fff...e.
ddd...e.
dfc.beee
dcd.bbaa
d.c.baaa
c.c.bbaa
.g......
ef......
eddccba.
..dcbbaa
.....ba.
hhhfe...
ghffee..
gg.fed..
dd.ccc..
gcb.dd..
bbb.aa..
.cbaaa..
hhhg.f..
dddc.c..
.hggff..
.ddccc..
eeegdf..
cebddd..
ccbba...
c.baaa..
.jjii...
.jjhh...
.jjiihh.
.ijjhhg.
ggff.hh.
fiie.gg.
ggffee..
ffieeg..
dd..ee..
df..ec..
dd.aacc.
.dbbaac.
ddaa....
..ee....
..dc....
..ba....
llkk..gg
hhgg..ee
fhgggeee
jjiihhff
fffddcce
eeddccff
ffdddccc
eeddcc..
bbbadc..
.baaa...
.hhff...
.hggf...
hhegff..
eeeggd..
eccddd..
bbcdaa..
.bcca...
iiff....
ffdd....
iiff..dd
ffdd..cc
effddccc
hhggee..
eeebbc..
.ee.bb..
gg.dd...
dd.cc...
ffeecc..
eeggdd..
ee..dd..
bb..aa..
.jji.hh.
.hhf.ee.
ghhffeed
ffieeggd
gghffedd
cffbeedd
ggcccbdd
ccbbaad.
aaaccbb.
.cb..aa.
.jj..hg.
.hh..ee.
fii.heeg
ghh.feed
ff.dd.ee
gg.ff.dd
.fddc...
.ccbb...
..bbcc..
..cbaa..
.bbaac..
.ccbba..
lljj....
klljjii.
hhggfff.
kkhhiig.
.kfhhgg.
.eeeddd.
.ffeegd.
.fcceedd
.hggg...
jj..ii..
fh..ge..
fhhhge..
eedd..c.
cccb..d.
.ebddcc.
.acbddd.
.acbbb..
.jji....
.hgg....
jjhii.c.
fhhgg.c.
gghhidcc
ffhhgccb
.gghddbc
.ffeccbb
.effdbb.
.ddeebb.
aeeffb..
ddaaee..
aae.....
daa.....
dffee...
ddccb...
dddcbb..
.daccbb.
.iih....
iihhffe.
g.hff.ee
e.ffd.dc
gg.bbdde
ee.aacdc
.gc.bbdd
.bb.accc
.caa....
.bbb....
.jj.hh..
.hg.ff..
jjihhgg.
.fiieegg
.hhgefdd
.ffidee.
.cceedd.
..fddcc.
..cceed.
..bdcc..
..bb.aa.
.iihgg..
.feeed..
ii.hhgg.
ff.eedd.
ffeehdd.
.ffeecdd
.cbbbaaa
bbaa..c.
cccb..a.
.hhf....
gghfff..
.gihhf..
.ghhef..
.ggeeff.
.ggdeee.
.dgceef.
.ccddde.
.ddccb..
.cbbad..
aad.cbb.
ccb.aaa.
.aa...b.
.bb...a.
.llk....
.hhh....
lljkk...
gghff...
.ijjkgg.
.ghhfee.
hiijggf.
gggfffe.
hhideeff
dddcceee
.hcddeef
.dbbcaaa
bbccdaa.
ddbccca.
.bbc..aa
.bbb..aa
.iihg...
.ffdd...
eeffdd..
ffheeg..
.ffdeec.
.eeccbb.
...ddbcc
...cccbb
....dbbc
....acbb
....aab.
..ggf...
..ddd...
.ccdd...
.eefd...
eec.dd..
ccc.bb..
.ccbbd..
.caabb..
.ffee...
iihhggd.
fffeeec.
.fh.egdd
.fd.eccc
.ffeeccd
.dddbbcc
..feccb.
..ddbbb.
.....abb
.....aab
....ccbb
.ddee...
.cddbb..
.bbbaa..
.ggdd...
gg..dd..
.ffeecc.
.hhgf...
eegddf..
ceebdd..
.cbaa...
jjj.fff.
jjj.eee.
jijiefef
.hii.gee
.iii.fff
.hhigg.e
.hhggd.d
dhh.ggcc
cch.gddd
ddbbaacc
chhggbbb
ddbbaa.c
ccaaab.b
lllkkjjj
llikkjjh
ggiikfhh
ggiiffhh
egddffcc
eeddb.cc
cccee.bb
eedbbaac
cccaaabb
...aaabb
gg.edd..
gf.ddd..
gfcccd..
ffeecd..
efffcd..
fbbcc...
ebbbc...
bbbcc...
eeeba...
hhhgf...
eeggff..
eedddc..
.eddccb.
.eeccdd.
....cbba
....aabb
eddd....
ddee.b..
eeed.b..
ddc.bb..
.dccbb..
.ccbbb..
..cc....
..ca....
eded....
eeed....
ddcbbb..
d.ccbb..
c.cbaa..
..ccaa..
..cbba..
hhh.g...
.hhgg..c
.hggg..d
ff.ggdcc
fh.egddd
ffeeddcc
fffecccd
f.eedd..
f.eeec..
...e.bb.
...b.ca.
...aabb.
iiih.f..
iihh.f..
.iihhff.
gg.hhff.
gi.hffe.
gge.ddd.
ggg.dee.
.geeddcc
.gdddcee
..eebbcc
..bdaccc
.aaabbc.
.bbaaac.
..aa.b..
..bb.a..
fffd.cc.
eeed.cc.
ffeddcc.
eeddccc.
.eedd.c.
.eddd.c.
bee.....
ab......
hhh.gg..
.hhggg..
.hgggf..
ffe.ddd.
ehh.gff.
eeeddc..
fceebbaa
bbedaccc
.ccbbbaa
.bddaaac
.cc...a.
fff.e...
eed.d...
ddceeb..
eeecdc..
.baaac..
.bba....
eed.....
ffeed...
eeddd...
.ceedd..
.eeddc..
.cceddbb
.bbaaccc
.bbbaacc
gggfeee.
eedddcc.
gg.ffee.
ee.ddcc.
dddffccc
bdd..acc
bb...aa.
cccbeddd
dddbeccc
.dbbbac.
ff.cc...
ee.cc...
fffccc..
.edddb..
.eddcb..
.eeddbb.
.dddbbb.
.ee..bb.
.ad..bb.
eeedd...
ggffeecc
eeedddbb
.dffeecc
.ecddbbb
.cccaabb
.ddbbaa.
.cccaaa.
eee.....
.fffe.cc
.eedd.cc
bbddeecc
bbdddccc
bbddee.c
bbbaac.c
b.d.aa..
b.b.aa..
.gggf...
.eedd...
eggdff..
eeeddd..
eeddff..
eeddc...
bbccc...
.bbcc...
hhhgg...
.eeeff..
.eeddd..
ddeeff..
dcccbb..
ccaabb..
..aab...
hh.f.e..
ee.d.d..
cccddd..
gdd.c.b.
ccc.a.a.
dddccbb.
cbcbaaa.
.aaccbb.
a.b.....
fefedd..
edeccc..
.eee.d..
.ded.c..
ccbbdd..
bdddcc..
f.fee...
f.eee...
dd.eecc.
fd.eccc.
.d...c..
ddbb.cc.
dddb.ca.
f.feee..
fffeedd.
.cccddd.
.ccbbaaa
..bbba.a
..ccbb.a
.ddc....
.d.dcc..
.d.ccc..
bb...c..
dd...c..
b...cc..
b...aa..
bba.a...
e.ddd...
d.dee...
e.edd...
.c.cbb..
.c.bbb..
.cccb...
.ccab...
fff.dd..
eed.cc..
fefedcc.
.eeeddc.
.....cc.
.....bb.
.....bba
.gggccc.
.eeebbb.
.g.gc.c.
.e.eb.b.
eeffddbb
ddeebbaa
e.f..d.b
d.d..a.a
dddccaaa
...c.c..
...ccc..
.ef..db.
.dd..aa.
gggccc..
eeebbb..
g.gc.c..
e.eb.b..
f.fddbb.
e.ebaba.
fff.d.b.
ddd.a.a.
eeeddbb.
dcccaaa.
eaea....
.ccc....
eeeggddd
eeeccddd
bbbccaaa
ddccc...
bb.cc...
bd.ac...
bbaaa...
hhggg...
fffggeee
fhhggedd
.efdccc.
.eeeccc.
.eeebbc.
.dd.....
.dddcc..
.bdccc..
bbbac...
ggg..ccc
fff..ccc
.ff..ccc
.fe..ccc
...eedd.
...bdda.
hhheee..
.ggffdd.
.ffddcc.
bbccaa..
.dfeccc.
.dfebac.
.cfbead.
.dddbac.
f..d.c..
e..c.c..
fe.d.c..
ee.d.c..
.e.cccb.
.d.dbbb.
.eee..b.
.ddd..b.
...abbb.
.hggg.d.
.hhgg.e.
fhgeeed.
hhfgeee.
f.geddd.
d.fffec.
fffeaccc
dddfaccc
.dbaac..
bd...c..
b...ac..
gf..ddd.
ee..ccc.
gf.eeed.
ee.dccc.
.fffced.
.dddbbc.
.bbbce..
.dddbb..
..abccc.
..aabbb.
..ab....
g....e..
e....d..
gfffde..
..cfd...
.bcfddda
.bccc..a
.bbb.aaa
.hh.....
.hg.....
heeggff.
ehhgfff.
ddeegcf.
eeedccf.
.dde.cc.
.edd.cc.
..dbaacc
..bddcaa
fdecc...
eeedc...
bdd.cc..
bbb.cc..
bbddac..
bbaccc..
..dd....
.ccd....
.d.cc...
.c.dd...
bb..cc..
cc..bb..
.bb.a...
.aa.b...
..abb...
.ff.cc..
.ee.cc..
ddeeccc.
fbeeddc.
ddeebbc.
abbeed..
addbbb..
aabb....
aaab....
..ff....
.deee...
ddde....
dde.cc..
.cccbbb.
.aacbb..
.ccaab..
.gg.....
.ee.....
ggee....
gffeebb.
..ffecbb
..dddbbb
.d.fccab
.c.cabab
.ddccaa.
..ddaa..
.ggfe...
gffddeec
eeccddbb
..ddbbcc
.adbbcc.
.aab....
hgggfff.
hhfggee.
hghgfee.
hffggge.
ddd.eee.
cccbadd.
ccdbbba.
cddbaba.
cbbbaaa.
hhhg..f.
hhhf..e.
hhgg.ff.
hhff.ee.
hgggfffe
ghfffeee
ddd...ee
ggg...dd
dd...eee
gg...ddd
dcbbbaaa
cccbaaad
.cccba..
.cbbba..
hhh....f
.hhgggff
.hgggfff
.ehggfff
.hhgefef
.eegddd.
.dggeee.
.eeecdd.
bbbccad.
bdbdcaa.
bbcccaa.
bbbccca.
b....aaa
feeed...
ccc.dd..
ddd.cc..
.cc.ddd.
.dd.ccc.
..cbaaa.
..bbaac.
...bbba.
ggg.eee.
gg..eed.
ff..edd.
gfffedd.
.bffdddc
.beeeccc
.bbf..cc
.bbb..cc
.bbbaccc
ccddb...
..bbaa..
..aabb..
hghgfff.
hhggeee.
hgggfef.
fhgggee.
ddd..efe
fff..edd
dcd..eee
ffc..ddd
.cdcbaaa
.ccbbbad
.cccbaba
....bbba
..dcc...
ccd.d...
c.dbbb..
d.dccc..
bbba.a..
.a.abb..
.b.aaa..
hhhggff.
hgggf.fe
eehgg.ff
eee..dff
cce..ddd
.ccbbadd
...dc...
...dd...
.dddc.c.
.cddb.b.
bbb.ccc.
ccc.bbb.
c.caab..
hghfef..
hg.gefe.
.dbdcac.
..bdbaca
d.dbbb..
c.cbbb..
dccc.b..
cccb.b..
...cbb..
...bbb..
.acc....
fffec...
fffdc...
feeeccc.
efddccc.
dddecb..
.d...b..
.e...b..
f....ccc
e....ccc
fffdddc.
feeed.c.
eeddd.c.
..e.d...
..b.d...
..eb....
..bb....
b.a.....
f....d..
f.eeedc.
e.edcdc.
..beccc.
..bbccc.
..bea.c.
g..eee..
e..ddd..
gggfed..
eeeccd..
...fdddc
...ccbbb
..bbbccc
..ab...c
..aa...b
.cddd...
.dddc...
.cdbbb..
cccab...
.f.ee...
.e.dd...
fffdeecc
fdddecc.
eeebdcc.
..db..c.
..bb..c.
efff....
fdee....
eeef....
dddee...
ddecc...
.cdbb...
.dbbc...
cccabb..
addbcc..
caaab...
aaabb...
ff......
ee......
dddec...
cccdd...
bb.ca...
cc.ab...
.fee....
.eed....
fffeed..
f.cedd..
e.ccdd..
..cccdd.
...cbba.
...acbb.
.f.dd...
fffedd..
feeedcb.
eeccdbb.
..ecccbb
...caab.
fff.ed..
eee.dd..
f.eeedd.
e.eccdd.
..cedd..
..ccdd..
b.ccc...
b.bcc...
bbbca...
.g.ee...
gggfee..
gfffec..
eeeddb..
.dfcccb.
.dddcbb.
..d..abb
..c..aaa
..g.f...
..e.e...
ddeeecc.
.gdfceee
.ddeeccc
dddccc.e
dddbbc.c
.dbbac..
hhhggg..
.hhggeee
.hffgee.
..fffde.
.cfddd..
.ccbdda.
.dbbcaa.
dddbcca.
hhggf...
heegfff.
eee..df.
eee..dd.
.ce..ddd
.ee..ddd
.cccbdda
...bbbaa
...cbbaa
gggff...
gefffa..
fffeea..
.eeefaaa
.ddeeaaa
.ee..aab
.dd..aaa
.dddcbbb
..ddccbb
..dccc..
..cccb..
.hh..ff.
.hhhgfff
.hhhfeee
dddgg.ee
gggff.dd
.ddaaeee
.ggbbddd
.dbaaac.
.cbbbad.
bbbaccc.
.bb..cc.
.cc..aa.
.dd.cc..
.cc.dd..
dddbac..
gg.bbb..
ff.bbb..
gggbbc..
fffbbb..
gf..bcc.
ff..bcc.
.fffccc.
.ffeddd.
.aeedd..
.aeddd..
aaeeed..
aaaddd..
gg..ee..
ff..ee..
gggeeed.
g.fffedd
f.feeedd
c.ffbddd
c.cbbddd
cccfbb..
ccabbb..
ccabab..
dd.bbb..
cc.bbb..
dcccb...
cccbb...
ede.....
.eddb...
.ddda...
eecdbbb.
cdcdaaa.
cccddab.
cccbaba.
c..aaa..
c..bbb..
...b....
ccedd...
ccddd...
.ceedaa.
.ccddaa.
.....b..
ffgee...
.fddecc.
..bddacc
....b..a
eeefd...
..ecddd.
..cddbb.
.bbcccd.
.baa.c..
.acc.b..
..fd....
fefdcdc.
.ebebaca
.ebbccaa
..fe....
eefffd..
fdfecec.
.eccddb.
.dbdbaca
.cccabbb
..caaabb
.b.b....
g.g..ddd
f.f..ddd
gfffe.dd
ffeee.dd
bbf.eecc
bbe.eccc
.bffaac.
bbb.accc
bbb.aacc
..fff...
.gggfff.
.eeffdd.
.geedff.
cceeddd.
eeecddd.
.cccabb.
..bbaaa.
..aaabb.
.fffed..
.fffdd..
.feeeddd
.efdddcc
cceebbdd
eeebdccc
cccaabb.
eebbbac.
..caabb.
c.ddbb..
c.cddb..
.ccaa.b.
.caab.b.
gggffee.
.dgffeec
.fcceddd
.ddd.ccc
.ccc.ddd
..dd.cc.
..cc.bb.
.gg..dd.
.ff..dd.
gggf..dd
ffee..dd
geefffdd
..eeff.c
..eeec.c
..ee.ccc
..bb.ccc
.aabbcc.
.ggee...
gfffee..
dffcc...
dddccaa.
cccddaa.
.ddbccaa
.ddbb...
acc.....
efdddc..
eefddd..
eeedddcc
eebbdccc
..bbbacc
..bbbaa.
.eecc...
deecc...
ccdbdb..
dddbbb..
cacabb..
..ddc...
.ccddbb.
hhh..fff
hhh..eee
hhhgggff
hgggfefe
heeeggff
hhhgfefe
.eeeggd.
.eccddd.
bbccddda
bbbdcaaa
bbcccaaa
bdddccca
.cddbbb.
cccaab..
b.baa..."""
    data2="""1 3 1 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3
1 7 4 2 1 2 2 2 3 3 3 3 3 3 3 3 3 3
1 11 4 2 5 6 3 3 3 3 3 3 3 3 3 3 3 3
1 15 7 2 4 2 5 6 3 3 3 3 3 3 3 3 3 3
1 23 7 2 8 6 2 2 3 3 3 3 3 3 3 3 3 3
1 27 9 6 5 6 3 3 3 3 3 3 3 3 3 3 3 3
1 30 7 2 8 6 10 10 3 3 3 3 3 3 3 3 3 3
1 31 11 2 9 6 5 6 3 3 3 3 3 3 3 3 3 3
1 47 12 6 13 10 5 6 3 3 3 3 3 3 3 3 3 3
1 63 14 6 9 6 5 6 3 3 3 3 3 3 3 3 3 3
1 79 11 2 7 2 15 16 3 3 3 3 3 3 3 3 3 3
1 94 11 2 9 6 17 18 3 3 3 3 3 3 3 3 3 3
1 95 19 2 12 6 15 16 3 3 3 3 3 3 3 3 3 3
1 111 19 2 20 21 15 16 3 3 3 3 3 3 3 3 3 3
1 121 22 16 23 10 10 10 3 3 3 3 3 3 3 3 3 3
1 122 11 2 24 16 10 10 3 3 3 3 3 3 3 3 3 3
1 123 19 2 22 16 5 6 3 3 3 3 3 3 3 3 3 3
1 124 12 6 13 10 17 18 3 3 3 3 3 3 3 3 3 3
1 125 14 6 25 10 15 16 3 3 3 3 3 3 3 3 3 3
1 126 19 2 22 16 17 18 3 3 3 3 3 3 3 3 3 3
1 127 26 2 27 16 15 16 3 3 3 3 3 3 3 3 3 3
1 186 28 10 24 16 10 10 3 3 3 3 3 3 3 3 3 3
1 187 14 6 24 16 10 10 3 3 3 3 3 3 3 3 3 3
1 189 14 6 29 18 5 6 3 3 3 3 3 3 3 3 3 3
1 191 30 6 22 16 5 6 3 3 3 3 3 3 3 3 3 3
1 239 30 6 20 21 15 16 3 3 3 3 3 3 3 3 3 3
1 247 30 6 31 18 15 16 3 3 3 3 3 3 3 3 3 3
1 254 30 6 22 16 17 18 3 3 3 3 3 3 3 3 3 3
1 255 32 6 27 16 15 16 3 3 3 3 3 3 3 3 3 3
1 367 33 21 20 21 15 16 3 3 3 3 3 3 3 3 3 3
1 381 34 16 25 10 15 16 3 3 3 3 3 3 3 3 3 3
1 383 35 21 27 16 15 16 3 3 3 3 3 3 3 3 3 3
1 495 36 16 20 21 15 16 3 3 3 3 3 3 3 3 3 3
1 511 37 16 27 16 15 16 3 3 3 3 3 3 3 3 3 3
3 7 38 5 5 5 5 5 3 3 3 3 3 3 3 3 3 3
3 11 39 40 41 42 43 44 45 46 34 47 48 49 24 50 51 52
3 15 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68
3 23 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84
3 27 85 86 30 86 30 38 12 38 12 87 8 87 8 6 6 6
3 30 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 102
3 31 103 104 105 106 5 87 3 3 3 3 3 3 3 3 3 3
3 47 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122
3 63 38 6 5 6 5 6 3 3 3 3 3 3 3 3 3 3
3 79 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138
3 94 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154
3 95 155 156 157 158 159 160 161 162 163 164 165 166 167 168 3 3
3 111 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184
3 121 185 186 187 188 189 190 191 192 193 194 195 196 197 198 68 199
3 122 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 214
3 123 215 16 216 18 10 10 3 3 3 3 3 3 3 3 3 3
3 124 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232
3 125 233 234 235 220 236 237 238 239 240 241 242 243 244 245 246 184
3 126 247 201 248 203 249 250 251 252 253 254 255 256 257 258 259 153
3 127 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275
3 186 276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 290
3 187 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306
3 189 247 201 248 203 307 308 309 310 311 312 313 314 315 316 317 317
3 191 318 319 320 321 322 323 324 325 326 327 328 329 330 331 3 3
3 239 332 87 333 334 335 336 337 6 338 21 51 16 3 3 3 3
3 247 332 87 339 340 341 336 9 6 342 18 51 16 3 3 3 3
3 254 332 87 46 336 343 340 337 6 15 16 17 18 3 3 3 3
3 255 86 6 15 16 15 16 3 3 3 3 3 3 3 3 3 3
3 367 344 336 277 68 22 336 22 16 68 199 51 16 3 3 3 3
3 381 345 346 347 348 349 350 351 352 353 354 355 356 357 358 3 3
3 383 42 336 359 340 360 336 20 21 15 16 15 16 3 3 3 3
3 495 42 336 361 334 27 336 362 16 338 21 51 16 3 3 3 3
3 511 363 336 45 336 34 336 48 16 24 16 51 16 3 3 3 3
7 11 364 47 15 49 15 50 15 52 3 3 3 3 3 3 3 3
7 15 365 366 367 368 369 370 371 372 373 374 375 376 377 378 16 16
7 23 379 380 381 382 381 383 384 385 386 387 386 388 389 390 391 391
7 27 392 393 394 393 394 395 396 395 397 398 399 398 400 401 402 401
7 30 403 404 405 406 405 407 408 409 410 411 410 412 413 414 415 416
7 31 417 418 419 420 419 421 422 423 424 425 426 427 428 429 430 431
7 47 432 433 434 435 436 433 437 438 439 440 441 438 442 184 443 444
7 63 432 445 446 445 446 445 447 448 449 448 449 448 24 16 16 16
7 79 432 450 451 452 446 453 454 455 456 457 458 459 460 461 16 336
7 94 462 44 463 433 463 464 463 465 466 467 466 468 466 469 415 470
7 95 471 472 473 465 473 460 474 104 475 106 476 168 3 3 3 3
7 111 471 472 473 477 473 460 474 104 475 478 476 168 3 3 3 3
7 121 479 480 481 482 483 484 485 486 487 488 489 490 491 492 493 493
7 122 494 495 496 497 496 498 499 152 500 357 3 3 3 3 3 3
7 123 501 294 502 203 503 504 505 506 507 508 509 510 511 512 513 514
7 124 515 516 517 518 519 520 521 522 523 524 525 526 527 528 529 530
7 125 531 532 533 534 535 536 537 538 539 540 541 542 543 544 13 23
7 126 545 495 546 497 546 497 547 548 549 550 500 550 3 3 3 3
7 127 551 552 553 554 555 556 557 364 558 559 560 561 562 563 564 565
7 187 566 567 568 569 570 571 572 573 574 575 576 577 287 258 578 153
7 189 346 401 579 152 580 401 3 3 3 3 3 3 3 3 3 3
7 191 581 582 583 584 585 586 587 588 589 590 591 592 591 593 17 18
7 247 594 595 596 495 597 497 598 599 600 601 602 603 184 184 3 3
7 255 604 605 606 605 607 608 609 610 609 610 611 612 613 614 615 614
7 367 616 617 618 619 620 621 622 623 624 625 626 627 628 579 3 3
7 383 629 630 631 632 633 634 635 636 12 6 16 16 3 3 3 3
7 511 637 336 22 336 22 336 22 16 336 16 16 16 3 3 3 3
11 15 638 639 640 641 642 643 644 645 646 647 648 649 470 650 651 415
11 23 652 653 654 655 656 657 658 659 660 661 662 663 664 665 3 3
11 27 666 401 667 401 3 3 3 3 3 3 3 3 3 3 3 3
11 30 668 669 670 420 671 672 673 674 675 676 677 678 679 680 681 681
11 31 682 380 683 684 685 686 687 688 689 688 690 691 692 314 693 694
11 47 695 696 697 698 699 700 701 702 703 704 705 706 707 708 709 710
11 63 711 495 712 495 713 495 714 401 715 401 716 401 3 3 3 3
11 79 717 718 719 720 721 722 723 724 725 726 727 728 469 729 290 290
11 94 730 731 732 733 734 735 736 737 738 739 740 741 17 18 742 742
11 95 652 743 654 744 656 745 746 747 748 314 314 749 3 3 3 3
11 111 652 743 654 750 656 745 746 747 748 751 314 749 3 3 3 3
11 121 752 753 754 755 756 757 758 321 759 760 761 354 762 763 764 764
11 122 765 766 767 768 769 770 771 772 773 774 775 776 777 777 3 3
11 123 778 779 780 781 782 783 784 785 786 787 788 789 790 791 792 793
11 124 794 795 796 797 798 799 800 801 802 803 804 805 806 807 199 199
11 125 808 234 809 220 810 237 811 239 812 241 813 243 814 815 816 391
11 126 817 818 819 820 821 250 822 252 823 824 825 256 826 258 153 153
11 127 827 323 828 829 830 831 832 833 834 835 836 258 837 184 838 838
11 186 839 840 841 582 842 843 844 845 846 847 848 849 850 851 290 290
11 187 852 554 853 346 854 855 856 579 857 858 859 580 860 213 3 3
11 189 861 495 862 497 713 495 714 401 863 152 864 401 3 3 3 3
11 191 865 866 867 321 868 869 870 871 872 873 874 875 470 415 3 3
11 239 876 877 878 879 880 881 882 883 884 885 886 887 888 889 890 891
11 247 892 893 894 895 896 897 898 599 899 900 901 902 903 904 742 742
11 254 905 906 907 634 608 908 909 529 214 214 3 3 3 3 3 3
11 255 910 554 911 346 912 346 913 914 915 914 916 917 918 500 919 500
11 367 920 595 921 922 923 924 925 588 926 336 465 104 927 168 928 904
11 381 929 930 931 932 933 934 935 936 937 938 939 940 941 942 943 944
11 383 945 946 947 829 948 772 949 950 951 952 953 954 955 956 52 16
11 511 39 364 957 914 958 914 959 833 960 580 666 580 961 184 3 3
15 23 962 963 964 965 966 967 968 969 970 971 972 973 974 975 961 184
15 27 432 976 977 978 979 203 980 981 982 983 984 151 985 986 340 18
15 30 987 988 380 684 989 990 991 992 993 994 995 996 997 998 999 443
15 31 1000 1001 1002 420 1003 1004 1005 1006 1007 1008 1009 1010 1011 1012 791 1013
15 47 1014 438 1015 1016 1017 438 338 21 215 16 3 3 3 3 3 3
15 63 1018 142 1002 142 1019 142 1020 1021 1022 1021 1023 901 1024 1025 1026 1025
15 79 1027 1028 1029 1030 1031 745 1032 1033 1034 1035 1036 1037 1038 1038 904 904
15 94 1039 1040 1041 201 1042 1043 1044 1045 1046 1047 1048 1049 1050 469 290 290
15 95 1051 743 1052 744 1053 745 1054 1055 1056 1057 1058 1059 1060 168 3 3
15 111 1051 743 1052 750 1061 745 1062 1063 1064 1065 1066 1067 500 500 3 3
15 121 1068 1069 1070 1071 1072 1073 1074 1075 1076 1077 1078 1079 1080 1081 3 3
15 122 1082 1083 1084 1085 1086 1087 1088 1089 1090 1091 1092 1093 184 837 3 3
15 123 1094 1095 1096 1097 1098 1099 1100 1101 1102 1103 813 1104 628 1105 1106 1107
15 124 1108 1109 1110 1111 1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 729 1122
15 125 1123 467 1124 1125 1126 914 1127 1128 1129 1130 415 651 3 3 3 3
15 126 1131 818 1132 820 1133 203 1134 1135 1136 1089 1137 1138 1139 1140 1141 1142
15 127 1143 1144 1145 1085 1146 1147 1148 1149 1150 1149 1151 1152 1153 628 1154 628
15 187 1155 1156 1157 579 1158 1159 1160 493 1161 1161 3 3 3 3 3 3
15 189 1162 433 1163 1164 1165 1166 1167 1168 1169 1170 1171 1172 1173 1174 3 3
15 191 1175 1176 1177 914 1178 1179 1180 1181 1182 1183 87 6 3 3 3 3
15 239 1184 914 1185 1186 1187 467 1188 331 1189 1190 198 1191 1192 391 3 3
15 247 1193 914 1194 1195 534 467 1196 336 1197 106 729 469 415 415 3 3
15 255 1198 556 1199 346 1200 1201 1202 1203 1204 1203 1205 1206 1207 1208 1209 1209
15 367 1210 1211 1212 1213 1214 1215 1216 1217 1218 1219 1220 1219 415 415 3 3
15 383 1221 346 1222 1223 1224 1021 1225 352 1226 1227 1228 1229 500 358 3 3
15 495 364 336 1230 334 1231 336 1232 904 1233 1234 904 904 3 3 3 3
23 27 392 1235 1236 1235 1237 1238 1239 1238 1240 1241 1242 1241 1243 106 1244 106
23 30 1245 1246 1247 1248 1249 1250 1251 1252 1253 1254 1255 1256 1050 469 764 764
23 31 1257 1258 1259 1260 1261 1262 1263 1264 1265 1266 1267 1268 102 102 1269 1269
23 47 432 1270 1271 1272 1273 1260 1274 1275 1276 1277 1278 1279 1280 1281 1282 1283
23 63 392 1270 1236 1270 1284 1270 1285 829 1286 829 1287 1288 1289 1290 1291 1290
23 79 1292 1293 1294 1295 1296 1295 1297 1298 1299 914 1156 1300 1301 1300 628 628
23 94 432 1270 1302 1303 1304 1305 1306 1307 1308 1309 1310 1311 1312 1313 838 838
23 95 453 472 1314 465 1315 460 47 336 1316 340 340 216 17 18 904 904
23 111 1317 1318 1319 1320 1321 1322 1323 1324 1325 1063 1326 1327 1328 1067 974 1329
23 121 1330 1331 1332 1333 1334 1335 1336 68 1337 1337 51 16 2 2 3 3
23 122 432 1270 1338 1339 1340 1341 1342 1343 1344 1345 1346 1347 1348 1349 1350 1351
23 123 1352 1353 1354 1355 1356 1357 1358 1359 1360 1361 1362 1363 1364 213 1365 1366
23 124 1108 1109 1367 1111 1368 1369 1370 1371 1372 1373 1374 1375 1376 1377 1378 316
23 125 1379 1293 1380 1381 1382 222 1383 1384 1385 1386 1387 1388 1389 1390 1391 1392
23 126 1393 1394 1395 1355 1396 1397 1398 1399 1400 1401 1402 1403 1404 152 1405 317
23 127 1406 364 1407 151 1408 151 1409 1410 154 153 259 153 391 391 3 3
23 186 1411 1336 1412 1413 1414 1414 1415 634 1414 1416 904 904 199 199 3 3
23 187 840 25 637 364 1417 467 1418 1419 1420 1421 1422 1423 3 3 3 3
23 189 1424 1425 1354 1355 1426 1427 1428 1429 1430 1431 1432 1433 694 1403 1434 1435
23 191 1436 25 1406 364 637 364 1437 38 103 1197 1438 329 1439 500 1440 214
23 255 1441 1176 1442 914 1443 1444 1445 1446 859 580 1447 258 3 3 3 3
23 383 1448 1449 1450 1451 1452 914 1453 580 1454 512 1455 1128 3 3 3 3
27 30 1456 1457 1458 1459 1460 1461 1462 1463 1464 1465 1466 1466 1311 1467 340 340
27 31 445 472 445 465 448 1468 448 104 6 87 6 87 3 3 3 3
27 63 38 87 38 87 87 87 87 6 6 6 6 6 3 3 3 3
27 79 1469 1470 1469 1470 438 914 438 580 742 1471 742 1471 3 3 3 3
27 95 433 472 433 465 465 460 465 104 106 106 106 168 3 3 3 3
27 111 433 472 433 477 465 460 465 104 106 478 106 168 3 3 3 3
27 123 1235 471 1472 1473 142 1474 1475 1476 1477 1478 1479 1480 469 469 469 1481
27 124 1456 1482 1456 1483 201 1484 201 1485 1479 1486 1479 1487 469 1488 469 469
27 126 1489 1490 1491 1492 773 1493 1494 1495 212 1496 212 1142 742 742 742 742
27 127 1497 1498 1497 1498 1499 914 1499 580 213 213 213 213 3 3 3 3
27 255 292 1195 201 914 1500 914 1501 1502 401 580 401 580 3 3 3 3
27 511 766 914 766 914 495 914 495 580 401 580 401 580 3 3 3 3
30 31 1503 1504 142 1505 1506 1507 1508 1509 1510 1511 1512 986 3 3 3 3
30 47 1513 1514 142 1507 1515 1516 1517 1518 1519 1520 1521 1522 1523 1524 153 153
30 63 1525 1270 1526 1527 1528 1527 1529 1530 1531 1530 1532 563 680 563 317 317
30 79 1456 1533 1534 1535 201 1536 250 350 1537 1538 1539 1540 1523 1541 928 904
30 94 1542 1543 1544 1545 1546 1547 1548 1549 1550 1551 1552 1553 1554 1555 10 10
30 95 433 472 1556 1557 438 1558 1559 1208 742 742 764 764 3 3 3 3
30 111 1560 138 1561 192 1562 1563 1564 1565 1566 1567 1122 1481 1568 1569 3 3
30 122 1570 1571 1572 820 1573 1574 1575 1576 1577 1578 1579 1522 1580 1580 837 961
30 123 1581 1582 1583 1584 1585 321 1586 1587 1311 152 1588 1589 3 3 3 3
30 124 1542 1590 1248 1591 1592 1593 1594 1595 1596 1597 1598 1599 1600 1601 1602 1603
30 125 1604 1605 1606 1607 1608 1609 1610 1611 1612 1613 1614 1615 1616 1617 1618 1619
30 126 1620 1621 766 1622 1623 1622 1624 1625 1626 1627 1628 1629 1630 391 214 214
30 127 1631 1632 567 1633 1634 1633 1635 1636 1637 593 1638 592 18 18 3 3
30 187 1620 1639 1640 1641 1642 1643 1644 1645 1646 1647 1648 530 1649 529 1269 1269
30 189 1621 467 495 438 1625 151 1650 317 214 214 231 231 3 3 3 3
30 191 567 467 1462 914 1651 467 1652 1653 152 628 1312 1313 3 3 3 3
30 247 1654 467 1655 1195 1499 914 1656 628 213 213 1580 1580 3 3 3 3
30 255 1657 467 201 914 1658 914 1659 580 401 580 1660 469 3 3 3 3
31 47 1661 1662 1238 1663 1664 1665 1666 1667 1668 1669 1670 1671 1672 1673 1220 1219
31 63 1674 142 1675 142 1676 142 1677 772 1678 772 1679 1680 1681 1682 1329 1683
31 79 1406 1406 1684 1685 495 1686 1687 1688 1689 1690 1691 1692 1107 1106 415 415
31 94 1693 1040 201 201 1694 1043 1695 1045 1696 1697 1650 1698 1699 317 391 816
31 95 453 1700 433 445 1701 1702 1703 1636 1704 1705 1706 1707 1107 1107 184 184
31 111 453 1700 433 1708 398 1709 1710 634 1711 1712 1713 1714 184 184 3 3
31 121 1715 1715 1716 1717 1718 1719 1720 1721 1722 1723 1724 1725 1726 1378 198 942
31 122 1727 1728 1729 1729 1730 1731 1732 1733 1734 1735 1736 1737 1738 1739 1740 1741
31 123 1742 1743 1744 1745 1746 1747 1748 336 87 87 87 1749 16 16 6 6
31 124 1750 818 1751 1752 1753 1754 495 1755 1756 1757 1758 1759 1760 1603 3 3
31 125 1761 1762 1639 1417 1763 1764 438 833 1704 1765 904 1766 742 742 3 3
31 126 637 1767 1768 1769 1770 1771 1772 1773 601 1774 184 837 3 3 3 3
31 127 1775 1776 1777 1778 1779 1089 1780 493 1781 1781 1781 1781 3 3 3 3
31 186 277 277 1639 1123 497 1157 1782 1783 152 1784 316 1378 838 838 3 3
31 187 1785 1786 1787 610 1788 1789 1790 1791 1792 1793 16 16 18 18 3 3
31 191 1175 1794 1795 1796 1797 1798 679 1799 1800 1801 259 153 3 3 3 3
31 247 1406 1802 395 445 1803 1804 1805 1806 1807 1808 1809 1810 184 184 3 3
31 254 1811 1812 1813 1814 1815 1045 1816 1817 1691 1691 1818 469 184 184 153 153
31 255 1819 1794 1144 1814 1820 1821 1822 634 438 634 1823 1824 1825 415 415 415
31 383 629 1802 1826 1827 1462 1814 1462 1828 1829 1830 1831 1832 1833 628 904 1569
47 79 336 336 334 1834 21 1834 16 16 3 3 3 3 3 3 3 3
47 94 336 50 478 106 904 1766 3 3 3 3 3 3 3 3 3 3
47 111 637 1802 1835 1836 1837 1838 1839 1840 338 334 448 168 444 444 184 184
47 121 1841 1842 453 453 1843 1844 1845 1845 1846 1847 1378 1378 1191 942 3 3
47 122 1848 1722 934 1849 1850 498 940 1851 1852 1853 3 3 3 3 3 3
47 124 1413 1854 1855 1856 1857 1858 1859 1860 1861 1130 415 651 3 3 3 3
47 125 1841 1862 453 1709 1863 1864 364 630 1865 1866 1867 1868 593 593 1234 1234
47 126 1869 1870 1871 1776 1872 207 1873 1874 1874 1874 530 1648 1875 529 231 231
47 239 1876 1877 1878 1879 1880 1881 1882 1883 1880 1884 444 1885 184 1886 3 3
47 247 1878 1879 1876 1877 1880 1881 1887 1888 1880 1884 184 1886 444 1885 3 3
47 367 1889 1890 1891 1892 1893 1894 1895 1896 1897 1898 1899 460 904 1900 3 3
63 95 1147 743 1147 744 1901 745 1902 747 1903 314 1903 749 3 3 3 3
63 111 1147 743 1147 750 1901 745 1902 747 1903 751 1903 749 3 3 3 3
63 123 1176 1176 1176 1904 1905 1906 1907 512 1907 1907 3 3 3 3 3 3
63 126 629 42 1819 1908 1909 1910 1909 1021 579 497 579 152 500 357 500 357
63 127 1193 584 1193 584 1656 1911 1656 1912 1656 1913 592 593 592 592 18 18
63 187 1914 1914 1451 1915 1451 1916 512 1917 512 1907 1107 1107 3 3 3 3
63 191 1406 637 1918 1919 1920 1921 497 1872 497 1530 1922 1923 500 500 500 500
63 255 1924 584 1924 584 1925 1926 1925 1912 1925 1912 1927 274 1927 580 1927 580
63 511 630 336 630 336 336 336 336 16 16 16 16 16 3 3 3 3
79 94 346 495 1928 497 1929 1930 1931 152 500 357 3 3 3 3 3 3
79 111 584 610 1932 1933 1934 1935 1936 1937 1938 1939 1940 1726 764 764 184 184
79 121 1569 1569 17 216 17 216 16 16 3 3 3 3 3 3 3 3
79 122 1605 1543 1941 1942 1943 1944 1945 1946 1947 1948 287 1949 1765 1653 23 23
79 124 1413 1854 1856 1856 1950 1858 1951 1860 1130 1130 415 651 3 3 3 3
79 127 1406 1802 1952 1953 1954 1955 1956 1957 1958 1959 1960 1961 1962 742 415 415
79 367 1184 1814 1963 1964 1965 1814 1966 1217 1967 304 1968 1968 1969 1969 3 3
94 122 1970 1971 201 1144 1972 1973 1974 1975 1976 1977 1978 1979 1580 1580 1603 1603
94 123 1639 1417 433 445 1980 1981 1982 1983 1984 1985 469 1481 742 742 3 3
94 124 1986 1986 1854 1987 1988 1989 1990 1991 1992 1993 651 1994 742 742 3 3
94 126 1995 1996 1744 1997 1998 1999 2000 2001 2002 2003 18 18 3 3 3 3
94 187 2004 1469 1639 2005 1314 2006 2007 1703 151 2008 2009 2010 1825 415 764 764
94 247 2011 2012 2013 445 2014 1897 2015 2016 2017 2018 2019 1801 2020 1713 3 3
94 254 2021 1812 1462 1814 2022 2023 2024 1410 2025 1833 2026 904 742 742 3 3
95 111 1095 2027 2028 2029 2030 237 595 2031 2032 2033 1510 2034 2035 327 3 3
95 123 2036 2037 2038 2039 2040 2041 2042 2043 2044 2045 2046 2047 152 152 2048 2049
95 125 2050 2050 2051 2052 2053 2054 2055 2056 2057 573 2058 2059 2060 2061 2062 2062
95 126 453 433 433 433 2063 1556 2064 2065 2066 2067 2068 2069 316 316 2070 316
95 127 2071 595 2072 2073 2074 869 2075 2076 2077 2078 2079 1774 153 153 391 391
95 187 1336 1336 1854 1413 1176 2080 833 634 258 1638 651 415 764 764 3 3
95 189 1470 1986 467 1633 914 1415 628 548 2081 2082 1106 1107 3 3 3 3
111 123 471 471 2083 2084 2085 2086 2087 2088 2089 2090 2091 2092 2093 563 2094 1405
111 125 1632 2095 2096 1331 2097 2098 763 2099 2100 2101 904 1766 3 3 3 3
111 126 471 1270 2083 2102 2103 2104 2087 2105 2089 2106 2091 2107 2093 1851 2094 317
111 189 1986 1986 2108 2109 2110 2111 2112 2113 1128 2114 1471 742 1107 1107 3 3
111 255 1293 346 2115 346 2116 1584 1298 1850 579 1850 2117 152 2118 500 500 500
111 495 364 630 2119 2120 2121 2122 2123 2124 2125 904 1234 1234 904 904 3 3
121 122 19 19 2126 2127 2128 2129 2130 1755 2131 2132 1079 1140 415 1825 199 199
121 123 2133 2134 2135 252 2136 2137 2138 2139 2140 2141 729 729 1106 1107 184 184
121 124 1 1 336 336 2142 1834 16 16 199 199 3 3 3 3 3 3
121 125 2143 1964 584 1814 2144 2145 2146 2147 2148 197 729 729 184 184 3 3
121 127 2149 2150 2151 1814 1177 2152 2153 2154 2155 1410 2156 2157 1962 742 904 904
121 186 1336 1336 2158 2159 2160 1916 2161 1917 1081 1481 764 764 3 3 3 3
122 123 2162 2163 2164 1149 2165 2166 2167 2168 331 331 1825 415 1107 1107 764 764
122 124 840 840 453 2169 2170 2171 2172 2173 2174 2175 2176 2177 2178 2179 199 199
122 125 2180 2181 1639 1417 1314 1709 2182 2183 1856 1866 2184 2185 258 593 1233 1234
122 126 2186 2187 2188 1814 2189 2190 2191 1279 2192 2193 1329 1683 259 153 3 3
122 186 68 68 1569 1569 17 216 16 16 10 10 3 3 3 3 3 3
122 187 2194 2163 2195 1814 2196 2197 2198 1410 2193 2199 184 184 290 290 3 3
122 189 840 28 2200 2201 2202 2203 2204 2205 2206 2207 2208 512 1423 1423 1107 1107
122 191 2209 2163 2210 1814 2211 2212 2213 2008 2214 2008 2215 2216 529 529 1269 1269
122 247 2217 2218 1611 2219 2220 2221 2222 2223 2224 593 258 592 1471 742 3 3
123 125 2225 1293 2226 1381 2227 222 2228 1384 2229 1451 2230 2231 1403 2232 500 500
123 126 1908 2233 2102 1527 2234 250 2235 2236 2237 2238 2239 680 1851 563 2240 2241
123 127 332 2180 2242 552 2243 2244 2245 2246 2247 2248 2249 2249 2250 1410 2251 2252
123 187 2253 1514 2254 2255 296 980 2256 2257 2258 2259 2260 2261 2262 327 2263 2264
123 189 1639 1639 346 495 1928 497 2265 2266 2267 401 628 152 2081 2081 3 3
123 191 2268 2269 2270 2271 2272 2273 2274 1912 2275 1347 2276 2277 2278 2279 16 16
123 247 2280 2281 2282 1849 2283 2284 2285 2286 2287 634 2288 2289 415 415 742 742
123 255 2290 2291 1558 634 2292 2293 2125 904 904 904 18 18 3 3 3 3
124 125 277 1411 637 1802 44 2294 2295 2296 2297 2298 2299 2300 2301 2302 764 2303
124 126 277 1411 637 1802 44 1767 2304 2305 2306 2307 2230 152 2240 2240 2308 2308
124 127 26 11 1406 1802 2309 1981 2310 579 1624 579 2311 500 500 500 2312 2312
124 187 840 28 2169 1709 2313 1769 2314 2315 2316 2008 2317 2318 52 16 18 18
125 126 2319 2319 584 584 2320 813 1912 1912 2321 2322 500 500 259 259 3 3
125 187 2323 2004 346 2324 2325 192 579 2326 2327 2328 500 2329 259 153 3 3
125 189 2330 2330 1569 1569 17 216 16 16 21 21 3 3 3 3 3 3
125 247 2331 2332 2282 1849 2333 2334 2335 2336 2337 1311 2338 2339 184 184 3 3
126 127 1631 2340 2341 2342 2343 2342 2344 2345 1576 2008 152 2346 2347 2348 470 415
126 187 2004 2004 2349 2350 2351 2352 2353 2354 2355 2356 2357 2347 153 153 3 3
126 189 2109 2109 1986 1986 2358 2359 2113 2113 2360 2361 1107 1107 742 742 3 3
126 191 1462 346 2362 350 2363 2364 2365 2366 2367 2368 316 1940 2347 2348 470 415
126 247 2369 2370 2371 2372 2373 772 2374 2375 2376 2377 2378 2378 956 956 51 16
126 254 2379 1639 2210 346 2380 146 2381 2305 2382 2383 2384 1851 2240 2240 154 154
126 255 2385 1520 1558 634 1823 634 2386 16 16 16 18 18 3 3 3 3
127 191 138 138 138 138 2387 2388 1089 2389 1089 2390 500 2391 2392 2347 816 391
127 247 1802 1802 2393 1812 2394 1769 914 2395 2396 634 636 2397 2026 904 18 18
127 254 1986 1986 2398 1632 579 2399 2112 2113 580 1824 651 415 1107 1107 3 3
127 367 2400 2401 2402 2403 2404 2405 2406 2341 2407 579 2408 2409 2410 2411 493 493
187 189 340 340 168 106 1481 469 742 742 3 3 3 3 3 3 3 3
191 247 336 336 168 106 1481 469 415 415 3 3 3 3 3 3 3 3
191 254 1986 1986 1632 1632 2412 2399 2113 2113 2413 1824 415 415 1107 1107 3 3
239 367 336 336 2414 514 1861 1130 415 415 3 3 3 3 3 3 3 3
247 254 340 340 336 336 478 106 904 904 18 18 3 3 3 3 3 3
247 381 336 336 469 1481 106 168 415 415 3 3 3 3 3 3 3 3
255 383 336 336 512 1907 1907 512 415 415 3 3 3 3 3 3 3 3"""
    strtab = split(data1,'\n')
    m = Dict()
    datalines = split(data2,'\n')
    for l in datalines
        a = [parse(Int64,x) for x in split(l)]
        m[(a[1],a[2])]=a[3:end]
    end
    return strtab,m
end

#gendata()
main()
