#lang racket

(provide ui-loop working done)

(require (prefix-in mat/ racket/match))

(struct ui-loop (format-str update update-interval done))

(define (working ui)
  (mat/match-let ([(ui-loop fmtstr update interval _) ui])
    (for ([s update])
    (display (format fmtstr s))
    (sleep interval))))

(define (done ui)
  (mat/match-let ([(ui-loop fmtstr _ _ done) ui])
    (displayln (format fmtstr done))))

#;(begin
  (working (ui-loop "\rxxx [~a]" '("|" "/" "-" "\\") 0.2 "x"))
  (done (ui-loop "\rxxx [~a]" '("|" "/" "-" "\\") 0.2 "x")))

;; begin class approach

(require racket/class)
(define ui-loop%
  (class object%
    (init-field format-str done updates
                [update-interval 0.2])
    (super-new)
    (define/public (working)
      (for ([s updates])
       (display (format format-str s))
       (sleep update-interval)))
    (define/public (finish)
      (displayln (format format-str done)))))

#;(begin
  (send (new ui-loop% [format-str "\rComputing [~a]"] [updates '("|" "/" "-" "\\")] [done "x"]) working)
  (send (new ui-loop% [format-str "\rComputing [~a]"] [updates '("|" "/" "-" "\\")] [done "x"]) finish))

;; end class approach

;; Previous approach but functions that return multiple values
;; can't be passed to other functions and then later be destructured
;; with let-values
(define (line-loop format-str loop-inputs done-input)
  (values
   (λ () (for ([s loop-inputs])
           (display (format format-str s))
           (sleep 0.2)))
   (λ () (displayln (format format-str done-input)))))

#;(let-values ([(working done) (line-loop "\rComputing [~a]" '("|" "/" "-" "\\") "x")])
  (working)
  (done))

;; https://github.com/hopkinsr/terminal-color

;; Feels like a lightweight approach but getting
;; struct fields can be very verbose
(require (prefix-in gen/ racket/generic))
(gen/define-generics progressable
    (working-p progressable)
    (done-p progressable))

(struct progress-loop (format-str update update-interval done)
  #:methods gen:progressable
  [(define (working-p p)
     (for ([s (progress-loop-update p)])
       (display (format (progress-loop-format-str p) s))
       (sleep (progress-loop-update-interval p))))
   (define (done-p p)
     (displayln (format (progress-loop-format-str p)
                        (progress-loop-done p))))])

#;(begin
  (working-p (progress-loop "\rComputing [~a]" '("|" "/" "-" "\\") 0.1 "x"))
  (done-p (progress-loop "\rComputing [~a]" '("|" "/" "-" "\\") 0.1 "x")))

;; end define-generics approach
