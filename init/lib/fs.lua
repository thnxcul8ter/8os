local mountPoints={}
filesystem={}
fs=filesystem
function filesystem.mount(comp,path)
	if not comp then return false,"i need args idiot" end
	if type(comp)=="string" then comp=component.proxy(comp) end
	if comp.type~="filesystem" then return false,"that's not a filesystem, how am i supposed to mount that?" end
	if not path then
		if comp.getLabel() then
			path="/mnt/"..comp.getLabel()
		else
			path="/mnt/"..string.sub(comp.getAddress(),1,10)
		end
	end
	mountPoints[path]=comp
end
local function getMounts(path)
	local start,end_,device=0,0
	for mpath,mdevice in pairs(mountPoints) do
		local foundStart,foundEnd=string.find(path,mpath)
		if (foundStart or 0)>start then start,end_=foundStart,foundEnd device=mdevice end
	end
	assert(device,"device is nil, why?")
	return device,string.sub(path,end_,-1)
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
	file.write=function(self,...) return drive.write(self.pointer,...) end
	file.read=function(self,...) return drive.read(self.pointer,...) end
	file.seek=function(self,...) return drive.seek(self.pointer,...) end
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
function filesystem.run(path,...)
	local f=filesystem.open(path)
	local ftext=f:read(math.maxinteger)
	return pcall(load(ftext),...)
end