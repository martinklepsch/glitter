#lang racket/base

(require (prefix-in file/ racket/file))

(provide assoc keyword->symbol string->file)

(define (keyword->symbol kw)
  (string->symbol (keyword->string kw)))

(define assoc
  (make-keyword-procedure
   (lambda (kws kw-args m)
     (foldl (lambda (k v m) (hash-set m k v))
            m
            (map keyword->symbol kws)
            kw-args))))

(define (string->file str)
  (let ([f (file/make-temporary-file)])
    (file/display-to-file str f #:exists 'truncate)
    (path->string f)))

;; (file:file->string (string->file "xxx"))
;; (path->string (string->file "xxx"))

;; (make-temporary-file)
;; (make-temporary-file)
