event={}
timers={}
local handlers={}
event.register=function(func,evname)
  if evname==nil or func==nil then
    return false,"invalid args"
  end
  handlers[func]=evname
end
event.unregister=function(func,evname)
  if handlers[func] and (handlers[func]==evname or evname==nil) then
    handlers[func]=nil
  end
end
event.pull=function(name,maxtries)
  local ev
  local i=0
  repeat
    i=i+1
    local time=computer.uptime()
    for i,v in ipairs(timers) do
      if v <= time then
        table.remove(timers,i)
        event.push("timer_"..v)
      end
    end
    ev=table.pack(computer.pullSignal(0))
    for k,v in pairs(handlers) do
      if v==ev[1] then
        k(table.unpack(ev))
      end
      if ev[1] and ev[1]~=name and string.sub(ev[1],1,6)=="timer_" then
        event.push(table.unpack(ev))
      end
      if maxtries and i>maxtries then return false,"max tries reached" end
    end
  until ev[1]==name or name==nil
  return table.unpack(ev)
end
event.push=computer.pushSignal
function os.sleep(time)
  local wtime=computer.uptime()+time
  table.insert(timers,wtime)
  event.pull("timer_"..wtime)
end
event.listen=event.register
event.ignore=event.unregister