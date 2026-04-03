-- capi: capybara's hotspring
-- arrows:move | z:interact | x/left:close

-- upgrade table: {name, cost, pool_size}
local upg={
 {"tiny puddle",  0,  8},
 {"small pool",  50, 12},
 {"warm bath",  150, 16},
 {"cozy spring",300, 20},
 {"paradise",   600, 26},
}

-- hotspring center
local hx,hy=64,58
-- work area center
local wx,wy=100,90
-- tree positions {x,y}
local trees={
 {15,18},{105,18},{18,98},{108,95},
 {28,82},{95,28},{22,52},{110,58},
 {52,12},{78,112},{40,105},{88,8},
}

-- state: 0=title 1=world 2=menu
local gs=0
-- player
local px,py=64,92
local pfx,pan,pat=1,0,0
-- coins/level
local nc,hl=0,1
-- tables
local coins,steam={},{}
-- timers
local wtimer,wanim,mmsg=0,0,""
local title_t=0

function _init()
 for i=1,6 do spawn_coin() end
end

function spawn_coin()
 local x,y,ok,tries=0,0,false,0
 repeat
  x=12+flr(rnd(104))
  y=12+flr(rnd(104))
  ok=true
  if abs(x-hx)<22 and abs(y-hy)<22 then ok=false end
  if abs(x-wx)<16 and abs(y-wy)<16 then ok=false end
  for tr in all(trees) do
   if abs(x-tr[1])<9 and abs(y-tr[2])<9 then ok=false end
  end
  tries+=1
 until ok or tries>40
 add(coins,{x=x,y=y})
end

function _update()
 if gs==0 then
  title_t+=1
  if btn(0) or btn(1) or btn(2) or btn(3)
  or btn(4) or btn(5) then gs=1 end
 elseif gs==1 then
  upd_world()
 elseif gs==2 then
  upd_menu()
 end
end

function upd_world()
 local dx,dy=0,0
 if btn(0) then dx-=1.2 end
 if btn(1) then dx+=1.2 end
 if btn(2) then dy-=1.2 end
 if btn(3) then dy+=1.2 end
 if dx>0 then pfx=1 elseif dx<0 then pfx=-1 end
 if dx~=0 or dy~=0 then
  pat+=1
  if pat>8 then pat=0;pan=1-pan end
 else
  pan=0;pat=0
 end
 px=mid(6,px+dx,122)
 py=mid(8,py+dy,122)

 -- collect coins
 local nc2={}
 for c in all(coins) do
  if abs(px-c.x)<6 and abs(py-c.y)<6 then
   nc+=1
  else
   add(nc2,c)
  end
 end
 coins=nc2
 while #coins<6 do spawn_coin() end

 -- work area: earn 3 coins every 5s
 if abs(px-wx)<14 and abs(py-wy)<14 then
  wtimer+=1
  if wtimer>=150 then
   wtimer=0;nc+=3;wanim=45
  end
 else
  wtimer=0
 end
 if wanim>0 then wanim-=1 end

 -- open upgrade menu
 if abs(px-hx)<24 and abs(py-hy)<24
 and btnp(4) then
  gs=2;mmsg=""
 end

 -- steam particles
 local sr={0,0.05,0.15,0.25,0.4}
 if rnd(1)<sr[hl] then
  local s=upg[hl][3]
  add(steam,{
   x=hx-s/2+rnd(s),y=hy+2,
   dy=-0.5-rnd(0.4),
   dx=rnd(0.6)-0.3,
   l=50+flr(rnd(20))
  })
 end
 local ns={}
 for p in all(steam) do
  p.x+=p.dx;p.y+=p.dy;p.l-=1
  if p.l>0 then add(ns,p) end
 end
 steam=ns
end

function upd_menu()
 if btnp(5) or btnp(0) then gs=1 end
 if btnp(4) then do_upgrade() end
end

function do_upgrade()
 if hl>=5 then
  mmsg="already at max!"
  return
 end
 local cost=upg[hl+1][2]
 if nc>=cost then
  nc-=cost;hl+=1
  mmsg="upgraded!  ^_^"
 else
  mmsg="need "..(cost-nc).." more coins!"
 end
end

function _draw()
 if gs==0 then
  draw_title()
 else
  draw_world()
  if gs==2 then draw_menu() end
 end
end

