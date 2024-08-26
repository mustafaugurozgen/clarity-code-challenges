;; AFTER SOLUTION

(define-data-var txLog (list 100 uint) (list))

;; Converted body part to one block with let.
;; Added length check while adding element to list
;; Added error handling if it exceeds length.
(define-public (add-tx (amount uint))
  (let
    ((currentTxLog (var-get txLog)))
    (match (as-max-len? (append currentTxLog amount) u100) success
      (ok (var-set txLog success))
      (err "Max length exceed")
    )
  )
)

;; Fixed wrong use of accessing to txLog data.
(define-read-only (get-last-tx)
  (let
    (
      (currentTxLog (var-get txLog))
      (logLength (len currentTxLog))
    )
    (if (> logLength u0)
      (ok (element-at? currentTxLog (- logLength u1)))
      (err u0)
    )
  )
)

;; We have added begin to do many operations in a block
;; Function body should be one block
(define-private (clear-log)
  (begin
    (var-set txLog (list))
    (print "Log cleared")
  )
)

;; We should make this read-only since it doesn't update state.
(define-read-only (get-tx-count)
  (ok (len (var-get txLog)))
)

;; Test cases
(add-tx u32)
(add-tx u21)
(add-tx u432)
(add-tx u3)
(print (get-last-tx))
(clear-log)
(print (get-last-tx))
(print (get-tx-count))