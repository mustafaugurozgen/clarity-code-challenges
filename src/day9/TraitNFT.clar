;; This is our trait. First deploy this as contract-1

;;(define-trait sip009-nft-trait
;;    (
;;        ;; Last token ID, limited to uint range
;;        (get-last-token-id () (response uint uint))
;;
;;        ;; URI for metadata associated with the token 
;;        (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
;;
;;        ;; Owner of a given token identifier
;;        (get-owner (uint) (response (optional principal) uint))
;;
;;        ;; Transfer from the sender to a new principal
;;        (transfer (uint principal principal) (response bool uint))
;;    )
;;)

;; This is our implementation contract, an NFT that implements trait
;; sip009-nft
;; CONTRACT-2

;;(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.contract-1.sip009-nft-trait)
;;
;;(define-constant contract-owner tx-sender)
;;
;;(define-constant err-owner-only (err u100))
;;(define-constant err-token-id-failure (err u101))
;;(define-constant err-not-token-owner (err u102))
;;
;;(define-non-fungible-token stacksies uint)
;;(define-data-var token-id-nonce uint u0)
;;
;;(define-read-only (get-last-token-id)
;;	(ok (var-get token-id-nonce))
;;)
;;
;;(define-read-only (get-token-uri (token-id uint))
;;	(ok none)
;;)
;;
;;(define-read-only (get-owner (token-id uint))
;;	(ok (nft-get-owner? stacksies token-id))
;;)
;;
;;(define-public (transfer (token-id uint) (sender principal) (recipient principal))
;;	(begin
;;		(asserts! (is-eq tx-sender sender) err-not-token-owner)
;;		(nft-transfer? stacksies token-id sender recipient)
;;	)
;;)
;;
;;(define-public (mint (recipient principal))
;;	(let ((token-id (+ (var-get token-id-nonce) u1)))
;;		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
;;		(try! (nft-mint? stacksies token-id recipient))
;;		(asserts! (var-set token-id-nonce token-id) err-token-id-failure)
;;		(ok token-id)
;;	)
;;)


(use-trait nft-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.contract-1.sip009-nft-trait)

(define-public (get-owner-of-nft (nftContract <nft-trait>) (tokenId uint))
  (match (contract-call? nftContract get-owner tokenId)
    ownerPrincipal (ok (unwrap-panic ownerPrincipal))
    err (err u401)
  )
)

;; Test cases
(define-constant NFT_CONTRACT 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.contract-2)

;; First we need to mint
(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.contract-2 mint tx-sender)
(get-owner-of-nft NFT_CONTRACT u1) ;; Should return (ok nftOwnerPrincipal)