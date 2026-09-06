-- Timer class
------------------------------------------------

local Timer = {}
Timer.__index = Timer

function Timer.new(duration, cyclic, callbacks)
	callbacks = callbacks or {}

	local self = setmetatable({
		started 	  = false,
		cur_time 	  = 0,
		duration 	  = duration or 0,
		cyclic 		  = cyclic,
		tick_callback = callbacks.tick_callback,
		tick_callback_data = callbacks.tick_callback_data,
		end_callback 	   = callbacks.end_callback,
		end_callback_data  = callbacks.end_callback_data
	}, Timer)

	return self
end

function Timer:start(duration)
	self.cur_time = 0
	self.duration = duration or self.duration
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