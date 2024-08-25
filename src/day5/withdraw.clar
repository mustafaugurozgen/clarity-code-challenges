;; BEFORE SOLUTION
;;  Implement a public function called withdraw that allows the contract owner to withdraw funds from the contract. Use a private function to check if the caller is the owner.

(define-constant CONTRACT_OWNER tx-sender)

(define-private (check-owner)
  ;; Your code here
)

(define-public (withdraw (amount uint))
  ;; Your code here
)

;; Test cases (NOTE: change `.your-contract` to the name of your contract, eg `contract-0`, etc)
(stx-transfer? u100 tx-sender .your-contract) ;; transfer funds to the contract for testing withdraw
(contract-call? .your-contract withdraw u100) ;; Should succeed if called by owner
(as-contract (contract-call? .your-contract withdraw u100)) ;; Should fail