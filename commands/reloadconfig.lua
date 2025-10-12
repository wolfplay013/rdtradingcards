local command = {}
function command.run(message, mt)
	if message and not isauthoradmin(message) then
		message.channel:send("haha no, nice try")
		return
	end
	_G["config"] = dofile('config.lua')
	print("done configing")
	
	if message then
		message.channel:send('Config has been reloaded.')
	end
end
return command