function draw_title()
 cls(1)
 -- animated bg patches
 for i=0,15 do
  for j=0,3 do
   if (i+j+flr(title_t/20))%3==0 then
    rectfill(i*8,j*32,i*8+7,j*32+31,3)
   end
  end
 end

 -- title card
 rectfill(20,22,108,78,0)
 rect(20,22,108,78,10)
 rect(21,23,107,77,9)

 print("c a p i",40,28,10)
 print("capybara's hotspring",21,40,7)
 print("collect coins",27,50,11)
 print("upgrade your spring!",20,60,12)

 -- capybara face
 local fx,fy=64,96
 circfill(fx,fy,10,4)
 circfill(fx+7,fy-2,4,4)
 pset(fx-3,fy-2,0);pset(fx+3,fy-2,0)
 rectfill(fx-3,fy+4,fx+3,fy+7,9)
 print("^",fx-1,fy+2,0)
 rectfill(fx-1,fy-9,fx+3,fy-7,4)

 if flr(title_t/15)%2==0 then
  print("press any button",24,113,7)
 end
end

function draw_world()
 -- checkerboard grass
 cls(11)
 for i=0,3 do for j=0,3 do
  if (i+j)%2==0 then
   rectfill(i*32,j*32,i*32+31,j*32+31,3)
  end
 end end

 -- dirt paths
 rectfill(0,56,127,68,9)
 rectfill(58,0,70,127,9)

 -- trees
 for tr in all(trees) do
  local tx,ty=tr[1],tr[2]
  rectfill(tx-1,ty+4,tx+1,ty+10,4)
  circfill(tx,ty,7,3)
  circfill(tx-1,ty-2,4,11)
 end

 -- bamboo work area
 rectfill(wx-14,wy-14,wx+12,wy+10,3)
 rect(wx-14,wy-14,wx+12,wy+10,5)
 for i=0,2 do
  local bx=wx-9+i*8
  line(bx,wy+8,bx,wy-12,11)
  line(bx,wy,bx+4,wy-4,3)
  line(bx,wy-6,bx-4,wy-10,11)
 end
 print("work",wx-9,wy+12,7)

 -- hotspring
 draw_hs()

 -- steam
 for p in all(steam) do
  local a=p.l/70
  local c=a>.5 and 7 or (a>.25 and 6 or 13)
  pset(p.x,p.y,c)
  if a>0.4 then
   pset(p.x+1,p.y,c)
   pset(p.x,p.y-1,c)
  end
 end

 -- coins (animated sparkle)
 local tc=t()
 for c in all(coins) do
  if flr(tc*4+c.x*0.1)%2==0 then
   circfill(c.x,c.y,3,10);pset(c.x,c.y,7)
  else
   circfill(c.x,c.y,3,9);pset(c.x,c.y,10)
  end
 end

 draw_plr()

 -- interaction hints
 if abs(px-hx)<24 and abs(py-hy)<24 then
  print("[z] upgrade spring",16,118,7)
 end
 if abs(px-wx)<14 and abs(py-wy)<14 then
  local pct=wtimer/150
  rectfill(wx-16,wy+16,wx+14,wy+20,0)
  rectfill(wx-16,wy+16,wx-16+flr(pct*30),wy+20,10)
  print("working...",wx-19,wy+22,7)
  if wanim>0 then print("+3!",wx-4,wy-20,10) end
 end

 draw_ui()
end

