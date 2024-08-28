(define-non-fungible-token Ticket uint)

;; error codes
(define-constant ERR_NO_TICKET_SOLD (err u500))
(define-constant ERR_WRONG_WINNER (err u501))
(define-constant ERR_WINNER_ALREADY_SELECTED (err u502))

(define-data-var ticketCounter uint u0)
(define-data-var ticketPrice uint u1000000) ;; 1 STX
(define-data-var lotteryPool uint u0)

;; custom var
(define-data-var winner (optional principal) none)
(define-data-var winnerSelected bool false)


;; first pull STX 
;; then mint nft
;; update vars
(define-public (buy-ticket)
  (let
    (
      (token-id (+ (var-get ticketCounter) u1))
      (price (var-get ticketPrice))
      (currentPool (var-get lotteryPool))
    )
    (asserts! (not (var-get winnerSelected)) ERR_WINNER_ALREADY_SELECTED)
    (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
    (try! (nft-mint? Ticket token-id contract-caller))
    (var-set lotteryPool (+ currentPool price))
    (var-set ticketCounter token-id)

    (ok token-id)
  )
)

(define-public (select-winner)
  ;; Implement winner selection logic here (this can be hard coded, or however you prefer)
  (begin
    (asserts! (not (var-get winnerSelected)) ERR_WINNER_ALREADY_SELECTED)
    (if (is-eq (var-get ticketCounter) u0)
      ERR_NO_TICKET_SOLD
      (let
        (
          ;; pseudo random number. ID can't be 0, add 1.
          (pRandomId (+ u1 (mod block-height (var-get ticketCounter))))
          (nftOwner (nft-get-owner? Ticket pRandomId) )
        )
        (var-set winnerSelected true)
        (var-set winner nftOwner)
        (ok (var-get winner))
      )
    )
  )
)

(define-public (claim-prize)
  ;; Implement prize claiming logic here
  (let
    (
      (lotteryWinner (unwrap-panic (var-get winner)))
      (currentPool (var-get lotteryPool))
    )
    (asserts! (is-eq tx-sender lotteryWinner) ERR_WRONG_WINNER)
    (try! (as-contract (stx-transfer? currentPool tx-sender lotteryWinner)))
    (var-set lotteryPool u0)
    (ok true)
  )
)

;; read-only
(define-read-only (get-tickets-sold)
  (ok (var-get ticketCounter))
)
(define-read-only (get-lottery-pool)
  (ok (var-get lotteryPool))
)
(define-read-only (get-winner)
  (ok (var-get winner))
)
(define-read-only (get-ticket-price)
  (ok (var-get ticketPrice))
)
;; Test cases

;; Buy a ticket successfully
;;(contract-call? .lottery buy-ticket) ;; Should `mint` NFT to your address
;; ticketCounter should be 1, lotteryPool should be 1000000

;; Select a winner
;; (contract-call? .lottery select-winner)
;; Should return (ok principal) where principal is the winner's address

;; Claim prize (assuming the caller is the winner)
;; (contract-call? .lottery claim-prize) ;; Should return (ok u...)
;; The winner's balance should increase by 3000000, lotteryPool should be 0

;; Attempt to select winner when no tickets are sold
;; First, reset the contract state or deploy a fresh instance
;; (contract-call? .lottery select-winner)
;; Should return an error (err u...) indicating no tickets sold

;; Buy a ticket after a winner has been selected
;; Assuming a winner has been selected in a previous test
;; (contract-call? .lottery buy-ticket)
;; Should return an error (err u...) or start a new lottery round

;; Get current ticket price
;; (contract-call? .lottery get-ticket-price)
;; Should return price of ticket

;; Get total tickets sold
;; (contract-call? .lottery get-tickets-sold)
;; Should return the number of tickets sold (uint)

;; Get current lottery pool
;; (contract-call? .lottery get-lottery-pool)
;; Should return the current amount in the lottery pool (uint)