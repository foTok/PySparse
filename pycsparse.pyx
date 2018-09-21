import scipy
from scipy import sparse

# --2010.06.01 Created by xialulee--
# --for Python 2.6.4--
# --xialulee.spaces.live.com--

cdef extern from "malloc.h":
    void * malloc(size_t size)
    void free(void * memblock)

cdef extern from "CSparse\src\csparse.h":
    struct cs_sparse:
        int nzmax
        int m
        int n
        int * p
        int * i
        double * x
        int nz
    struct cs_dmperm_results:
        int * P
        int * Q
        int * R
        int * S
        int nb
        int rr[5]
        int cc[5]
    cs_dmperm_results * cs_dmperm(cs_sparse * A)
    cs_dmperm_results * cs_dfree(cs_dmperm_results * D)

def dmperm(A):
    '''Dmperm has the same function as Matlab dmperm
    This function is a simple wrapper of CSparse cs_dmperm for Python.
    '''
    cdef cs_sparse spA
    # i: row indices
    cdef int * i
    # p: column pointers
    cdef int * p
    # x: values of non-zero elements
    cdef double * x
    # pres: a pointer indicates the location of the dmperm results
    cdef cs_dmperm_results * pres
    # nnz: number of non-zero elements
    cdef int nnz
    # m, n: size of matrix A. m: number of rows, n: number of columns
    cdef int m, n
    # k is a loop counter
    cdef int k

    # if A is NOT a csc_matrix, convert it
    if type(A) != scipy.sparse.csc.csc_matrix:
        A = sparse.csc_matrix(A)
    m, n = A.shape
    nnz = A.nnz
    i = <int*>malloc(sizeof(int)*nnz)
    p = <int*>malloc(sizeof(int)*(n+1))
    x = <double*>malloc(sizeof(double)*nnz)
    for k in range(nnz):
        i[k] = A.indices[k]
        x[k] = A.data[k]
    for k in range(n+1):
        p[k] = A.indptr[k]
    spA.i = i
    spA.p = p
    spA.x = x
    spA.m = m
    spA.n = n
    spA.nzmax = nnz
    spA.nz = -1
    pres = cs_dmperm(&spA)
    free(i)
    free(p)
    free(x)
    P = []
    Q = []
    R = []
    S = []
    rr = []
    cc = []
    for k in range(pres.nb+1):
        R.append(pres.R[k])
        S.append(pres.S[k])
    for k in range(m):
        P.append(pres.P[k])
    for k in range(n):
        Q.append(pres.Q[k])
    for k in range(5):
        rr.append(pres.rr[k])
        cc.append(pres.cc[k])
    cs_dfree(pres)
    return P, Q, R, S, cc, rr