function draw_hs()
 local s=upg[hl][3]
 local x1,y1=hx-s,hy-s
 local x2,y2=hx+s,hy+s

 -- stone surround
 rectfill(x1-4,y1-4,x2+4,y2+4,5)
 -- stone detail
 local sp=flr(s/2)
 for i=0,4 do
  pset(x1-2+i*sp,y1-3,6)
  pset(x1-2+i*sp,y2+3,6)
 end

 -- water
 rectfill(x1,y1,x2,y2,1)
 -- ripple
 local tc=t()
 line(x1+2,y1+s/2+flr(sin(tc*.3)*2),
      x2-2,y1+s/2+flr(sin(tc*.3+.5)*2),12)
 rectfill(x1+2,y1+2,x1+s,y1+4,12)

 -- level 3: side rocks
 if hl>=3 then
  circfill(x1-2,hy,4,5);circfill(x1-2,hy,3,6)
  circfill(x2+2,hy,4,5);circfill(x2+2,hy,3,6)
 end
 -- level 4: gold trim
 if hl>=4 then
  for i=x1-3,x2+3,4 do
   pset(i,y1-4,10);pset(i,y2+4,10)
  end
  for i=y1-3,y2+3,4 do
   pset(x1-4,i,10);pset(x2+4,i,10)
  end
 end
 -- level 5: flowers
 if hl>=5 then
  local fp={{x1-8,y1-8},{x2+8,y1-8},
            {x1-8,y2+8},{x2+8,y2+8}}
  for f in all(fp) do
   circfill(f[1],f[2],3,14)
   circfill(f[1],f[2],1,10)
  end
 end

 -- name label
 local n=upg[hl][1]
 print(n,hx-#n*2,y2+7,7)
end

function draw_plr()
 local bx=px-4
 local by=py-4
 if pfx==1 then
  -- body + head
  rectfill(bx,by+2,bx+7,by+6,4)
  rectfill(bx+2,by,bx+7,by+3,4)
  -- snout + nose
  rectfill(bx+6,by+1,bx+9,by+3,9)
  pset(bx+9,by+2,5)
  -- eye
  pset(bx+5,by+1,0)
  -- ear
  rectfill(bx+3,by-1,bx+5,by+1,4)
  pset(bx+4,by,14)
  -- tail
  pset(bx-1,by+3,4);pset(bx-1,by+4,4)
  -- legs
  if pan==0 then
   rectfill(bx+1,by+6,bx+2,by+9,4)
   rectfill(bx+5,by+6,bx+6,by+9,4)
  else
   rectfill(bx+2,by+6,bx+3,by+9,4)
   rectfill(bx+4,by+6,bx+5,by+9,4)
  end
 else
  -- facing left (mirror)
  rectfill(bx,by+2,bx+7,by+6,4)
  rectfill(bx,by,bx+5,by+3,4)
  rectfill(bx-2,by+1,bx+1,by+3,9)
  pset(bx-2,by+2,5)
  pset(bx+2,by+1,0)
  rectfill(bx+2,by-1,bx+4,by+1,4)
  pset(bx+3,by,14)
  pset(bx+8,by+3,4);pset(bx+8,by+4,4)
  if pan==0 then
   rectfill(bx+1,by+6,bx+2,by+9,4)
   rectfill(bx+5,by+6,bx+6,by+9,4)
  else
   rectfill(bx+2,by+6,bx+3,by+9,4)
   rectfill(bx+4,by+6,bx+5,by+9,4)
  end
 end
end

function draw_ui()
 -- coin counter
 rectfill(0,0,58,9,0)
 rectfill(1,1,57,8,5)
 circfill(6,4,3,10);pset(6,4,7)
 print(nc.." coins",12,1,10)
 -- level display
 rectfill(73,0,127,9,0)
 rectfill(74,1,126,8,5)
 print("lv."..hl.." spring",76,1,12)
end

function draw_menu()
 -- background overlay
 rectfill(14,14,114,114,0)
 rect(14,14,114,114,10)
 rect(15,15,113,113,9)

 print("hotspring upgrades",20,19,10)
 line(20,27,108,27,9)

 print("level "..hl..": "..upg[hl][1],20,31,12)
 print("coins: "..nc,20,39,10)

 if hl<5 then
  local nu=upg[hl+1]
  local c=nu[2]
  print("next: "..nu[1],20,51,7)
  print("cost: "..c.." coins",20,59,9)
  local pct=min(nc/c,1)
  rectfill(20,69,100,75,5)
  rectfill(20,69,20+flr(pct*80),75,11)
  rect(20,69,100,75,6)
  print(flr(pct*100).."%",84,70,6)
  if nc>=c then
   print("[z] upgrade!",20,81,11)
  else
   print("[z] upgrade (not enough)",20,81,8)
  end
 else
  print("paradise achieved!",20,55,14)
  print("max level hotspring!",20,65,7)
  print("^_^  ^o^  ^v^",24,78,10)
 end

 if mmsg~="" then print(mmsg,20,93,14) end
 print("[x / left] close",20,104,6)

 -- decorative capybara face
 local fx,fy=95,50
 circfill(fx,fy,10,4)
 circfill(fx+7,fy-2,4,4)
 pset(fx-3,fy-2,0);pset(fx+3,fy-2,0)
 rectfill(fx-3,fy+4,fx+3,fy+7,9)
 print("^",fx-1,fy+2,0)
 rectfill(fx-1,fy-9,fx+3,fy-7,4)
end