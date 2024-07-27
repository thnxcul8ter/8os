for addr,name in component.list() do
  local comp=component.proxy(addr)
  if component[name]==nil then
    component[name]=comp
    component[name].count=0
  end
  if not comp.address then comp.address=addr end
  component[name].count=component[name].count+1
  component[name][component[name].count]=comp
end
