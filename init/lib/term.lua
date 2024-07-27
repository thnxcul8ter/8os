term={}
for i,v in ipairs(component.gpu) do
  local t={}
  term[i]=t
  t.gpu=v
  t.screen=component.proxy(v.getScreen())
  t.keyboard=component.proxy(t.screen.getKeyboards()[1])
  t.cursorPos={x=1,y=1}
  t.resolution={}
  t.resolution.x,t.resolution.y=t.gpu.getResolution()
  t.pullkey=function()
    if not t.keyboard then return false,"no keyboard" end
    local ev
    repeat
      ev=table.pack(event.pull("key_down"))
    until ev[2]==t.keyboard.address
    return table.unpack(ev)
  end
  t.clear=function()
    t.gpu.fill(1,1,t.resolution.x,t.resolution.y," ")
    t.cursorPos.x=1
    t.cursorPos.y=1
  end
  t.write=function(str)
    if str==nil then return false,"no string provided" end
    for i=1,string.len(str) do
      if t.cursorPos.y>t.resolution.y then t.clear() end
      if string.sub(str,i,i)=="\n" then
        t.cursorPos.x=1
        t.cursorPos.y=t.cursorPos.y+1
      else
        if t.cursorPos.x>t.resolution.x then t.cursorPos.x=1 t.cursorPos.y=t.cursorPos.y+1 end
        t.gpu.set(t.cursorPos.x,t.cursorPos.y,string.sub(str,i,i))
        t.cursorPos.x=t.cursorPos.x+1
      end
    end
  end
  t.pull=function()
    t.write("\n:")
    local buffer=""
    repeat
      local ev=table.pack(t.pullkey())
      if ev[3]==8 then
        buffer=string.sub(buffer,1,-2)
        t.cursorPos.x=t.cursorPos.x-1
        t.gpu.set(t.cursorPos.x,t.cursorPos.y," ")
      elseif ev[3]~=0 then
        buffer=buffer..string.char(ev[3])
        t.write(string.char(ev[3]))
      end
    until ev[3]==13
    t.cursorPos.x=1
    t.cursorPos.y=t.cursorPos.y+1
    return buffer
  end
  local buffer=""
  local function keyListener(...)
    local ev=table.pack(...)
    if not t.keyboard then event.unregister(keyListener) return false,"no keyboard" end
    if ev[2]==t.keyboard.address then
      if ev[3]==8 then
        buffer=string.sub(buffer,1,-2)
        t.cursorPos.x=t.cursorPos.x-1
        t.gpu.set(t.cursorPos.x,t.cursorPos.y," ")
      elseif ev[3]==13 then
        t.cursorPos.x=1
        t.cursorPos.y=t.cursorPos.y+1
        event.push("term_read_done_"..tostring(t),buffer)
        buffer=""
        event.unregister(keyListener)
      elseif ev[3]~=0 then
        buffer=buffer..string.char(ev[3])
        t.write(string.char(ev[3]))
      end
    end
  end
  t.readAsync=function()
    event.register(keyListener,"key_down")
  end
end
