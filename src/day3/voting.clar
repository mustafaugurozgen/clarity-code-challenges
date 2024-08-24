(define-map Voters principal bool)
(define-map VoteCounts principal uint)
(define-data-var TotalVotes uint u0)

;; Implement the register-voter function
(define-public (register-voter (voter principal))
  (if (is-none (map-get? Voters voter))
    (ok (map-set Voters voter false))
    (err "Already Registered")
  )
)

;; Implement the cast-vote function
(define-public (cast-vote (voter principal) (candidate principal))
  (let ((is-voted (unwrap! (map-get? Voters voter) (err u1)))) ;; Error if "User not registered"
    (if (not is-voted)
      (let ((vote-count (default-to u0 (map-get? VoteCounts candidate))))
        (map-set Voters voter true)
        (var-set TotalVotes (+ u1 (var-get TotalVotes)))
        (ok (map-set VoteCounts candidate (+ u1 vote-count)))
      )
      (err u2) ;; Already voted
    )
  )
)

;; Implement the get-vote-count function
(define-read-only (get-vote-count (candidate principal))
  (default-to u0 (map-get? VoteCounts candidate))
)

;; Test cases
(register-voter 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) ;; Should return (ok true)
(cast-vote tx-sender 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG) ;; Should return (ok true)
(cast-vote tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) ;; Should fail (err u2) already voted
;;(var-get TotalVotes)
(get-vote-count 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG) ;; Should return (u1)