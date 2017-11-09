#include "AutoTune.h"
#include "IndexIVFPQ.h"
using namespace std;
using namespace faiss;

extern "C" Index *faiss_index_factory(int d, const char *description_in,
                                      int metric) {
  MetricType me;
  if (metric == 0)
    me = METRIC_INNER_PRODUCT;
  else
    me = METRIC_L2;
  return faiss::index_factory(d, description_in, me);
}

/* extern "C" void faiss_index_free(Index *p) { */
/*   printf(typeid(p).name()); */
/*   p->~IndexIVF(); */
/* } */
extern "C" void faiss_index_train(Index *p, int64_t n, const float *x) {
  Index::idx_t m;
  m = (Index::idx_t)n;
  p->train(m, x);
}

extern "C" void faiss_index_add(Index *p, int64_t n, const float *x) {
  p->add(n, x);
}

extern "C" void faiss_index_search(Index *p, int64_t n, float *x, int64_t k,
                                   float *D, int64_t *I) {
  p->search(n, x, k, D, I);
}
