# Immunefi - Vaults System

[![GitHub Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry]
[![Styled with Prettier][prettier-badge]][prettier]

[gha]: https://github.com/immunefi-team/vaults/actions
[gha-badge]: https://github.com/immunefi-team/vaults/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[prettier]: https://prettier.io
[prettier-badge]: https://img.shields.io/badge/Code_Style-Prettier-ff69b4.svg

Immunefi wants to resolve the trust issue that currently exists in bug bounty programs by creating a decentralized
version of the bounty programs we currently run on our “Web2” infrastructure. This system provides a way for projects to
lock assets for bug bounties to further incentivize hackers to review their projects.

## High level description

A project can prove their proof of assets deploying a vault via Immunefi Dashboard and depositing assets. The project is
the ultimate owner of the vault, none else can access or operate their funds. The system is non custodial.

Currently a vault is implemented as a [Gnosis Safe](https://github.com/safe-global/safe-contracts).

A project pays a successful report submission by a whitehat using the [Splitter](./src/Splitter.sol). This contract
handles automatically the distribution of the bounty payment to the whitehat and the Immunefi fee.

This is a beta and up to changes in the next iterations.

## Deployments

Deterministic deployments available at `0xa35d2f47063076d2eaf4c5e3efea4f15936086d8` on Ethereum
[Mainnet](https://etherscan.io/address/0xa35d2f47063076d2eaf4c5e3efea4f15936086d8) and
[Goerli](https://goerli.etherscan.io/address/0xa35d2f47063076d2eaf4c5e3efea4f15936086d8).

## Testing

### Pre Requisites

You will need the following software on your machine:

- [Git](https://git-scm.com/downloads)
- [Foundry](https://github.com/foundry-rs/foundry)
- [Node.Js](https://nodejs.org/en/download/)
- [Yarn](https://yarnpkg.com/)

To test and deploy you need only Foundry.

### Tests

1. Run `forge test`

### Deploy

1. Copy `.env.example` to `.env` and set variables based on your environment
2. Run `source .env && forge script script/SplitterDeployer.s.sol:SplitterDeployer`

## Security

### Disclosures

If you discover any security issues, please follow the [Immunefi Bounty Program](https://immunefi.com/bounty/immunefi/)
to submit.

### Audits

- [Internal Audit by Immunefi Triaging Team](./audits/2023-02-03%20-%20Immunefi%20-%20Internal%20Audit%20of%20the%20Vaults%20system.pdf)

## License
