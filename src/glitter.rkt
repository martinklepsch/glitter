#! /usr/bin/env racket
#lang racket

(require (prefix-in cmd/ racket/cmdline))
(require (prefix-in util/ "util.rkt"))
(require (prefix-in aws/ "aws.rkt"))

(define verbose? (make-parameter #f))
(define name     (make-parameter #f))
(define rollback (make-parameter #f))

(define aws-command (find-executable-path "aws"))

(define cli
  (cmd/command-line #:once-each
                [("-v" "--verbose")    "Verbose mode" (verbose? #t)]
                [("-n" "--new")      n "Bucket/User name" (name n)]
                [("-r" "--rollback") f "File to run rollback from" (rollback f)]))

;; (define (brand)
;;   (writeln "")
;;   (writeln "          .---.                                                   ")
;;   (writeln "          |   |.--.                        __.....__              ")
;;   (writeln "  .--./)  |   ||__|                    .-''         '.            ")
;;   (writeln " /.''\\   |   |.--.     .|       .|   /     .-''\"'-.  `. .-,.--.  ")
;;   (writeln "| |  | |  |   ||  |   .' |_    .' |_ /     /________\   \|  .-. | ")
;;   (writeln " \`-' /   |   ||  | .'     | .'     ||                  || |  | | ")
;;   (writeln " /(\"'`    |   ||  |'--.  .-''--.  .-'\    .-------------'| |  | | ")
;;   (writeln " \ '---.  |   ||  |   |  |     |  |   \    '-.____...---.| |  '-  ")
;;   (writeln "  /'\"\"'.\ |   ||__|   |  |     |  |    `.             .' | |      ")
;;   (writeln " ||     ||'---'       |  '.'   |  '.'    `''-...... -'   | |      ")
;;   (writeln " \'. __//             |   /    |   /                     |_|      ")
;;   (writeln "  `'---'              `'-'     `'-'                           "))

;; (brand)
(cond
  [(name) (aws/create-project (name))]
  [(rollback) (aws/rollback-project (rollback))]
  [else (displayln "Invalid invocation, see glitter --help")])
