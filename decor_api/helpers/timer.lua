-- Timer class
------------------------------------------------

local Timer = {
	started = false,
	cur_time = 0,
	duration = 0,
    cyclic = false,
    tick_callback = nil,
    tick_callback_data = nil,
	end_callback = nil,
	end_callback_data = nil
}

Timer.__index = Timer

function Timer.new(_duration, _cyclic, callbacks)
	local self = setmetatable({}, Timer)
	self.duration = _duration
	self.cyclic = _cyclic
	self.end_callback = callbacks.end_callback
	self.end_callback_data = callbacks.end_callback_data
	self.tick_callback = callbacks.tick_callback
	self.tick_callback_data = callbacks.tick_callback_data

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

function Timer:reset()
    self.cur_time = 0
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

    if self.tick_callback then
        self.tick_callback(self.tick_callback_data)
    end

	if self.cur_time >= self.duration then
        if self.cyclic then
            self:reset()
        else
            self:stop()
        end

		if self.end_callback then
			self.end_callback(self.end_callback_data)
		end
	end
end

return Timer