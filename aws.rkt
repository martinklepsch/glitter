#lang racket

(require (prefix-in mat/  racket/match))
(require (prefix-in list/ racket/list))
(require (prefix-in port/ racket/port))
(require (prefix-in sys/  racket/system))
(require (prefix-in json/ json))
(require "hash-utils.rkt")
(require (prefix-in flow/ "flow.rkt"))
(require (prefix-in util/ "util.rkt"))
(require (prefix-in ui/   "ui.rkt"))


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
  (hash
   ;; User management
   'create-user   (hash 'cmd           "iam create-user"
                        'label         "Creating User"
                        'type          'cli-json
                        'required-opts '(UserName)
                        'reverse       'delete-user)
   'delete-user   (hash 'cmd           "iam delete-user"
                        'label         "Deleting User"
                        'type          'cli-json
                        'required-opts '(UserName)
                        'reverse       'create-user)
   ;; Inline Policies
   'put-user-policy    (hash 'cmd           "iam put-user-policy"
                             'label         "Adding Inline Policy"
                             'type          'cli-json
                             'required-opts '(UserName PolicyName PolicyDocument)
                             'reverse       'delete-user-policy)
   'delete-user-policy (hash 'cmd           "iam delete-user-policy"
                             'label         "Deleting Inline Policy"
                             'type          'cli-json
                             'required-opts '(UserName PolicyName)
                             'reverse       'put-user-policy)
   ;; Access Keys
   'create-access-key (hash 'cmd           "iam create-access-key"
                            'label         "Adding Access Key"
                            'type          'cli-json
                            'required-opts '(UserName)
                            'reverse       'delete-access-key)
   'delete-access-key (hash 'cmd           "iam delete-access-key"
                            'label         "Deleting Access Key"
                            'type          'cli-json
                            'required-opts '(UserName AccessKeyId)
                            'reverse       'create-access-key)
   ;; Buckets
   'create-bucket (hash 'cmd           "s3 mb s3://~BucketName"
                        'label         "Creating S3 Bucket"
                        'type          'format
                        'opts          '(BucketName)
                        'required-opts '(BucketName)
                        'reverse       'delete-bucket)
   'delete-bucket (hash 'cmd           "s3 rb s3://~BucketName"
                        'label         "Deleting S3 Bucket"
                        'type          'format
                        'opts          '(BucketName)
                        'required-opts '(BucketName)
                        'reverse       'create-bucket)))

