#lang racket

(require unstable/hash)
(require (prefix-in file/ racket/file))
(require (prefix-in list/ racket/list))

(provide (all-defined-out))

(define (any? pred lst)
  (ormap pred lst))

(define (df fmtstr . args)
  (displayln (apply format fmtstr args)))

(define (format-map fmtstr hmap)
  (for/fold ([str fmtstr])
            ([(k v) hmap])
    (regexp-replace (regexp (string-append "~" (symbol->string k))) str v)))

;(pregexp #px"\~[:alpha:]")
(define (keyword->symbol kw)
  (string->symbol (keyword->string kw)))

(define (zipmap keys vals)
  (for/fold
      ([h (hash)])
      ([k keys]
       [v vals])
    (hash-set h k v)))

(define (hash-filter f h)
  (for/fold ([hn (hash)])
            ([k  (hash-keys h)]
             [v  (hash-values h)])
    (if (f k v) (hash-set hn k v) hn)))

(define (hash-normalize h)
  (for/hash ([(k v) (in-hash h)]) (values k v)))

(define (hash-merge h1 h2)
  (hash-union (hash-normalize h1)
              (hash-normalize h2)
              #:combine (lambda (v1 v2) v2)))

(define (hash-select-keys h keys)
  (for/fold ([hnew (hash)])
            ([k    keys])
    (hash-set hnew k (hash-ref h k))))

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

(define (write-data relative-path data)
  (with-output-to-file
    (build-path (current-directory) relative-path)
    (lambda () (write data))
    #:exists 'truncate))

(define (read-data relative-path)
  (with-input-from-file
    (build-path (current-directory) relative-path)
    (lambda () (read))))
