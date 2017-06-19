local syslog = {}

function syslog.write(data)
	file = io.open("/syslog.log", "a")
	io.output(file)
	io.write(data .. "\n")
	io.close() 
	io.output(io.stdout)
end

return syslog

