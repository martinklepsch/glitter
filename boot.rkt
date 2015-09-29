#lang racket/base

(define (task fn)
  (λ (next-task)
    (λ (data)
      (next-task (fn data)))))

(define pipe
  (compose1 (task (λ (d) (hash-set d 'x 1)))
            (task (λ (d) (hash-set d 'y 2)))
            (task (λ (d) (hash-set d 'z 3)))))

(define (boot composed-tasks initial)
  ((composed-tasks (λ (data) (display data))) initial))

;; these two are equivalent
;; (boot pipe (hash 'b 0))
;; ((pipe (λ (d) (display d))) (hash 'b 0))

