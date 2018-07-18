#!/usr/bin/env racket

#lang racket/base

(require dyoo-while-loop
         rutils
         threading
         sxml
         sxml/sxpath
         racket/file)

(define *BIBCOUNT* 0)
(define *HASLCCCOUNT* 0)


(define *ALL-CULS* (find-files (lambda (x) #t) (~> "../scsb-data/CUL/"
                                                   (string->path))))


(define *HOWMANY* (length *ALL-CULS*))
(define *COUNTER* 0)

(define CULOUT (open-output-file "../computed-data/lc-call-numbers/cul-lc-calls.txt" #:exists 'error))

(for/list ((afile (cdr *ALL-CULS*)))
  (set! *COUNTER* (+ 1 *COUNTER*))
  (progress *COUNTER* *HOWMANY* #t (current-output-port))
  (define curr (~> afile
                   (open-input-file)
                   (ssax:xml->sxml '())))
  (for/list ((item ((sxpath "/bibRecords/bibRecord/bib") curr)))
    (define bibid (car (cdr (car  ((sxpath "/owningInstitutionBibId") item)))))
    (define oh50 "")
    (define oh90 "")
    (set! *BIBCOUNT* (+ *BIBCOUNT* 1))
    (define tmp1 ((sxpath "/content/collection/record/datafield[@tag='050']/subfield[@code='a']/text()") item))
    (define tmp2 ((sxpath "/content/collection/record/datafield[@tag='090']/subfield[@code='a']/text()") item))
    (when (not (null? tmp1))
      (set! oh50 (car tmp1)))
    (when (not (null? tmp2))
      (set! oh90 (car tmp2)))
    ; (printf "~A\t~A\t~A~%" bibid oh50 oh90)
    (fprintf CULOUT "~A\t~A\t~A~%" bibid oh50 oh90)
    (flush-output)))
