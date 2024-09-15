local shutdown=computer.shutdown
local initstate={}
local worked,err,timestamp
local function tablewalk(t,store)
  for k,v in pairs(t) do
    if type(v)=="table" and k~="_G" then
      store[k]={}
      tablewalk(v,store[k])
    else
      store[k]=true
    end
  end
end
local function reset(t,store)
  for k,v in pairs(t) do
    if store[k] then
      if type(v)=="table" and k~="_G" then
        reset(v,store[k])
      end
    else
      t[k]=nil
    end
  end
end

do
tablewalk(_G,initstate)
local fs=component.proxy(computer.getBootAddress())
local function loadfile(path)
  local handle=fs.open(path)
  assert(handle, "file open failed")
  local file=""
  repeat
    local data=fs.read(handle,math.maxinteger)
    file=file..(data or "")
  until not data
  assert(file, "read failed")
  local func=load(file)
  assert(func, "load failed, tried to load: "..file)
  return func
end
--loadfile("/init/bootstrap.lua")(loadfile)
repeat
  timestamp=computer.uptime()
  worked,err=pcall(loadfile("/init/bootstrap.lua"),loadfile,err)
  reset(_G,initstate)
until computer.uptime()-timestamp<3
if not worked then error(err) end
end
shutdown()