;; (aws 'create-user (hash 'UserName "x"))
(define (aws command opts)
  (let ([cmd (hash-set (hash-ref aws-commands command) 'opts opts)])
    (aws-validate cmd)))

(define (parse-success s)
  (let ([so (flow/success-stdout s)])
    (if (and (> (string-length so) 0)
             (eq? #\{ (string-ref so 0)))
        (first (hash-values (json/string->jsexpr so)))
        (hash))))

;(parse-success (first (hash-values results)))

;; (aws-reverse (aws-new 'create-user (hash 'UserName "x")))
(define (aws-reverse command prev-result)
  ;; Return the reverse command of the given command
  ;; Useful in scenarios where some commands worked
  ;; but then one failed and others need to be rolled back
  (let* ([to-merge      (mat/match prev-result
                                   [(? flow/success? s) (parse-success s)]
                                   [(? flow/failure? f) (hash)])]
         [reversed      (hash-ref aws-commands (hash-ref command 'reverse))]
         [required      (hash-ref reversed 'required-opts)]
         [original-opts (hash-ref command 'opts)]
         [merged-opts   (util/hash-merge original-opts to-merge)])
    (aws-validate
     (hash-set reversed 'opts (util/hash-select-keys merged-opts required)))))


;; (aws-validate (aws-new 'create-user (hash 'serName "x")))
(define (aws-validate command)
  (let* ([reqs (hash-ref command 'required-opts)]
         [vals (map (λ (o) (hash-ref* command (list 'opts o) #:failure-result null)) reqs)])
    (if (util/any? null? vals)
        (begin (displayln "Command invalid:")
               (util/df "Required options: ~a" reqs)
               (util/df "Given options: ~a\n~a" (hash-keys (hash-ref command 'opts)) vals))
        command)))

(define (make-cli-json mapping)
  (string-append " --cli-input-json file://"
                 (util/string->file (json/jsexpr->string mapping))))

;; (aws->shell (aws 'delete-user (hash 'UserName "x")))
;; (aws->shell (aws 'create-bucket (hash 'BucketName "x")))
(define (aws->shell awscli-cmd)
  (let ([cmd  (hash-ref awscli-cmd 'cmd)]
        [type (hash-ref awscli-cmd 'type)]
        [opts (hash-ref awscli-cmd 'opts)])
    (string-append "aws --output json "
                   (cond [(eq? 'cli-json type) (string-append cmd (make-cli-json opts))]
                         [(eq? 'format type)   (util/format-map cmd opts)]))))

(define (aws-feedback cmd)
  (ui/ui-loop (string-append "\r[~a] " (hash-ref cmd 'label))
              '("|" "/" "-" "\\") 0.2 "x"))

  ;(make-list n(ui/ui-loop "\rComputing --------- [~a]" '("|" "/" "-" "\\") 0.2 "x")))

(define (aws-runner aws-cmds)
  (flow/run-cmds (map aws->shell aws-cmds)
                 #:feedbacks (map aws-feedback aws-cmds)
                 #:verbose #t))

(define sample-up
  (let* ([name "my-project-sf4r34rf13edsdf"]
         [policy-name (string-append name "-S3FullAccess")])
    (list (aws 'create-user (hash 'UserName name))
          (aws 'put-user-policy (hash 'UserName name
                                      'PolicyName policy-name
                                      'PolicyDocument (json/jsexpr->string (policy name))))
          (aws 'create-access-key (hash 'UserName name))
          (aws 'create-bucket (hash 'BucketName name)))))

(define (aws-save-cmds aws-cmds)
  ())

(define (report results)
  (let ([bucket-name (hash-ref (parse-success (first results)) 'UserName)]
        [secret-key  (hash-ref (parse-success (third results)) 'SecretAccessKey)]
        [access-key  (hash-ref (parse-success (third results)) 'AccessKeyId)])
    (displayln (make-string 75 #\-))
    (util/df "You can now use the bucket ~a:" bucket-name)
    (util/df "AccessKey: ~a" access-key)
    (util/df "SecretKey: ~a" secret-key)))

(report results)
(define results
  (aws-runner sample-up))

(parse-success (third results))
(define (reversed)
  (map aws-reverse (reverse sample-up) (reverse results)))
(aws-runner (reversed))

;; (define reversed-results
;;   (aws-runner (reversed)))
;(aws-reverse (aws 'put-user-policy (hash 'UserName "x" 'PolicyName "x" 'PolicyDocument "x")))
;; (define sample-down
;;   (let* ([name "my-project"]
;;          [policy-name (string-append name "-S3FullAccess")])
;;     (map aws-reverse
;;          (reverse (list
;;                    (aws 'create-user (hash 'UserName name))
;;                    (aws 'put-user-policy (hash 'UserName name 'PolicyName policy-name 'PolicyDocument (json/jsexpr->string (policy name))))
;;                   ;;(aws 'create-access-key (hash 'UserName name))
;;                   ;;(aws 'create-bucket (hash 'BucketName name)))
;;                   )))))

;; (define (get-skeleton cmd)
;;   (let ([cmd (string-append cmd " --generate-cli-skeleton")])
;;     (json/string->jsexpr (port/with-output-to-string (lambda () (sys/system cmd))))))

;; (define (make-bucket bucket-name)
;;   (string-append "aws s3 mb s3://" bucket-name))
