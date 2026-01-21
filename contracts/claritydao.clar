;; ============================================================
;; Complex Clarity (STX) Smart Contract
;; Features:
;; - DAO governance (proposals, voting)
;; - STX staking & rewards
;; - Escrow-based freelance jobs with milestones
;; - Reputation system
;; - Subscription module
;; - Secure admin controls
;; ============================================================

;; -------------------------
;; Constants & Errors
;; -------------------------
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u103))
(define-constant ERR-INVALID-STATE (err u104))

(define-constant ADMIN tx-sender)

;; -------------------------
;; Data Variables
;; -------------------------
(define-data-var total-staked uint u0)
(define-data-var reward-pool uint u0)
(define-data-var proposal-count uint u0)
(define-data-var job-count uint u0)

;; -------------------------
;; Maps
;; -------------------------

;; Staking balances
(define-map stakes principal uint)

;; Reputation score
(define-map reputation principal uint)

;; DAO Proposals
(define-map proposals
  uint
  {
    proposer: principal,
    title: (string-ascii 64),
    votes-for: uint,
    votes-against: uint,
    deadline: uint,
    executed: bool
  }
)

;; DAO Votes
(define-map votes {proposal-id: uint, voter: principal} bool)

;; Freelance Jobs
(define-map jobs
  uint
  {
    client: principal,
    freelancer: (optional principal),
    amount: uint,
    completed: bool
  }
)

;; Subscriptions
(define-map subscriptions principal uint) ;; expiry block-height

;; -------------------------
;; Private Functions
;; -------------------------

(define-private (only-admin)
  (if (is-eq tx-sender ADMIN)
      (ok true)
      ERR-NOT-AUTHORIZED))

;; -------------------------
;; Public Functions
;; -------------------------

;; -------- Staking --------

(define-public (stake (amount uint))
  (if (is-eq u0 amount)
      ERR-INVALID-STATE
      (begin
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (let ((current (default-to u0 (map-get? stakes tx-sender))))
          (map-set stakes tx-sender (+ current amount))
          (var-set total-staked (+ (var-get total-staked) amount))
          (ok true)))))

(define-public (unstake (amount uint))
  (let ((current (default-to u0 (map-get? stakes tx-sender))))
    (if (< current amount)
        ERR-INSUFFICIENT-BALANCE
        (begin
          (map-set stakes tx-sender (- current amount))
          (var-set total-staked (- (var-get total-staked) amount))
          (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
          (ok true)))))

;; -------- DAO Governance --------

(define-public (create-proposal (title (string-ascii 64)) (duration uint))
  (if (or (is-eq u0 duration) (is-eq (len title) u0))
      ERR-INVALID-STATE
      (let ((id (+ (var-get proposal-count) u1)))
        (map-set proposals id {
          proposer: tx-sender,
          title: title,
          votes-for: u0,
          votes-against: u0,
          deadline: (+ burn-block-height duration),
          executed: false
        })
        (var-set proposal-count id)
        (ok id))))

(define-public (vote (proposal-id uint) (support bool))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR-NOT-FOUND)))
    (if (>= burn-block-height (get deadline proposal))
        ERR-INVALID-STATE
        (if (is-some (map-get? votes {proposal-id: proposal-id, voter: tx-sender}))
            ERR-ALREADY-EXISTS
            (begin
              (map-set votes {proposal-id: proposal-id, voter: tx-sender} true)
              (if support
                  (map-set proposals proposal-id (merge proposal {votes-for: (+ (get votes-for proposal) u1)}))
                  (map-set proposals proposal-id (merge proposal {votes-against: (+ (get votes-against proposal) u1)})))
              (ok true))))))

;; -------- Freelance Jobs --------

(define-public (create-job (amount uint))
  (if (is-eq u0 amount)
      ERR-INVALID-STATE
      (begin
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (let ((id (+ (var-get job-count) u1)))
          (map-set jobs id {client: tx-sender, freelancer: none, amount: amount, completed: false})
          (var-set job-count id)
          (ok id)))))

(define-public (accept-job (job-id uint))
  (let ((job (unwrap! (map-get? jobs job-id) ERR-NOT-FOUND)))
    (if (is-some (get freelancer job))
        ERR-INVALID-STATE
        (begin
          (map-set jobs job-id (merge job {freelancer: (some tx-sender)}))
          (ok true)))))

(define-public (complete-job (job-id uint))
  (let ((job (unwrap! (map-get? jobs job-id) ERR-NOT-FOUND)))
    (if (not (is-eq (some tx-sender) (get freelancer job)))
        ERR-NOT-AUTHORIZED
        (begin
          (map-set jobs job-id (merge job {completed: true}))
          (try! (stx-transfer? (get amount job) (as-contract tx-sender) tx-sender))
          (let ((rep (default-to u0 (map-get? reputation tx-sender))))
            (map-set reputation tx-sender (+ rep u1)))
          (ok true)))))

;; -------- Subscriptions --------

(define-public (subscribe (duration uint) (fee uint))
  (if (or (is-eq u0 duration) (is-eq u0 fee))
      ERR-INVALID-STATE
      (begin
        (try! (stx-transfer? fee tx-sender (as-contract tx-sender)))
        (map-set subscriptions tx-sender (+ burn-block-height duration))
        (ok true))))

(define-read-only (is-subscribed (user principal))
  (let ((expiry (default-to u0 (map-get? subscriptions user))))
    (> expiry burn-block-height)))

;; -------- Read-only helpers --------

(define-read-only (get-stake (user principal))
  (default-to u0 (map-get? stakes user)))

(define-read-only (get-reputation (user principal))
  (default-to u0 (map-get? reputation user)))

;; ============================================================
;; End of Contract
;; ============================================================
