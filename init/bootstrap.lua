local args={...}
local loadfile=args[1]
local crash=args[2]
_OSVER=0.3
loadfile("/init/lib/event.lua")()
loadfile("/init/lib/components.lua")()
loadfile("/init/lib/gpu.lua")()
loadfile("/init/lib/term.lua")()
loadfile("/init/lib/fs.lua")()
for i=1,component.gpu.count do
  local t=term[i]
  t.write("hello, this is a demo of cul8ter's os multi gpu support, running on screen: "..i.."\n")
end
term[1].write(computer.freeMemory().."\n")
if crash then
  term[1].write("last crash reason:\n"..crash.."\n")
end
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
      local worked,err=pcall(load(string.sub(buffer,6,-1)),nil,"t",_ENV)
      if not worked then t.write(err) end
    elseif cmd=="cd" then
      dir=args[1]
    elseif cmd=="ls" then
      if fs.exists(args[1] or dir) then
        local list,err=filesystem.list(args[1] or dir)
        for _,file in pairs(list) do
          t.write(file.."\n")
        end
      else
        t.write("that dont exist lol\n")
      end
    elseif cmd=="rm" then
      filesystem.remove(dir.."/"..args[1])
    elseif cmd=="exec" then
      filesystem.run(dir..args[1],args,"t",_ENV)
    elseif cmd=="mkdir" then
      filesystem.mkdir(dir..args[1])
    else
      t.write("invalid command\n")
    end
    t.readAsync()
  end
  event.listen(listener,"term_read_done_"..tostring(t))
end
os.sleep(math.huge)
term[1].write("whyyyyyyyyyyyyyy")
while true do event.pull() end