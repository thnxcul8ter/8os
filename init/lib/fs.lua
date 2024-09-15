local mountPoints={}
filesystem={}
fs=filesystem
function filesystem.mount(comp,path)
	if not comp then return false,"i need args idiot" end
	if type(comp)=="string" then comp=component.proxy(comp) end
	if comp.type~="filesystem" then return false,"that's not a filesystem, how am i supposed to mount that?" end
	if not path then
		local name
		if comp.getLabel() then
			name=comp.getLabel()
		else
			name=string.sub(comp.address,1,3)
		end
		filesystem.mkdir("/mnt/"..name)
		path="/mnt/"..name
	end
	term[1].write('mounted "'..(comp.getLabel() or comp.address)..'" at "'..path..'"\n')
	mountPoints[path]=comp
end
local function getMounts(path)
	local start,end_,device=0,0
	for mpath,mdevice in pairs(mountPoints) do
		local foundStart,foundEnd=string.find(path,mpath)
		term[1].write(tostring(mpath).." "..tostring(foundStart).." "..tostring(foundEnd).."\n")
		if (foundEnd or 0)>end_ then start,end_=foundStart,foundEnd device=mdevice end
	end
	assert(device,"device is nil, why?")
	term[1].write(string.sub(path,end_,-1).."\n")
	return device,string.sub(path,end_+1,-1)
end
function filesystem.list(path)
	drive,path=getMounts(path)
	return drive.list(path)
end
function filesystem.open(path,mode)
	drive,path=getMounts(path)
	local rfile=drive.open(path,mode)
	local file={}
	file.pointer=rfile
	file.read=function(self,...) return drive.read(self.pointer,...) end
	file.seek=function(self,...) return drive.seek(self.pointer,...) end
	file.write=function(self,...) return drive.write(self.pointer,...) end
	file.close=function(self,...) return drive.close(self.pointer,...) end
	return file
end
function filesystem.makeDirectory(path)
	drive,path=getMounts(path)
	return drive.makeDirectory(path)
end
filesystem.mkdir=filesystem.makeDirectory
function filesystem.exists(path)
	drive,path=getMounts(path)
	return drive.exists(path)
end
function filesystem.rename(path)
	drive,path=getMounts(path)
	return drive.rename(path)
end
function filesystem.remove(path)
	drive,path=getMounts(path)
	return drive.remove(path)
end
function filesystem.lastModified(path)
	drive,path=getMounts(path)
	return drive.lastModified(path)
end
function filesystem.isDirectory(path)
	drive,path=getMounts(path)
	return drive.isDirectory(path)
end
function filesystem.size(path)
	drive,path=getMounts(path)
	return drive.size(path)
end
function filesystem.run(path,args,a,env)
	local f=filesystem.open(path)
	local ftext=f:read(math.maxinteger)
	assert(type(ftext)=="string")
	return pcall(load(ftext,a,env),table.unpack(args))
end


filesystem.mount(computer.getBootAddress(),"/")
filesystem.mount(computer.tmpAddress(),"/mnt")