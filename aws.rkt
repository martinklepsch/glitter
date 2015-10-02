#lang racket

(require unstable/hash)
(require (prefix-in mat/  racket/match))
(require (prefix-in list/ racket/list))
(require (prefix-in port/ racket/port))
(require (prefix-in sys/  racket/system))
(require (prefix-in json/ json))
(require "hash-utils.rkt")
(require (prefix-in flow/ "flow.rkt"))
(require (prefix-in util/ "util.rkt"))


(provide statement policy); create-user create-access-key attach-inline-policy make-bucket)

(define (statement effect action resource)
  (hash 'Effect effect 'Action action 'Resource resource))

(define (policy name)
  (let ([bucket-arn   (string-append "arn:aws:s3:::" name)]
        [contents-arn (string-append "arn:aws:s3:::" name "/*")])
    (hash 'Version "2012-10-17"
          'Statement (list
                      (statement "Allow" '("s3:ListBucket") (list bucket-arn))
                      (statement "Allow" '("*") (list contents-arn))))))

(define aws-commands
  (hash 'create-user (hash 'cmd           "iam create-user"
                           'required-opts '(UserName)
                           'opposite      'delete-user)
        'delete-user (hash 'cmd           "iam delete-user"
                           'required-opts '(UserName)
                           'opposite      'create-user)))

;; (aws-new 'create-user (hash 'UserName "x"))
(define (aws command opts)
  (let ([cmd (hash-set (hash-ref aws-commands command) 'opts opts)])
    (aws-validate cmd)))

;; (aws-reverse (aws-new 'create-user (hash 'UserName "x")))
(define (aws-reverse command)
  ;; Return the reverse command of the given command
  ;; Useful in scenarios where some commands worked
  ;; but then one failed and others need to be rolled back
  (let ([rev  (hash-ref aws-commands (hash-ref command 'opposite))]
        [opts (hash-ref command 'opts)])
    (hash-set rev 'opts opts)))

(define (any? pred lst)
  (ormap pred lst))

;; (aws-validate (aws-new 'create-user (hash 'serName "x")))
(define (aws-validate command)
  (let* ([reqs (hash-ref command 'required-opts)]
         [vals (map (λ (o) (hash-ref* command (list 'opts o) #:failure-result null)) reqs)])
    (if (any? null? vals)
        (begin (displayln "Command invalid:")
               (util/df "Required options: ~a" reqs)
               (util/df "Given options: ~a\n~a" (hash-keys (hash-ref command 'opts)) vals))
        command)))

(define (make-cli-json mapping)
  (string-append " --cli-input-json file://"
                 (util/string->file (json/jsexpr->string mapping))))

;; (aws-run! (awscli 'create-user (hash 'UserName "x")))
(define (aws->shell awscli-cmd)
  (let ([cmd  (hash-ref awscli-cmd 'cmd)]
        [opts (hash-ref awscli-cmd 'opts)])
    (string-append "aws " cmd (make-cli-json opts))))

;; (aws->shell (awscli 'delete-user (hash 'UserName "x")))

;; (define (get-skeleton cmd)
;;   (let ([cmd (string-append cmd " --generate-cli-skeleton")])
;;     (json/string->jsexpr (port/with-output-to-string (lambda () (sys/system cmd))))))

;; (hash-keys (get-skeleton "aws iam create-user"))

;; (define (aws cmd mapping)
;;   (let ([input-json (make-cli-json cmd mapping)])
;;     (string-append cmd " --cli-input-json file://" input-json)))

;; (get-skeleton "iam create-access-key")
;; (make-cli-json "iam create-access-key" (hash 'UserName "x"))

;; (define (create-access-key user-name)
;;   (string-append "aws iam create-access-key --user-name " user-name))

;; (define (attach-inline-policy user-name policy-name policy-file)
;;   (string-append "aws iam put-user-policy"
;;                  " --user-name " user-name
;;                  " --policy-name " policy-name
;;                  " --policy-document file://" policy-file))

;; (define (make-bucket bucket-name)
;;   (string-append "aws s3 mb s3://" bucket-name))
