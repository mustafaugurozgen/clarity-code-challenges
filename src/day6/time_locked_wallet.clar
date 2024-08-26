;; Time-Locked Wallet

;; Constants and Storage
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_ALREADY_LOCKED (err u101))
(define-constant ERR_NOT_UNLOCKED (err u102))
(define-constant ERR_NO_VALUE (err u103))
;; Error if given height is in the past
(define-constant ERR_INVALID_HEIGHT (err u104))

(define-data-var beneficiary (optional principal) none)
(define-data-var unlockHeight uint u0)
(define-data-var balance uint u0)


;; Public Functions
;; I have implemented it as only one user can lock at a time
;; If it is already locked, not anyone else can lock.
;; Thought so because of ERR_ALREADY_LOCKED constant 
;; and already defined storage are not maps, theya are single vars.
;; I am also assuming that supported token is STX.

;; In this function, we will set variables
;; and check some error cases. 
;; Since anyone can send/lock, we don't check for owner or any role.
(define-public (lock (newBeneficiary principal) (unlockAt uint) (amount uint))
  (begin
    ;; Check conditions
    (asserts! (is-none (unwrap-panic (get-beneficiary))) ERR_ALREADY_LOCKED) ;; It shouldn't be locked
    (asserts! (> amount u0) ERR_NO_VALUE) ;; Amount has to be gt 0
    (asserts! (> unlockAt block-height) ERR_INVALID_HEIGHT)
    ;; Transfer stx, before setting vars. Security purposes.
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; set variables
    (var-set beneficiary (some newBeneficiary)) 
    (var-set unlockHeight unlockAt)
    (var-set balance amount)
    (ok true)
  )
)

(define-public (claim)
  (begin
    
    (asserts! (is-eq (some contract-caller) (unwrap-panic (get-beneficiary))) ERR_NOT_AUTHORIZED)
    (asserts! (>= block-height (unwrap-panic (get-unlock-height))) ERR_NOT_UNLOCKED)
    ;; we can use contract-caller as to principal since we check equality
    (try! (as-contract (stx-transfer? (unwrap-panic (get-balance)) tx-sender (unwrap-panic (unwrap-panic (get-beneficiary))))))
    ;; after claim, initialize vars back.
    (var-set beneficiary none)
    (var-set unlockHeight u0)
    (var-set balance u0)
    (ok true)
  )
)

(define-public (bestow (newBeneficiary principal))
  (begin
    ;; only current beneficiary can transfer right to claim
    (asserts! (is-eq (some contract-caller) (unwrap-panic (get-beneficiary))) ERR_NOT_AUTHORIZED)
    (var-set beneficiary (some newBeneficiary))
    (ok true)
  )
)

;; Read-only Functions

(define-read-only (get-beneficiary)
  (ok (var-get beneficiary))
)

(define-read-only (get-unlock-height)
  (ok (var-get unlockHeight))
)

(define-read-only (get-balance)
  (ok (var-get balance))
)

;; Test cases

;; Test: Lock tokens
;; (print (lock tx-sender u100 u1000))
;; (print (get-beneficiary))
;; (print (get-unlock-height))
;; (print (get-balance))

;; Test: Attempt to claim before unlock height
;; (print (claim))

;; Test: Bestow to new beneficiary
;; (define-constant NEW_BENEFICIARY 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK)
;; (print (bestow NEW_BENEFICIARY))
;; (print (get-beneficiary))

;; Test: Claim after unlock height (you'll need to advance the block height in your test environment)
;; (print (claim))
;; (print (get-balance))