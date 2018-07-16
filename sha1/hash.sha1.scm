(module (hash sha1) (digest-length init update! final! string->hash)
(import scheme
        (chicken base)
        (chicken foreign)
        (only (chicken blob) make-blob)
        (only (chicken memory representation) number-of-bytes)
        (only srfi-4 u8vector? u8vector-length)
        (only (chicken blob) blob?))

#>
#include "sha1.c"
<#

(define digest-length (foreign-value "SHA1_DIGEST_LENGTH" int))

(define-record sha1-ctx blob)
(define-foreign-type sha1-ctx (c-pointer "SHA1_CTX")
  (lambda (x) (sha1-ctx-blob x)))

(define (init)
  (let (($blob (location (make-blob (foreign-value "sizeof(SHA1_CTX)" int)))))
    ((foreign-lambda void "SHA1Init" (c-pointer "SHA1_CTX")) $blob)
    (make-sha1-ctx $blob)))

(define (update! ctx data #!optional len)
  (cond ((or (string? data) (blob? data))
         ((foreign-lambda void "SHA1Update" sha1-ctx scheme-pointer int)
          ctx data (number-of-bytes data)))
        ((u8vector? data)
         ((foreign-lambda void "SHA1Update" sha1-ctx u8vector int)
          ctx data (u8vector-length data)))
        (else
         ((foreign-lambda void "SHA1Update" sha1-ctx c-pointer int)
          ctx data len)))
  ctx)

(define (final! ctx #!optional (blob (make-blob digest-length)))
  (assert (= digest-length (number-of-bytes blob)))
  ((foreign-lambda void "SHA1Final" sha1-ctx blob)
   ctx blob)
  blob)

(define (string->hash str)
  (final! (update! (init) str)))

)
