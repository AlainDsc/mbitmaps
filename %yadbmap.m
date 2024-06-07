%yadbmap ;install-0.00-2024-06-07T05.01.00.380927829.02.00-630699
 ; version=6.40
 ; cuser=adescamp
 ; ctime=2024-04-05T15:31:10+02:00
 ; muser=adescamp
 ; mtime=2024-05-27T10:25:19+02:00
 ;
 ; // About: bitmap index store and retrieve
ltechbeg ; path=/adescamp/bitmap/%yadbmap.m
%SetInd(PGx,PDindex,PDid,PDbit,PDzip,PDpre) ;
 ;setBitmapIndexValue($value, $bitglo, $term, $idnr, $zip=1, $idpre="-"):
 ;
 ; $synopsis: set/unset the bitmap index value of a term for an individual 'record'
 ; PGx: the name of the bitmap index global
 ; PDindex: indexed term
 ; PDid: numeric identificatio of the 'record'
 ; PDbit: index value to be set (1/0)
 ; PDzip: save the bitmap in zipped format(1) or not(0)
 ; PDpre: the 'set',to which the record belongs (this is always a 'record type:set id'
 ;example : s recnr=12345 d %SetInd^%yadbmap($na(^XTMPTEST("xemail2patron")),"peretotal@gmail.com",recnr,1,1,"euser:UA")
 n x,bitsi,bits,bitp
 s bitsi=PDid\50000,bitp=PDid#50000+1
 s bits=$$unzip($g(@PGx@(PDindex,PDpre,bitsi)))
 s bits=$zbitset($s(bits="":$zbitstr(bitp),$zbitlen(bits)<bitp:$zbitor($zbitstr(bitp),bits),1:bits),bitp,PDbit)
 i $zbitcount(bits)=0 k:$d(@PGx@(PDindex,PDpre,bitsi)) @PGx@(PDindex,PDpre,bitsi) q
 s x=$s(PDzip:$$zip(bits),1:"A"_bits)
 q:$g(@PGx@(PDindex,PDpre,bitsi))=x
 s @PGx@(PDindex,PDpre,bitsi)=x
 q
%SetBM(PGx,PDid,PDbit,PDzip,PDpre) ;def
 ;addBitmapset($bitset, $idnr, $zip=1, $idset="-")
 ; $synopsis: add/remove a 'record' to/from a bitmap set
 ;       (a bitmap set is an array of the form:
 ;         (set) = a bitmap array )
 ; PGx: the name of the bitmap index global
 ; PDid: numeric id of the 'record'
 ; PDbit: add the record(1) or remove it (0) from the bitmap set
 ; PDzip: save the bitmap in zipped format(1) or not(0)
 ; PDpre: the 'set',to which the record belongs
 n x,bitsi,bits,bitp
 s bitsi=PDid\50000,bitp=PDid#50000+1
 s bits=$$unzip($g(@PGx@(PDpre,bitsi)))
 s bits=$zbitset($s(bits="":$zbitstr(bitp),$zbitlen(bits)<bitp:$zbitor($zbitstr(bitp),bits),1:bits),bitp,PDbit)
 i $zbitcount(bits)=0 k:$d(@PGx@(PDpre,bitsi)) @PGx@(PDpre,bitsi) q
 s x=$s(PDzip:$$zip(bits),1:"A"_bits)
 q:$g(@PGx@(PDpre,bitsi))=x
 s @PGx@(PDpre,bitsi)=x
 q
%NextBM(PGx,PDpos,PDpre) ;fn
 ;nextBitmapsetNode($return, $bitset, $idnr, $idset="-")
 ; $synopsis: get the 'next' record nummer in a bitmap set.
 ; returns the next record number (empty=end-of-the-road)
 ; PGx:  the name of the bitmap index global
 ; PDpos: numeric id of the previous record (Empty = take the first)
 ; PDpre: the 'set',in which you are interested
 ; the combination (PDpos,PDpre) is unique
 n x,bitsi,bitp
 ;get next id
 s bitsi=PDpos\50000,bitp=PDpos#50000+1
 i $d(@PGx@(PDpre,bitsi)) s x=$zbitfind($$unzip(@PGx@(PDpre,bitsi)),1,bitp+1) q:x x-2+(bitsi*50000)
 f  s bitsi=$o(@PGx@(PDpre,bitsi)) q:bitsi=""  s x=$zbitfind($$unzip(@PGx@(PDpre,bitsi)),1) q:x
 q $s(bitsi="":"",x:x-2+(bitsi*50000),1:"")
%GetInd(PGx,PDindex,PDid,PDpre) ;def
 ;getBitmapIndexValue($return, $bitglo, $term, $idnr, $idpre="-")
 ; $synopsis: get the index value of a term for an indovidual record in a bitmap index
 ; returns the value 1 or 0
 ; PGx:  the name of the bitmap index global
 ; PDindex: the indexed term
 ; PDid: numeric id of the 'record'
 ; PDpre: the 'set' to which the record belongs
 n x,bitp,bits,bitsi
 s bitsi=PDid\50000,bitp=PDid#50000+1
 q:'$d(@PGx@(PDindex,PDpre,bitsi)) 0
 s bits=$$unzip(@PGx@(PDindex,PDpre,bitsi))
 q:bitp>$zbitlen(bits) 0
 q $zbitget(bits,bitp)
%GetBmap(PAbmap,PGx,PDindex,PDpat,PDpre) ;def
 ;getBitmap($bitmap, $bitglo, $term="", $pattern="", $idpre="-")
 ; $synopsis: get the bitmap froma given 'term'
 ; PAbmap: return array of type 'bitmap', Is killed initially.
 ; PGx : name of the global reference, that contain the bitmap
 ; PDindex: the term to be indexed
 ; PDpat: Optional. A pattern of terms to be retrieved.
 ;        (If not empty, PDindex is ignored)
 ; PDpre: the 'set' to which the record belongs
 n x,i,pre,RAbmap,index,indp,match
 k PAbmap
 i PDpat'="" d
 . s PDindex=""
 . ;the only pattern that is supported here, is 'abc*' (with * at the end)
 . ;interprete pattern as index if it does not seem to be a pattern
 . i $e(PDpat,$l(PDpat))'="*" s PDindex=PDpat q
 . s indp=$e(PDpat,1,$l(PDpat)-1) q:indp=""
 . s index=$s($d(@PGx@(indp)):indp,1:$o(@PGx@(indp)))
 . f  q:$e(index,1,$l(indp))'=indp  d  s index=$o(@PGx@(index))
 .. d %GetBmap(.RAbmap,PGx,index,"",PDpre)
 .. ;4_orBitmapInPlace(PAbmap,RAbmap)
 .. d %OrI(.PAbmap,.RAbmap)
 .. q
 . q
 i PDindex'="" d
 . s i="" f  s i=$O(@PGx@(PDindex,PDpre,i)) q:i=""  d
 .. s PAbmap(i)=$$unzip(@PGx@(PDindex,PDpre,i))
 .. q
 . q
 q
%GetBmpP(PArray,PGx,PDindex,PDpat,PDkill) ;def
 ;getBitmapIndexPrefixes($array, $bitglo, $term="", $pattern="")
 ; $synopsis: get the defined sets for a given indexed term
 ; PArray: return array, form = (set)=""
 ; PGx : name of the global reference, that contain the bitmap
 ; PDindex: the indexed term
 ; PDpat: Optional. The indexed terms in form of a pattern
 ;        (if not empty, PDindex will be ignored)
 ; PDkill: kill PArray before calculating(1) or not(0)
 n x,index,indp,match,pre
 i PDkill k PArray
 i PDpat'="" d
 . s PDindex=""
 . ;the only pattern that is supported here, is 'abc*' (with * at the end)
 . ;interprete pattern as index if it does not seem to be a pattern
 . i $e(PDpat,$l(PDpat))'="*" s PDindex=PDpat q
 . s indp=$e(PDpat,1,$l(PDpat)-1) q:indp=""
 . s index=$s($d(@PGx@(indp)):indp,1:$o(@PGx@(indp)))
 . f  q:$e(index,1,$l(indp))'=indp  d  s index=$o(@PGx@(index))
 .. d %GetBmpP(.PArray,PGx,index,"",0)
 .. q
 . q
 i PDindex'="" d
 . s pre="" f  s pre=$O(@PGx@(PDindex,pre)) q:pre=""  s PArray(pre)=""
 . q
 q
%Nxtid(PAbmap,PDpos) ;def
 ;nextBitmapIndexNode($nextidnr, $bitmap, $posidnr)
 ; $synopsis: get the next 'positive' id number within a bitmap array (= where the value=1)
 ; returns an id number or the empty string
 ; PAbmap: call bitmap array
 ; PDpos: start position. Empty = beginning
 n x,bitsi,bitp
 ;get next id
 s bitsi=PDpos\50000,bitp=PDpos#50000+1
 i $d(PAbmap(bitsi)) s x=$zbitfind(PAbmap(bitsi),1,bitp+1) q:x x-2+(bitsi*50000)
 f  s bitsi=$o(PAbmap(bitsi)) q:bitsi=""  s x=$zbitfind(PAbmap(bitsi),1) q:x
 q $s(bitsi="":"",x:x-2+(bitsi*50000),1:"")
%Max(PAbmap) ;def
 ;getBitmapMax($max, $bitmap)
 ; $synopsis: get the highest number, where there has been filed a value
 ; returns an integer
 ; PAbmap: call bitmap array (non-zipped)
 n x,bitsi,bitp
 s bitsi=$o(PAbmap(""),-1)
 q:bitsi="" 0
 s bitp=$zbitlen(PAbmap(bitsi))
 q bitsi*50000+bitp-1
%Not(PAbmap,PAbmap1,PDmaxi) ;def
 ;notBitmap($bitmap, $bitmapa, $max)
 ; $synopsis: calculate the negation of a bitmap
 ; PAbmap: return bitmap array
 ; PAbmap1: call bitmap array
 ; PDmaxl: maximum number, that cam exist
 n x,i
 k PAbmap
 s i="" f  s i=$O(PAbmap1(i)) q:i=""  d
 . s x=PAbmap1(i)
 . i $zbitcount(x)<50000 s x=$zbitor(x,$zbitstr(50000))
 . s PAbmap(i)=$zbitnot(x)
 . q
 q:'PDmaxi
 f i=0:1:(PDmaxi\50000) i '$d(PAbmap(i)) s PAbmap(i)=$zbitstr(50000,1)
 q
%CntInd(PGx,PDindex,PDpre) ;def
 ;getBitmapCount($count, $bitmap, $zipped=0)
 ; $synopsis: get the number of 'hits' from a given index term in a bitmap index
 ; returns an integer
 ; PGx: name of the global, that containes the bitmap index
 ; PDindex: indexed term
 ; PDpre: the 'set' of records, you want to consider
 n x,i
 s x=0,i=""
 f  s i=$O(@PGx@(PDindex,PDpre,i)) q:i=""  s x=x+$zbitcount($$unzip(@PGx@(PDindex,PDpre,i)))
 q x
%Cnt(PAbmap,PDzipped) ;def
 ;getBitmapCount($count, $bitmap, $zipped=0)
 ; $synopsis: get the number of positive id's within a bitmap array
 ; returns an integer
 ; PAbmap: call bitmap array
 ; PDzipped: Is the bitmap array zipped (1) or not (0)
 n x,i
 i 'PDzipped s x=0,i="" f  s i=$O(PAbmap(i)) q:i=""  s x=x+$zbitcount(PAbmap(i))
 i PDzipped s x=0,i="" f  s i=$O(PAbmap(i)) q:i=""  s x=x+$zbitcount($$unzip(PAbmap(i)))
 q x
%And(PAbmap,PAbmap1,PAbmap2) ;def
 ;andBitmap($bitmap, $bitmapa, $bitmapb)
 ; $synopsis: calculate a bitmap, the AND of 2 bitmaps
 ; PAbmap: return array (bitmap)
 ; PAbmap1: call bitmap array 1
 ; PAbmap2: call bitmap array 2
 n x,i
 k PAbmap
 s i="" f  s i=$O(PAbmap1(i)) q:i=""  d
 . q:'$d(PAbmap2(i))
 . s PAbmap(i)=$zbitand(PAbmap1(i),PAbmap2(i))
 . q
 q
%AndI(PAbmap,PAbmap2) ;def
 ;andBitmapInPlace($bitmap, $bitmapb)
 ; $synopsis: replace a bitmap by the result of an AND of itself with a secone bitmap
 ; PAbmap: call and return array. Bitmap 1
 ; PAbmap2: call array bitmap 2
 n x,i
 s i="" f  s i=$O(PAbmap(i)) q:i=""  d
 . i '$d(PAbmap2(i)) k PAbmap(i) q
 . s PAbmap(i)=$zbitand(PAbmap(i),PAbmap2(i))
 . q
 q
%AndNot(PAbmap,PAbmap1,PAbmap2) ;def
 ;andNotBitmap($bitmap, $bitmapa, $bitmapb)
 ; $synopsis: calculate a bitmap, the AND NOT of 2 bitmaps
 ; PAbmap: return array (bitmap)
 ; PAbmap1: call bitmap array 1
 ; PAbmap2: call bitmap array 2
 n x,i,y
 k PAbmap
 s i="" f  s i=$O(PAbmap1(i)) q:i=""  d
 . i '$d(PAbmap2(i)) s PAbmap(i)=PAbmap1(i) q
 . s y=$zbitlen(PAbmap1(i)) s x=$s($zbitlen(PAbmap2(i))<y:$zbitor($zbitstr(y),PAbmap2(i)),1:PAbmap2(i))
 . s x=$zbitnot(x)
 . s PAbmap(i)=$zbitand(PAbmap1(i),x)
 . q
 q
%Or(PAbmap,PAbmap1,PAbmap2) ;def
 ;orBitmap($bitmap, $bitmapa, $bitmapb)
 ; $synopsis: calculate a bitmap, the OR of 2 bitmaps
 ; PAbmap: return array (bitmap)
 ; PAbmap1: call bitmap array 1
 ; PAbmap2: call bitmap array 2
 n x,i
 s i="" f  s i=$O(PAbmap2(i)) q:i=""  d
 . i '$d(PAbmap1(i)) s PAbmap(i)=PAbmap2(i) q
 . s PAbmap(i)=$zbitor(PAbmap1(i),PAbmap2(i))
 . q
 q
%OrI(PAbmap,PAbmap2) ;def
 ;orBitmapInPlace($bitmap, $bitmapb)
 ; $synopsis: replace a bitmap by the result of an OR of itself with a secone bitmap
 ; PAbmap: call and return array. Bitmap 1
 ; PAbmap2: call array bitmap 2
 n x,i
 s i="" f  s i=$O(PAbmap(i)) q:i=""  d
 . q:'$d(PAbmap2(i))
 . s PAbmap(i)=$zbitor(PAbmap(i),PAbmap2(i))
 . q
 s i="" f  s i=$O(PAbmap2(i)) q:i=""  d
 . q:$d(PAbmap(i))
 . s PAbmap(i)=PAbmap2(i)
 . q
 q
%XOr(PAbmap,PAbmap1,PAbmap2) ;def
 ;xorBitmap($bitmap, $bitmapa, $bitmapb)
 ; $synopsis: calculate a bitmap, the XOR of 2 bitmaps
 ; PAbmap: return array (bitmap)
 ; PAbmap1: call bitmap array 1
 ; PAbmap2: call bitmap array 2
 n x,i,y
 s i="" f  s i=$O(PAbmap2(i)) q:i=""  d
 . i '$d(PAbmap1(i)) s PAbmap(i)=PAbmap2(i) q
 . s x=$$max($zbitlen(PAbmap1(i)),$zbitlen(PAbmap2(i)))
 . s y=$zbitstr(x)
 . s PAbmap(i)=$zbitxor($zbitor(PAbmap1(i),y),$zbitor(PAbmap2(i),y))
 . q
 q
max(PDa,PDb) ;def
 q $s(PDa>PDb:PDa,1:PDb)
zip(PDstr) ;fn
 n x,l,res,z
 s res=""
 ;small quantities are treted differently
 i $zbitcount(PDstr)<256 d  q $c(192)_res
 . s res="S",z=1 f  s z=$zbitfind(PDstr,1,z) q:'z  s res=res_$$num2bin(z-1)
 . q
 ;A=as is
 ;todo : 'W'
 ;more than 50 % : take as is
 i $zbitcount(PDstr)>25000 q $c(192)_"A"_PDstr
 s x=$tr($j("",$zbitfind(PDstr,1)\8-1)," ",$c(0))
 i $l(x)<10 q $c(192)_"A"_PDstr
 q $c(192)_"B"_$e(PDstr)_"N"_$$num2bin($l(x))_"A"_$e(PDstr,2+$l(x),$l(PDstr))
unzip(PDstr) ;def
 n x,mode,bstr,bitp,i
 s:$a(PDstr)=192 PDstr=$e(PDstr,2,$l(PDstr))
 s mode=$e(PDstr)
 ;A=as is, tot einde string
 q:mode="A" $e(PDstr,2,$l(PDstr))
 ;B=1 byte as is
 i mode="B" q $e(PDstr,2)_$$unzip($e(PDstr,3,$l(PDstr)))
 i mode="w" s x=$a(PDstr,2) q $e(PDstr,3,$a(PDstr,2))_$$unzip($e(PDstr,$a(PDstr,2)+4,$l(PDstr)))
 ;W=$c(0)+
 ;N = nullen, aangegeven door getal in 2 bytes
 i mode="N" q $tr($j("",$$bin2num($e(PDstr,2,3)))," ",$c(0))_$$unzip($e(PDstr,5,$l(PDstr)))
 ;n= nullen, aangegeven door getal in 1 byte
 i mode="n" q $tr($j("",$$bin2num($e(PDstr,2)))," ",$c(0))_$$unzip($e(PDstr,3,$l(PDstr)))
 s bstr=""
 ;S=singular values, aangegeven door getal, telkens in 2 bytes, tot einde string
 i mode="S" d  q bstr
 . s bstr=$zbitstr(1)
 . ;van achter naar voor: dan heb je snel de goede bit lengte
 . f i=$l(PDstr)-1:-2:2 d
 .. s bitp=$$bin2num($e(PDstr,i,i+1))
 .. s bstr=$zbitset($s(bstr="":$zbitstr(bitp),$zbitlen(bstr)<bitp:$zbitor($zbitstr(bitp),bstr),1:bstr),bitp,1)
 .. q
 . q
 ;fout
 q PDstr
bin2num(PDbin) ;def
 n x
 q $a(PDbin)*256+$a(PDbin,2)
num2bin(PDnum) ;def
 q $c(PDnum\256)_$c(PDnum#256)
%OutBmap(PAbmap,PDzipped) ;def
 ; $synopsis: show the content of a bitmap array in a readable way
 ;           this entry is only for debug facilities
 ; prints the bitmap on the current device
 ; PAbmap: call bitmap array
 ; PDzipped: Is the bitmap array zipped (1) or not (0)
 n x,ZAbmap,i,lp,next,pos,vervolg
 ;show bitmap
 i PDzipped d  q
 . s i="" f  s i=$O(PAbmap(i)) q:i=""  s ZAbmap(i)=$$unzip(PAbmap(i))
 . d %OutBmap(.ZAbmap,0)
 . q
 s pos="",vervolg=0,lp=""
 f  d  q:pos=""
 . ;4_nextBitmapIndexNode(next, PAbmap, pos)
 . s next=$$%Nxtid(.PAbmap,pos)
 . i 'pos w next s pos=next q
 . i next="" w:vervolg "-"_pos s pos="" q
 . i next-1=pos s:'vervolg vervolg=1,lp=pos s pos=next q
 . i vervolg w "-"_pos_","_next s vervolg=0 i 1
 . e  w ","_next
 . s pos=next
 . q
 q
%Stat(PAstat,PGx) ;def
 ; $synopsis: collect statistics about a given bitmap index global
 ;
 ; PAstat: return array : form = (set,keyword)=number
 ; keyword can be : "maxhits", "maxkey",..
 ; PGx: call variable. Conatines the name of the bitmap index global
 n x,RApre,index,stop,cat,count,keylen,next,pre,RAbmap
 k PAstat
 s index=""
 f  d  q:index=""
 . ;4_nextBitmapIndex(next,PGx,index)
 . s next=$o(@PGx@(index))
 . s index=next q:index=""
 . k RApre
 . ;4_getBitmapIndexPrefixes(RApre,PGx,index)
 . d %GetBmpP(.RApre,PGx,index,"",1)
 . s pre=""
 . f  s pre=$O(RApre(pre)) q:pre=""  d
 .. ;4_getBitmap(RAbmap,PGx,index,idpre=pre)
 .. d %GetBmap(.RAbmap,PGx,index,"",pre)
 .. ;4_getBitmapCount(count,RAbmap)
 .. s count=$$%Cnt^bbmapi(.RAbmap,0)
 .. s keylen=$l(index)
 .. i $g(PAstat(pre,"maxhits"))<count s PAstat(pre,"maxhits")=count,PAstat(pre,"maxhitterm")=index
 .. s:$g(PAstat(pre,"maxkey"))<keylen PAstat(pre,"maxkey")=keylen
 .. s cat=$s('count:"a=0",count=1:"b=1",count<10:"c<10",count<100:"d10-100",count<1000:"e100-1000",1:"f>1000")
 .. s x=$i(PAstat(pre,"hithist",cat))
 .. s x=$i(PAstat(pre,"hithist","total"))
 .. q
 . q
 q
%SetV(PDbit,PAbmap,PDid) ;def
 ; $synopsis: set/clear the bitmap value froma given record nr in a bitmap array
 ;
 ; PDbit: bitmap value . 1=on, 0=off
 ; PAbmap: name of the (local) bitmap array.
 ;         is build if non-existant
 ; PDid : numeriec (!) id of the 'record'
 n x,bitsi,bits,bitp
 s bitsi=PDid\50000,bitp=PDid#50000+1
 s bits=$g(PAbmap(bitsi))
 s bits=$zbitset($s(bits="":$zbitstr(bitp),$zbitlen(bits)<bitp:$zbitor($zbitstr(bitp),bits),1:bits),bitp,PDbit)
 i $zbitcount(bits)=0 k PAbmap(bitsi) q
 s PAbmap(bitsi)=bits
 q
%GetV(PAbmap,PDid) ;def
 ; $synopsis: get the bitmap value of a record nr in a given bitmap array
 ; function returns 1=on, 0=off
 ; PAbmap: name of the (local) bitmap array
 ; PDid: numeric id of the 'record'
 n x,bitp,bits,bitsi
 s bitsi=PDid\50000,bitp=PDid#50000+1
 q:'$d(PAbmap(bitsi)) 0
 s bits=PAbmap(bitsi)
 q:bitp>$zbitlen(bits) 0
 q $zbitget(bits,bitp)
ltechend ; path=/adescamp/bitmap/%yadbmap.m
