
```markdown
# ClarityDAO - STX Smart Contract

A comprehensive Clarity smart contract built on the Stacks blockchain featuring DAO governance, staking, freelance job escrow, reputation system, and subscription management.

##  Features

###  DAO Governance
- **Proposals**: Create and manage governance proposals with customizable duration
- **Voting System**: Democratic voting with support/opposition tracking
- **Deadline Management**: Time-bound voting periods using burn-block-height

###  Staking & Rewards
- **STX Staking**: Secure staking mechanism for token holders
- **Unstaking**: Flexible withdrawal with balance validation
- **Reward Pool**: Foundation for reward distribution system

###  Freelance Jobs
- **Job Creation**: Clients can create escrow-based job postings
- **Job Acceptance**: Freelancers can accept available jobs
- **Job Completion**: Secure payment upon job completion
- **Milestone-based Escrow**: Funds held until completion

###  Reputation System
- **Reputation Tracking**: Users earn reputation points on successful job completion
- **On-chain History**: Immutable reputation records on the blockchain

### Subscription Module
- **Flexible Subscriptions**: Time-based subscription management
- **Expiry Validation**: Automatic expiration checking
- **Custom Durations**: Configurable subscription periods

###  Security Features
- **Admin Controls**: Role-based access management
- **Authorization Checks**: Function-level permission validation
- **Input Validation**: Comprehensive parameter checking
- **Error Handling**: Detailed error codes for debugging

## Constants & Error Codes

| Error Code | Value | Description |
|-----------|-------|-------------|
| ERR-NOT-AUTHORIZED | 100 | Caller lacks required permissions |
| ERR-NOT-FOUND | 101 | Requested resource not found |
| ERR-ALREADY-EXISTS | 102 | Resource already exists |
| ERR-INSUFFICIENT-BALANCE | 103 | Insufficient balance for operation |
| ERR-INVALID-STATE | 104 | Invalid state for operation |

##  Data Structures

### Staking
```clarity
(define-map stakes principal uint)
```
Maps user principals to their staked STX amounts.

### DAO Proposals
```clarity
{
  proposer: principal,
  title: (string-ascii 64),
  votes-for: uint,
  votes-against: uint,
  deadline: uint,
  executed: bool
}
```

### Freelance Jobs
```clarity
{
  client: principal,
  freelancer: (optional principal),
  amount: uint,
  completed: bool
}
```

### Subscriptions
```clarity
(define-map subscriptions principal uint) ;; expiry burn-block-height
```

##  Public Functions

### Staking Functions

#### `stake(amount: uint) → Response<bool, Error>`
Stake STX tokens in the contract.
```clarity
(stake u1000) ;; Stake 1000 microSTX
```

#### `unstake(amount: uint) → Response<bool, Error>`
Withdraw staked STX tokens.
```clarity
(unstake u500) ;; Unstake 500 microSTX
```

### DAO Governance

#### `create-proposal(title: string-ascii 64, duration: uint) → Response<uint, Error>`
Create a new governance proposal.
```clarity
(create-proposal "Increase reward pool" u1000) ;; 1000 blocks duration
```

#### `vote(proposal-id: uint, support: bool) → Response<bool, Error>`
Vote on an active proposal.
```clarity
(vote u1 true) ;; Vote in favor of proposal 1
```

### Freelance Jobs

#### `create-job(amount: uint) → Response<uint, Error>`
Create a new job posting with escrow.
```clarity
(create-job u10000) ;; Create job worth 10000 microSTX
```

#### `accept-job(job-id: uint) → Response<bool, Error>`
Accept a job as a freelancer.
```clarity
(accept-job u1) ;; Accept job 1
```

#### `complete-job(job-id: uint) → Response<bool, Error>`
Mark job as complete and claim payment.
```clarity
(complete-job u1) ;; Complete job 1 and receive payment
```

### Subscriptions

#### `subscribe(duration: uint, fee: uint) → Response<bool, Error>`
Subscribe to the platform.
```clarity
(subscribe u100 u500) ;; Subscribe for 100 blocks at 500 microSTX
```

#### `is-subscribed(user: principal) → bool`
Check if a user has an active subscription.
```clarity
(is-subscribed tx-sender) ;; Returns true/false
```

### Read-only Functions

#### `get-stake(user: principal) → uint`
Get user's staked balance.

#### `get-reputation(user: principal) → uint`
Get user's reputation score.

##  Deployment

### Prerequisites
- Stacks CLI installed
- STX testnet account with balance
- Clarity IDE or VS Code with Clarity extension

### Deploy to Testnet
```bash
stx deploy contracts/claritydao.clar --testnet
```

### Deploy to Mainnet
```bash
stx deploy contracts/claritydao.clar --mainnet
```

##  Testing

Test individual functions:

```clarity
;; Test staking
(stake u1000)
(get-stake tx-sender)

;; Test proposal creation
(create-proposal "Test Proposal" u1000)

;; Test voting
(vote u1 true)

;; Test job creation
(create-job u5000)
(accept-job u1)
(complete-job u1)

;; Test subscriptions
(subscribe u100 u500)
(is-subscribed tx-sender)
```

##  Contract State

### Variables
- `total-staked`: Total STX staked in the contract
- `reward-pool`: Available rewards for distribution
- `proposal-count`: Number of created proposals
- `job-count`: Number of created jobs

##  Transaction Flow

### Staking Flow
1. User calls `stake(amount)`
2. STX transferred to contract
3. Stake recorded in map
4. `total-staked` incremented

### Job Completion Flow
1. Client creates job with `create-job(amount)`
2. Freelancer accepts with `accept-job(job-id)`
3. Freelancer completes with `complete-job(job-id)`
4. Payment transferred to freelancer
5. Reputation +1 for freelancer

### Voting Flow
1. Proposer creates proposal with `create-proposal(...)`
2. Voters call `vote(proposal-id, support)` before deadline
3. Votes tallied
4. Deadline reached = voting period ends

##  Security Considerations

1. **Input Validation**: All functions validate non-zero amounts and valid states
2. **Authorization**: Admin-only functions protected with `only-admin()`
3. **Escrow Protection**: Funds held until conditions met
4. **Replay Prevention**: Vote map prevents double voting
5. **Deadline Enforcement**: Voting windows enforced via `burn-block-height`

##  Known Limitations

- Title limited to 64 ASCII characters
- Single admin address (centralized)
- No proposal execution mechanism yet
- No automatic reward distribution
- Linear reputation model

##  Future Enhancements

- [ ] Multi-sig admin controls
- [ ] Proposal execution function
- [ ] Automated reward distribution
- [ ] Milestone-based job payments
- [ ] Reputation-weighted voting
- [ ] Slash mechanism for stakers
- [ ] Advanced dispute resolution

##  License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation
- Review Clarity language reference

##  Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request
4. Include tests for new features

---


```

This comprehensive README includes features, API documentation, deployment instructions, and usage examples for your ClarityDAO smart contract.This comprehensive README includes features, API documentation, deployment instructions, and usage examples for your ClarityDAO smart contract.
