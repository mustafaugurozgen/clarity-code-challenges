;; NOTE: Define your SIP10 trait (and make sure to deploy it before deploying your token contract)
(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.contract-2.sip-010-trait)

(define-fungible-token FaucetToken)


(define-constant CONTRACT_OWNER tx-sender)
(define-constant TOKEN_NAME "The Faucet")
(define-constant TOKEN_SYMBOL "DRIP")
(define-constant TOKEN_DECIMALS u6)
(define-constant CLAIM_AMOUNT u100000000) ;; 100 tokens with 6 decimals
(define-constant BLOCKS_BETWEEN_CLAIMS u144) ;; Approximately 24 hours (assuming 10-minute block times)

(define-map LastClaimedAtBlock principal uint)

;; Error Codes
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_CANT_CLAIM_YET (err u102))


;; SIP-010 functions
;; Implement: transfer, get-name, get-symbol, get-decimals, get-balance, get-total-supply, get-token-uri

;; Sender can only send their own tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (try! (ft-transfer? FaucetToken amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)
(define-read-only (get-name)
    (ok TOKEN_NAME)
)
(define-read-only (get-symbol)
    (ok TOKEN_SYMBOL)
)
(define-read-only (get-decimals)
    (ok TOKEN_DECIMALS)
)
(define-read-only (get-balance (who principal))
    (ok (ft-get-balance FaucetToken who))
)
(define-read-only (get-total-supply)
    (ok (ft-get-supply FaucetToken))
)
(define-read-only (get-token-uri)
    (ok none)
)

;; Contract owner can mint
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (ft-mint? FaucetToken amount recipient)
  )
)

;; Faucet functions

;; Check if claim allowed
;; Mint for the tx-sender with ft-mint and set Last Claimed Block
(define-public (claim)
  (begin
    (let
      (
        (recipient tx-sender)
        (canClaim (is-claim-allowed recipient))
      )
      (if (not canClaim)
        ERR_CANT_CLAIM_YET
        (begin
          ;; mint for the recipient directly
          (try! (ft-mint? FaucetToken CLAIM_AMOUNT recipient))
          (map-set LastClaimedAtBlock recipient block-height)
          (ok true)
        )
      )
    )
  )
)

;; check if user claimed previously or not
;; then calculate the difference between current block and last block
(define-read-only (time-until-next-claim (user principal))
  (begin
    (let 
      (
        (lastClaimBlock (default-to u0 (map-get? LastClaimedAtBlock user)))
        (nextClaimBlock (+ lastClaimBlock BLOCKS_BETWEEN_CLAIMS))
      )
      ;; if lastClaimBlock is none (u0 default), return u0
      ;; else, calculate
      (if (is-eq lastClaimBlock u0)
        u0
        (if (> nextClaimBlock block-height)
          (- nextClaimBlock block-height)
          u0
        )
      )
    )
  )
)

;; Helper functions
;; use time-until-next-claim to check if allowed or not
(define-private (is-claim-allowed (user principal))
  (if (is-eq (time-until-next-claim user) u0)
    true
    false
  )
)

;; Test cases

;; Test SIP-010 functions
(print (get-name))
(print (get-symbol))
(print (get-decimals))
(print (get-balance tx-sender))
(print (get-total-supply))
(print (get-token-uri))

;; Test claim function
(print (claim))
(print (get-balance tx-sender))
(print (claim)) ;; Should fail if called twice in a row

;; Test time-until-next-claim function
(print (time-until-next-claim tx-sender))

;; Test transfer function
;;(define-constant receiver 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK)
;;(print (transfer u50000000 tx-sender receiver none))
;;(print (get-balance tx-sender))
;;(print (get-balance receiver))

;; Advanced test: Multiple users
;;(define-constant user2 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
;;(print (as-contract (transfer CLAIM_AMOUNT tx-sender user2 none)))
;; (print (get-balance user2))
;; (print (as-contract (claim)))
;; (print (as-contract (time-until-next-claim tx-sender)))