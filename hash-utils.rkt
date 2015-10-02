#lang racket

;; https://github.com/DarrenN/racketutils

;; The MIT License (MIT)

;; Copyright (c) 2015 Darren_N

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;; Hash Utilities
;; ==============

;; hash-ref*
;; =========
;; recursively call hash-ref from a list of keys
;; example: (hash-ref* (hash 'a (hash 'b (hash 'c 2))) '(a b c)) -> 2
;;
(define (hash-ref* h keys #:failure-result [failure #f])
  (foldl (λ (k h)
           (if (hash? h)
               (if (hash-has-key? h k)
                   (hash-ref h k)
                   (if failure
                       failure
                       (raise-arguments-error 'hash-ref*
                                              "no value found for key"
                                              "key" k)))
               h))
         h keys))

;; hash-ref* tests
;; ===============
#; (module+ test
  (require rackunit
           quickcheck)

  (define foo (hash 'a 1
                    'b (hash 'bb 1
                             'cc (hash 'ccc 12))
                    'c "foo"))

  ;; Returns the first non-hash value
  (check-equal?
   (hash-ref* foo '(b bb ccc) #:failure-result 120) 1)

  ;; Fails and returns failure-result
  (check-equal?
   (hash-ref* foo '(b dd) #:failure-result "nope") "nope")

  ;; Gets value
  (check-equal?
   (hash-ref* foo '(b cc ccc)) 12)

  ;; Invalid keys raises exception
  (check-exn exn:fail? (λ () (hash-ref* foo '(b dd))))

  ;; Non-list raises exception
  (check-exn exn:fail? (λ () (hash-ref* foo "foo")))

  ;; Generate a hash from a list (must be non-empty) with a value of y
  (define (not-empty-hash xs y)
    (foldr (λ (l r)
             (hash-set r (first xs)
                       (hash l (hash-ref r (first xs)))))
           (hash (first xs) y)
           (rest xs)))

  ;; It will find a value in a validly-nested hash
  (define hash-ref-has-nest
    (property ([xs (arbitrary-list
                    arbitrary-ascii-char)]
               [y arbitrary-integer])
              (let* ([xss (if (empty? xs) '(1 2) xs)]
                     [hsh (not-empty-hash xss y)])
                (equal? (hash-ref* hsh xss) y))))

  (quickcheck hash-ref-has-nest)

  ;; It will not find a value in a validly-nested hash
  (define hash-ref-not-has-nest
    (property ([xs (arbitrary-list
                    arbitrary-ascii-char)]
               [z arbitrary-integer])
              (let* ([xss (if (empty? xs) (list (random 100) (random 100)) xs)]
                     [hsh (not-empty-hash xss z)])
                (not (equal? (hash-ref* hsh (cdr xss) #:failure-result "f") z)))))

  (quickcheck hash-ref-not-has-nest)

  ;; Passing en empty list will return the hash
  (define hash-ref-empty-list
    (property ([xs (arbitrary-list
                    arbitrary-ascii-char)]
               [y arbitrary-integer])
              (let* ([xss (if (empty? xs) '(1 2) xs)]
                     [hsh (not-empty-hash xss y)])
                (equal? (hash-ref* hsh '()) hsh))))

  (quickcheck hash-ref-empty-list))

;; Contracts

(provide (contract-out
          [hash-ref* (->* ((and/c hash? immutable?)
                           list?)
                          (#:failure-result any/c)
                          any/c)]))
