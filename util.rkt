#lang racket

(require (prefix-in file/ racket/file))
(require (prefix-in list/ racket/list))

(provide df assoc hash-ref-in keyword->symbol string->file)

(define (df fmtstr . args)
  (displayln (apply format fmtstr args)))

(define (keyword->symbol kw)
  (string->symbol (keyword->string kw)))

(define (hash-ref-in h path)
  (let ([current (hash-ref h (list/first path))]
        [pathr   (list/rest path)])
    (if (list/empty? pathr) current (hash-ref-in current pathr))))

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
