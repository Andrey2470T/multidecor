-- Timer class
------------------------------------------------

local Timer = {
	started = false,
	cur_time = 0,
	duration = 0,
	callback = nil,
	callback_data = nil
}

Timer.__index = Timer

function Timer.new(_duration, _callback, _callback_data)
	local self = setmetatable({}, Timer)
	self.duration = _duration
	self.callback = _callback
	self.callback_data = _callback_data

	return self
end

function Timer:start(_duration)
	self.cur_time = 0
	self.duration = _duration or self.duration
	self.started = true
end

function Timer:stop()
	self.started = false
end

function Timer:is_started()
	return self.started
end

function Timer:cur_time()
	return self.cur_time
end

function Timer:tick(dtime)
	if not self.started then return end

	self.cur_time = self.cur_time + dtime

	if self.cur_time >= self.duration then
		self:stop()

		if self.callback then
			self.callback(self.callback_data)
		end
	end
end

return Timer