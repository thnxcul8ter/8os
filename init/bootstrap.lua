local loadfile=...
_OSVER=0.2
loadfile("/init/lib/event.lua")()
loadfile("/init/lib/components.lua")()
loadfile("/init/lib/gpu.lua")()
loadfile("/init/lib/term.lua")()
loadfile("/init/lib/fs.lua")()
for i=1,component.gpu.count do
  local t=term[i]
  t.write("hello, this is a demo of cul8ter's os multi gpu support, running on screen: "..i.."\n")
end
filesystem.mount(computer.getBootAddress(),"/")
term[1].write(computer.freeMemory().."\n")
for i,v in ipairs(term) do
  local t=v
  local dir="/"
  t.readAsync()
  local listener=function(_,buffer)
    local args={}
    for s in string.gmatch(buffer,"([^%s]+)") do
      table.insert(args,s)
    end
    local cmd=args[1] or buffer
    table.remove(args,1)
    --os.sleep(5)
    if cmd=="eval" then
      local worked,err=pcall(load("local t=... "..string.sub(buffer,6,-1)),t)
      if not worked then t.write(err) end
    elseif cmd=="cd" then
      dir=args[1]
    elseif cmd=="ls" then
      for _,file in pairs(filesystem.list(dir)) do
        t.write(file.."\n")
      end
    elseif cmd=="rm" then
      filesystem.remove(dir.."/"..args[1])
    elseif cmd=="exec" then
      filesystem.run(dir..args[1],table.unpack(args))
    else
      t.write("invalid command\n")
    end
    t.readAsync()
  end
  event.listen(listener,"term_read_done_"..tostring(t))
end
os.sleep(math.huge)
term[1].write("whyyyyyyyyyyyyyy")
while true do end