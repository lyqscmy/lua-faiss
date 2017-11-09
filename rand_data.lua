local ffi = require "ffi"
ffi.load('gjrand',true)

ffi.cdef[[
struct foo;
struct gjrand {uint64_t a, b, c, d;};
void gjrand_init(struct gjrand *s, uint32_t x);
long gjrand_rand(struct gjrand *state);
uint32_t gjrand_rand32mod(struct gjrand *state, uint32_t m);
double gjrand_drand(struct gjrand *state);
void gjrand_frandv(struct gjrand *state, int n, float *v);
double gjrand_normal(struct gjrand *state);
void gjrand_sample(struct gjrand *state, int size, unsigned n,
		const void *src, unsigned k, void *a);
]]

local _M = {}
local mt = { __index = _M }

local gjrand_t = ffi.typeof("struct gjrand")
-- 31bit random int
function _M.userID(self, user_num)
	return tonumber(ffi.C.gjrand_rand32mod(self.gj, user_num))
end

function _M.rand32mod(self, m)
	return tonumber(ffi.C.gjrand_rand32mod(self.gj, m))
end
function _M.newsID(self)
	return tonumber(ffi.C.gjrand_rand(self.gj))
end
-- Return a uniform random number in (0.0 .. 1.0).
function _M.weight(self)
	return ffi.C.gjrand_drand(self.gj)
end


local chartset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
local k = 20

function _M.tag(self)
	local buf = ffi.new("uint8_t[?]", k)
	-- print(self.gj, #chartset, chartset, k, buf)
	ffi.C.gjrand_sample(self.gj, 1, #chartset, chartset, k, buf)
	return ffi.string(buf, k)
end

function _M.drandv(self, n)
	local buf = ffi.new("double[?]", n)
	ffi.C.gjrand_drandv(self.gj, n, buf)
	return buf
end

function _M.frandv(self, n)
	local buf = ffi.new("float[?]", n)
	ffi.C.gjrand_frandv(self.gj, n, buf)
	return buf
end

function _M.new(self,seed)
	local gj = ffi.new(gjrand_t)
	ffi.C.gjrand_init(gj, seed)
	return setmetatable({gj = gj}, mt)
end

return _M

