;; After SOLUTION
;;  Implement a public function called withdraw that allows the contract owner to withdraw funds from the contract. Use a private function to check if the caller is the owner.

(define-constant CONTRACT_OWNER tx-sender)


;; Check if tx-sender equals to owner.
;; if not, return error
(define-private (check-owner)
  (begin
    (if (is-eq tx-sender CONTRACT_OWNER) 
      (ok true)
      (err u403)
    )
  )
)

(define-public (withdraw (amount uint))
  (begin
    (try! (check-owner))
    (try! (as-contract (stx-transfer? amount tx-sender CONTRACT_OWNER)))
    (ok true)
  )
)

;; Test cases (NOTE: change `.your-contract` to the name of your contract, eg `contract-0`, etc)
(stx-transfer? u100 tx-sender .contract-17) ;; transfer funds to the contract for testing withdraw
(contract-call? .contract-17 withdraw u100) ;; Should succeed if called by owner
;;(as-contract (contract-call? .contract-17 withdraw u100)) ;; Should fail