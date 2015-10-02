#! /usr/bin/env racket
#lang racket

(require (prefix-in sys/ racket/system))
(require (prefix-in cmd/ racket/cmdline))
(require (prefix-in str/ racket/string))
(require (prefix-in port/ racket/port))
(require (prefix-in aws/ "aws.rkt"))
(require (prefix-in ui/ "ui.rkt"))

(define verbose? (make-parameter #f))
(define name     (make-parameter null))

(define aws-command (find-executable-path "aws"))

(define cli
  (cmd/command-line #:once-each
                [("-v" "--verbose")   "Verbose mode" (verbose? #t)]
                [("-n" "--name")    n "Bucket/User name" (name n)]))

#;(let ([exe  "sleep"]
      [args "iam delete-user --cli-input-json file:///var/folders/ss/4qg3hk1d4nv40phg1360ng5w0000gn/T/-Users-martin-code-glitter-util.rkt-19-11_14433789321443378932679"])
  (let-values ([(p o i e) (subprocess #f #f #f (find-executable-path exe) "2" #;"delete-user")])
    (while (eq? 'running (subprocess-status p)
      (ui/line-loop "\rComputing [~a]" '("|" "/" "-" "\\")))
    (display "\n")
    (cond [(zero? (subprocess-status p))
           (display (read-string 1000 o))]
          [(positive? (subprocess-status p))
           (display (read-string 1000 e))]))))

;; (system "which ls")
;; (str/string-trim (port/with-output-to-string (lambda () (sys/system "which ls"))))

;; (

;; (aws "aws iam create-user"(hash 'UserName "martin"))
;; (aws "aws iam delete-user" (hash 'UserName "Bob"))

;; (printf "~a\n" (aws/policy (name)))
