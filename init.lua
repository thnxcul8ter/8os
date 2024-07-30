local shutdown=computer.shutdown
do
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
loadfile("/init/bootstrap.lua")(loadfile)
end
shutdown()
