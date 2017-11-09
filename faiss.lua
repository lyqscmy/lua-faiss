local ffi=require 'ffi'
ffi.load('faiss', true)
ffi.cdef[[
typedef struct Index Index;
Index *faiss_index_factory(int d, const char *description_in, int metric);
void faiss_index_free(Index *p);
Index *faiss_read_index(const char *fname);
void faiss_write_index(const Index *idx, const char *fname);
void faiss_index_train(Index *p, int64_t n, const float *x);
void faiss_index_add(Index *p, int64_t n, const float *x);
void faiss_index_search(Index *p, int64_t n, float *x, int64_t k, float *D, int64_t *I);
]]

-- WARRING:only for IndexIVFPQ
local _M = {}
local mt = { __index = _M }

function _M.index_factory(self, d, description_in, metric)
	local index = ffi.C.faiss_index_factory(d, description_in, metric)
	ffi.gc(index, ffi.C.faiss_index_free)
	return setmetatable({index=index, d=d, metric=metric}, mt)
end

function _M.read_index(self, fname, d)
	local index = ffi.C.faiss_read_index(fname)
	return setmetatable({index=index, d = d}, mt)
end

function _M.write_index(self, index, fname)
	ffi.C.faiss_write_index(index, fname)
end

function _M.train(self, nb, xb)
	ffi.C.faiss_index_train(self.index, nb, xb)
end

function _M.add(self, nb, xb)
	ffi.C.faiss_index_add(self.index, nb, xb)
end

function _M.search(self, nq, xq, k)
	local distances = ffi.new("float [?]",nq*self.d)
	local lables = ffi.new("int64_t [?]",nq*self.d)
	ffi.C.faiss_index_search(self.index, nq, xq, k, distances, lables)
	return distances, lables
end

return _M
