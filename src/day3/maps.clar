;; User map principal -> data
(define-map UserProfiles principal { name: (string-ascii 50), age: uint })

;; Function that sets a key-value in our map
(define-public (set-profile (name (string-ascii 50)) (age uint))
  (ok (map-set UserProfiles tx-sender { name: name, age: age }))
)

;; Function that allows to read whole data name and age
;; We can return only which data we want.
(define-read-only (get-profile (who principal))
	(let
    (
      (profile (map-get? UserProfiles who))
    )
    {
      name: (default-to "Not Found" (get name profile)),
      age: (default-to u0 (get age profile))
    }
  )
)

;; Get only Name. 
(define-read-only (get-profile-name (who principal))
	(let
    (
      (profile (map-get? UserProfiles who))
    )
    {
      name: (default-to "Not Found" (get name profile)),
    }
  )
)


;; Test cases
(set-profile "Rumpel" u28)
(get-profile 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) ;; Should return a user
;;(get-profile-name 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)