--[[
 Alternates between 2-4 colours character by character, like 121212, 123123123, or 123412341234.
 Works for primary/border/shadow/secondary (only one of those).
 Nukes all comments and inline tags. Only first block of tags is kept.
 Shift can be used on an already colorized line to shift the colours by one letter.
 You have to set the right number of colours for it to work correctly.
 "Don't join with other tags" will keep {initial tags}{colour} separated (ie won't nuke the "}{"). 
 This helps some other scripts to keep the colour as part of the "text" without initial tags.
 "Continuous shift line by line" - If you select a bunch of the same colorized lines, this shifts the colours line by line.
 This kind of requires that no additional weird crap is done to the lines, otherwise malfunctioning can be expected.
--]]

script_name = "Colorize"
script_description = "Alternates between 2-4 colours"
script_author = "unanimated"
script_version = "1.5"

include("karaskel.lua")

function colors(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	
	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res.c4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col5=res.c5:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	    if res.kol=="primary" then k="\\c" text=text:gsub("\\1?c&H%x+&","") end
	    if res.kol=="border" then k="\\3c" text=text:gsub("\\3c&H%x+&","") end
	    if res.kol=="shadow" then k="\\4c" text=text:gsub("\\4c&H%x+&","") end
	    if res.kol=="secondary" then k="\\2c" text=text:gsub("\\2c&H%x+&","") end
	    
	    k1=k..col1
	    k2=k..col2
	    k3=k..col3
	    k4=k..col4
	    k5=k..col5
	    
	    tags=""
	    if text:match("^{\\[^}]*}") then tags=text:match("^({\\[^}]*})") end
	    text=text:gsub("{[^}]*}","")
	    text=text:gsub("%s*$","")
	    
	    if res.clrs=="2" then text=text:gsub("%s","  ") text=text.."*"
		text=text:gsub("([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	    
	    if res.clrs=="3" then text=text:gsub("%s","   ") text=text:gsub("\\N","\\N~") text=text.."**"
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
		text=text:gsub("{\\[1234]?c&H%x+&}~","")
	    end
	    
	    if res.clrs=="4" then text=text:gsub("%s","    ") text=text:gsub("\\N","\\N\\N") text=text.."***"
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3{"..k4.."}%4")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	    
	    if res.clrs=="5" then text=text:gsub("%s","     ") text=text:gsub("\\N","\\N\\N~") text=text.."****"
	text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3{"..k4.."}%4{"..k5.."}%5")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
		text=text:gsub("{\\[1234]?c&H%x+&}~","")
	    end

	    text=text:gsub("{\\[1234]?c&H%x+&}%*","")
	    text=text:gsub("%*+$","")
	
	text=text:gsub("{\\[1234]?c&H%x+&}\\{\\[1234]?c&H%x+&}N","\\N")
	text=text:gsub("\\N\\N","\\N")
	text=tags..text
	if res.join==false then text=text:gsub("}{","") end
	line.text=text
        subs[i] = line
    end
end

function shift(subs, sel)
	klrs=tonumber(res.clrs)	-- how many colours we're dealing with
	count=1				-- start line counter
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text

	    -- check if line looks colorized
	    if not text:match("{(\\[1234]?c)&H%x+&}[%w%p]$") then aegisub.dialog.display({{class="label",
		label="Line "..x.." does not \nappear to be colorized",x=0,y=0,width=1,height=2}},{"OK"}) aegisub.cancel()
	    end

	    -- determine which colour has been used to colorize - 1c, 2c, 3c, 4c
	    ctype=text:match("{(\\[1234]?c)&H%x+&}[%w%p]$")

	    -- this wasn't needed in the end but just in case
	    c1="{"..text:match("^{.-("..ctype.."&H%x+&)").."}"

	    -- get colours 2, 3, 4, 5, and create sequences for shifting
	    a,c2,b,c3,c,c4,d,c5=text:match("([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})")
	    if klrs==2 then first=c2 end
	    if klrs==3 then first=c3 second=c2 end
	    if klrs==4 then first=c4 second=c3 third=c2 end
	    if klrs==5 then first=c5 second=c4 third=c3 fourth=c2 end

	    -- don't run for 1st lines in sequences
	    if count>1 or not res.cont then

		-- separate first colour tag from other tags, save initial tags
		tags=""
		if text:match("^{\\[^}]*"..ctype.."&") then text=text:gsub("^({\\[^}]*)("..ctype.."&H%x+&)([^}]*})","%1%3{%2}") end
		if not text:match("^{\\[1234]?c&H%x+&}") then tags=text:match("^({\\[^}]*})") text=text:gsub("^{\\[^}]*}","") end

		-- shifting colours happens here
		switch=1
		repeat 
		text=text:gsub("({\\[1234]?c&H%x+&})([%w%p])","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})(%s)","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})(\\N)","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})$","")
		text=first..text
		switch=switch+1
		if switch==2 then first=second end
		if switch==3 then first=third end
		if switch==4 then first=fourth end
		until switch>=count

		text=tags..text
		if res.join==false then text=text:gsub("}{","") end
	    end

	-- line counter
	if res.cont then count=count+1 end
	if count>klrs then count=1 end
	line.text=text
        subs[i] = line
    end
end

function matchcolors(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	karaskel.preproc_line(subs,meta,styles,line)
	
		primary=line.styleref.color1:gsub("H%x%x","H")
		pri=text:match("^{[^}]-\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		outline=line.styleref.color3:gsub("H%x%x","H")
		out=text:match("^{[^}]-\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		shadow=line.styleref.color4:gsub("H%x%x","H")
		sha=text:match("^{[^}]-\\c(&H%x+&)")
		if sha~=nil then shadow=sha end
		
		secondary=line.styleref.color2:gsub("H%x%x","H")
		sec=text:match("^{[^}]-\\3c(&H%x+&)")
		if sec~=nil then secondary=sec end
		
	    if res.kol=="primary" then k="\\c" end
	    if res.kol=="border" then k="\\3c" end
	    if res.kol=="shadow" then k="\\4c" end
	    if res.kol=="secondary" then k="\\2c" end
	    text=text:gsub("\\1c","\\c")

	    
	if res.mode=="\\c -> \\3c (match outline to primary)" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		if ctags:match("\\3c") and not ctags:match("\\1?c") then ctags2=ctags:gsub("\\3c&H%w+&","\\3c"..primary) end
		if ctags:match("\\1?c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\1?c(&H%w+&)") ctags2=ctags:gsub("\\3c&H%w+&","\\3c"..tempc) end
		if ctags:match("\\1?c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("\\1?c(&H%w+&)","\\c%1\\3c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\3c") and not ctags:match("\\1?c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\3c"..primary.."}") end
		ctags=esc(ctags)
		text=text:gsub(ctags,ctags2)
	    end
	end
	
	if res.mode=="\\3c -> \\c (match primary to outline)" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		if ctags:match("\\1?c") and not ctags:match("\\3c") then ctags2=ctags:gsub("\\1?c&H%w+&","\\c"..outline) end
		if ctags:match("\\1?c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\3c(&H%w+&)") ctags2=ctags:gsub("\\1?c&H%w+&","\\c"..tempc) end
		if ctags:match("\\3c") and not ctags:match("\\1?c") then
		  ctags2=ctags:gsub("\\3c(&H%w+&)","\\c%1\\3c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\1?c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\c"..outline.."}") end
		ctags=esc(ctags)
		text=text:gsub(ctags,ctags2)
	    end
	end
	
	if res.mode=="\\c <--> \\3c (switch primary and border)" then
	    if text:match("^{\\") then
		tags=text:match("^({\\[^}]-})")
		if tags:match("\\1?c") then tags=tags:gsub("\\1?c","\\tempc")
		else tags=tags:gsub("({\\[^}]-)}","%1\\tempc"..primary.."}") end
		if tags:match("\\3c") then tags=tags:gsub("\\3c","\\c")
		else tags=tags:gsub("({\\[^}]-)}","%1\\c"..outline.."}") end
		tags=tags:gsub("\\tempc","\\3c")
		after=text:match("^{\\[^}]-}(.*)")
		after=after:gsub("\\1?c","\\tempc")
		after=after:gsub("\\3c","\\c")
		after=after:gsub("\\tempc","\\3c")
		text=tags..after
	    else
		tags="{\\c"..outline.."\\3c"..primary.."}"
		after=text
		after=after:gsub("\\1?c","\\tempc")
		after=after:gsub("\\3c","\\c")
		after=after:gsub("\\tempc","\\3c")
		text=tags..after
	    end
	end
	
	if res.mode=="increase brightness" or res.mode=="increase darkness" then
	    if res.mode=="increase brightness" then pyon=1 else pyon=-1 end
	    if not text:match(k) then
		if res.kol=="primary" then text=text:gsub("^({\\[^}]-)}","%1"..k..primary.."}") end
		if res.kol=="border" then text=text:gsub("^({\\[^}]-)}","%1"..k..outline.."}") end
		if res.kol=="shadow" then text=text:gsub("^({\\[^}]-)}","%1"..k..shadow.."}") end
		if res.kol=="secondary" then text=text:gsub("^({\\[^}]-)}","%1"..k..secondary.."}") end
	    end
	    
		for kol1,kol2,kol3 in text:gmatch(k.."&H(%x%x)(%x%x)(%x%x)&") do
		    kol1n=brightness(kol1)
		    kol2n=brightness(kol2)
		    kol3n=brightness(kol3)
		text=text:gsub(kol1..kol2..kol3,kol1n..kol2n..kol3n)
		end
	end

	line.text=text
        subs[i] = line
    end
end

function brightness(klr)
    ka,kb=klr:match("(%x)(%x)")
    ka=tonumber(ka,16)
    ka=ka+pyon
    ka=tohex(ka)
    klr2=ka..kb
return klr2
end

function tohex(num)
    if num<1 then num="0" end
    if num>14 then num="F" end
    if num==10 then num="A" end
    if num==11 then num="B" end
    if num==12 then num="C" end
    if num==13 then num="D" end
    if num==14 then num="E" end
return num
end

function esc(str)
str=str
:gsub("%%","%%%%")
:gsub("%(","%%%(")
:gsub("%)","%%%)")
:gsub("%[","%%%[")
:gsub("%]","%%%]")
:gsub("%.","%%%.")
:gsub("%*","%%%*")
:gsub("%-","%%%-")
:gsub("%+","%%%+")
:gsub("%?","%%%?")
return str
end

function colorize(subs, sel)
	dialog_config=
	{
	{x=0,y=0,width=1,height=1,class="label",label="Colours"},
	{x=1,y=0,width=1,height=1,class="dropdown",name="clrs",items={"2","3","4","5"},value="2"},
	{x=0,y=2,width=1,height=1,class="label",label="Apply to  "},
	{x=1,y=2,width=1,height=1,class="dropdown",name="kol",items={"primary","border","shadow","secondary"},value="primary"},
	    
	{x=3,y=0,width=1,height=1,class="label",label="  1 "},
	{x=3,y=1,width=1,height=1,class="label",label="  2 "},
	{x=3,y=2,width=1,height=1,class="label",label="  3 "},
	{x=3,y=3,width=1,height=1,class="label",label="  4 "},
	{x=3,y=4,width=1,height=1,class="label",label="  5 "},
	
	{x=4,y=0,width=1,height=1,class="color",name="c1" },
	{x=4,y=1,width=1,height=1,class="color",name="c2" },
	{x=4,y=2,width=1,height=1,class="color",name="c3" },
	{x=4,y=3,width=1,height=1,class="color",name="c4" },
	{x=4,y=4,width=1,height=1,class="color",name="c5" },
	
	{x=0,y=3,width=2,height=1,class="checkbox",name="join",label="Don't join with other tags",value=false },
	{x=0,y=1,width=2,height=1,class="label",label="Use this ^ for Shift too."},
	{x=0,y=4,width=3,height=1,class="checkbox",name="cont",label="Continuous shift line by line",value=false },
	
	{x=0,y=5,width=6,height=1,class="dropdown",name="mode",
		items={"colorize letter by letter","\\c -> \\3c (match outline to primary)","\\3c -> \\c (match primary to outline)","\\c <--> \\3c (switch primary and border)","increase brightness","increase darkness"},value="colorize letter by letter"},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Colorize","Shift","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Colorize" then
		if res.mode=="colorize letter by letter" then colors(subs, sel)
		else matchcolors(subs, sel) end
	end
	if pressed=="Shift" then    shift(subs, sel) end
    
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, colorize)