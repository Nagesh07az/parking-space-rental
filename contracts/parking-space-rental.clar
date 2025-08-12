;; Parking Space Rental Contract
;; This contract allows a user to rent a parking space by paying STX and the owner to withdraw earnings.

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-amount (err u101))

;; Track deposits for parking space rental
(define-map parking-rentals principal uint)
(define-data-var total-earnings uint u0)

;; Function 1: Rent a parking space
(define-public (rent-space (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; Update renter's total
    (map-set parking-rentals tx-sender
             (+ (default-to u0 (map-get? parking-rentals tx-sender)) amount))
    ;; Update total earnings
    (var-set total-earnings (+ (var-get total-earnings) amount))
    (ok true)))

;; Function 2: Withdraw earnings (only owner)
(define-public (withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (<= amount (var-get total-earnings)) err-invalid-amount)
    ;; Transfer STX to owner
    (try! (stx-transfer? amount (as-contract tx-sender) contract-owner))
    ;; Update total earnings
    (var-set total-earnings (- (var-get total-earnings) amount))
    (ok true)))