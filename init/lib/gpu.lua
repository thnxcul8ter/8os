if not component.screen then error("this os needs a screen idiot") end
if not component.gpu then error("this os needs a gpu idiot") end
for i=1,component.gpu.count do
  if i>component.screen.count then break end
  local gpu=component.gpu[i]
  assert(gpu,"gpu failed")
  assert(type(component.screen[i].address)=="string","screen failed")
  gpu.bind(component.screen[i].address)
  local mx,my=gpu.maxResolution()
  gpu.setResolution(mx,my)
  gpu.fill(1,1,mx,my," ")
end
