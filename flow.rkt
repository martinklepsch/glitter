#lang racket

;; (require (prefix-in sys/ racket/system))
;; (require (prefix-in cmd/ racket/cmdline))
(require (prefix-in port/ racket/port))
(require (prefix-in list/ racket/list))
(require (prefix-in str/ racket/string))
(require (prefix-in mat/ racket/match))
(require (prefix-in ui/  "ui.rkt"))
(require (prefix-in util/ "util.rkt"))

(define-syntax-rule (while condition body ...)
  (let loop ()
    (when condition
      body ...
      (loop))))

(provide (all-defined-out))
;; (provide success failure process run-cmds)

(struct success (stdout))
(struct failure (code stderr))

(define (process cmd)
  (let* ([segs (str/string-split cmd)]
         [exe  (find-executable-path (list/first segs))]
         [args (list/rest segs)])
    (let-values ([(p o i e) (apply subprocess #f #f #f exe args)])
      (sync p)
      (cond [(zero? (subprocess-status p))
             (success (port/port->string o))]
            [(positive? (subprocess-status p))
             (failure (subprocess-status p)
                      (port/port->string e))]))))

;; (define (fp msg) (sleep 1) (+ 5 msg))

(define (workq task in out)
  (thread (λ () (let loop ()
                  (channel-put out (task (channel-get in)))
                  (loop)))))


(define (wait-for ch feedback)
  (let loop ()
    (mat/match (channel-try-get ch)
               [#f (ui/working feedback) (loop)]
               [v  (ui/done feedback) v])))

;; (define (add msg acc) (sleep 1) (displayln (format "received: ~a" msg)) (+ acc msg))
;; (define (additive-workq task start in out)
;;   (thread (λ () (let loop ((acc start))
;;                   (displayln (format "loop called with accumulator: ~a" acc))
;;                   (let ([result (task (channel-get in) acc)])
;;                     (channel-put out result)
;;                     (loop result))))))
;; (define worker (additive-workq add 0 process-in process-out))

;; (kill-thread worker)

(define in (make-channel))
(define out (make-channel))
(define worker (workq process in out))

(define (default-feedback n)
  (make-list n (ui/ui-loop "\rcomputing --------- [~a]" '("|" "/" "-" "\\") 0.2 "x")))

(define (run-cmds cmds
                  #:verbose [verbose #f]
                  #:feedbacks [feedbacks #f])
  (for/fold ([results '()])
            ([cmd  cmds]
             [fb   (or feedbacks (default-feedback (length cmds)))])
    (channel-put in cmd)
    (let ([result (wait-for out fb)])
      (cond [(success? result)
             (append results (list result))]
            [(failure? result)
             (begin
               (when verbose
                 (util/df "~a failed with ~a" cmd (failure-stderr result)))
               (append results (list result)))]))))

;; (begin
;;   (define process-in (make-channel))
;;   (define process-out (make-channel))
;;   (define worker (workq process process-in process-out))
;;   (for/fold ([done (hash)])
;;             ([x '("ls" "ls /" "ls /x")])
;;     (channel-put process-in x)
;;     (mat/match (wait-for process-out)
;;       [(success _) (hash-set done x success)]
;;       [(failure _ stderr) (displayln (format "~a failed with ~a" x stderr))])))

;; (for/fold ([res '()])
;;           ([x '(1 2 3 -2)])
;;   (if (negative? x)
;;       (display (format "failure. already ran: ~a" res))
;;       (cons x res)))
;; (for/fold ([sum 0]) ([i '(1 2 3 4)]) (+ sum i))
;; (channel-get process-out)

;; (process "sleep 4" null)
;; (displayln "test")

;; (define (stepper cmds feedback)
;;   (for ([cmd cmds])
;;     (let ([result (process cmd feedback)])
;;       (cond [(success? result) (display (success-stdout result))]
;;             [(failure? result) (begin (display (failure-stderr result))
;;                                       (error (format "Command failed: ~a" cmd)))]))))

;; (struct command (cmd stdout-parser))

;; (struct step (cmd label stdout-parser))

;; (define step1 (step "ls /" "Read root of filesystem" identity))
;; (define step2 (step "ls /nix" "Read /nix" identity))
;; (define step3 (step "ls /Users/martin" "Read home dir" identity))

;; (success-stdout (process "ls /" null))
;; (stepper '("ls /" "ls /x") (ui/ui-loop "\rComputing [~a]" '("|" "/" "-" "\\") 0.2 "x"))
