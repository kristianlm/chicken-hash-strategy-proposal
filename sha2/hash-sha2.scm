;;;; sha2.scm

(declare (unit hash-sha2))

#>
#define SHA2_USE_INTTYPES_H 1
#define SHA2_USE_MEMSET_MEMCPY 1
#define SHA2_LITTLE_ENDIAN 1234
#define SHA2_BIG_ENDIAN    4321
#ifdef C_BIG_ENDIAN
# define SHA2_BYTE_ORDER SHA2_BIG_ENDIAN
#endif
#ifdef C_LITTLE_ENDIAN
# define SHA2_BYTE_ORDER SHA2_LITTLE_ENDIAN
#endif

#include "sha2.c"

#undef SHA2_LITTLE_ENDIAN
#undef SHA2_BIG_ENDIAN
#undef SHA2_BYTE_ORDER
#undef SHA2_USE_MEMSET_MEMCPY
#undef SHA2_USE_INTTYPES_H
<#

(module (hash sha256)
(digest-length init update! final!)
(import scheme
        (chicken base)
        (chicken foreign)
        (only (chicken blob) make-blob)
        (only (chicken memory representation) number-of-bytes)
        (only srfi-4 u8vector? u8vector-length)
        (only (chicken blob) blob?))

(define digest-length (foreign-value "SHA256_DIGEST_LENGTH" int))

(define-record sha256-ctx blob)
(define-foreign-type sha256-ctx (c-pointer "SHA256_CTX")
  (lambda (x) (sha256-ctx-blob x)))

(define (init)
  (let (($blob (location (make-blob (foreign-value "sizeof(SHA256_CTX)" int)))))
    ((foreign-lambda void "SHA256_Init" (c-pointer "SHA256_CTX")) $blob)
    (make-sha256-ctx $blob)))

(define (update! ctx data #!optional len)
  (cond ((or (string? data) (blob? data))
         ((foreign-lambda void SHA256_Update sha256-ctx scheme-pointer int)
          ctx data (number-of-bytes data)))
        ((u8vector? data)
         ((foreign-lambda void SHA256_Update sha256-ctx u8vector int)
          ctx data (u8vector-length data)))
        (else
         ((foreign-lambda void SHA256_Update sha256-ctx c-pointer int)
          ctx data len)))
  ctx)

(define (final! ctx #!optional (blob (make-blob digest-length)))
  (assert (= digest-length (number-of-bytes blob)))
  ((foreign-lambda void "SHA256_Final" sha256-ctx blob)
   ctx blob)
  blob)

)

(module (hash sha384)
(digest-length init update! final!)
(import scheme
        (chicken base)
        (chicken foreign)
        (only (chicken blob) make-blob)
        (only (chicken memory representation) number-of-bytes))

(define digest-length (foreign-value "SHA384_DIGEST_LENGTH" int))

(define-record sha384-ctx blob)
(define-foreign-type sha384-ctx (c-pointer "SHA384_CTX")
  (lambda (x) (sha384-ctx-blob x)))

(define (init)
  (let ((blob$ (location (make-blob (foreign-value "sizeof(SHA384_CTX)" int)))))
    ((foreign-lambda void "SHA384_Init" (c-pointer "SHA384_CTX")) blob$)
    (make-sha384-ctx blob$)))

(define (update! ctx str/blb)  
  ((foreign-lambda void SHA384_Update sha384-ctx scheme-pointer int)
   ctx str/blb (number-of-bytes str/blb))
  ctx)

(define (final! ctx #!optional (blob (make-blob digest-length)))
  (assert (= digest-length (number-of-bytes blob)))
  ((foreign-lambda void "SHA384_Final" sha384-ctx blob)
   ctx blob)
  blob)

)

(module (hash sha512)
(digest-length init update! final!)
(import scheme
        (chicken base)
        (chicken foreign)
        (only (chicken blob) make-blob)
        (only (chicken memory representation) number-of-bytes))

(define digest-length (foreign-value "SHA512_DIGEST_LENGTH" int))

(define-record sha512-ctx blob)
(define-foreign-type sha512-ctx (c-pointer "SHA512_CTX")
  (lambda (x) (sha512-ctx-blob x)))

(define (init)
  (let ((blob$ (location (make-blob (foreign-value "sizeof(SHA512_CTX)" int)))))
    ((foreign-lambda void "SHA512_Init" (c-pointer "SHA512_CTX")) blob$)
    (make-sha512-ctx blob$)))

(define (update! ctx str/blb)  
  ((foreign-lambda void SHA512_Update sha512-ctx scheme-pointer int)
   ctx str/blb (number-of-bytes str/blb))
  ctx)

(define (final! ctx #!optional (blob (make-blob digest-length)))
  (assert (= digest-length (number-of-bytes blob)))
  ((foreign-lambda void "SHA512_Final" sha512-ctx blob)
   ctx blob)
  blob)

)


