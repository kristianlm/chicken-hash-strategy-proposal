(module hash (hash-update-port
              hash-update-filename)

(import scheme
        (chicken base)
        (only (chicken io) read-string)
        (only (chicken port) port-for-each)
        (only (chicken file) file-exists?)
        (only (chicken file posix)
              file-close file-open file-size
              open/rdonly
              directory?)
        (only memory-mapped-files
              memory-mapped-file-pointer
              unmap-file-from-memory
              map-file-to-memory
              map/shared prot/read))

(define (hash-update-port c update! #!optional
                          (chunk-size 1024)
                          (port (current-input-port)))
  (port-for-each (lambda (str) (update! c str))
                 (lambda () (read-string chunk-size)))
  c)

(cond-expand
 ((and windows (not cygwin))
  (begin
    (define read-into-buffer
      (foreign-lambda* bool ((int fd) (c-pointer buffer) (integer size))
	               "C_return(read(fd, buffer, size) == size);"))
    (define (mapped-pointer fname fd size k)
      (let ((buffer (allocate size)))
	(unless (read-into-buffer fd buffer size)
	  (free buffer)
	  (error 'sha1sum "can not read file" fname))
	(k buffer (cut free buffer))))))
 (else
  (define (mapped-pointer fname fd size k)
    (let* ((mmap (map-file-to-memory #f size prot/read map/shared fd))
	   (ptr (memory-mapped-file-pointer mmap)))
      (k ptr (cut unmap-file-from-memory mmap))))))

(define (hash-update-filename ctxt update! fname)
  (and (file-exists? fname)
       (not (directory? fname))
       (let* ((fd (file-open fname open/rdonly))
	      (fsize (file-size fd)))
	 (unless (zero? fsize)
           (print "fsize=" fsize)
	   (mapped-pointer
	    fname fd fsize
	    (lambda (buffer cleanup)
	      (update! ctxt buffer fsize)
	      (cleanup))))
	 (file-close fd)
         ctxt)))
)
