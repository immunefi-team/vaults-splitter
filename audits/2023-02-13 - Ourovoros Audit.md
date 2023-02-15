<table style="background-color: transparent; background-image: url(https://i.ibb.co/crxZMz2/arrows-removebg-preview.png); background-position: right bottom; background-repeat: no-repeat; background-size: contain; border: 0px solid transparent; margin: 0% 0% 0% 0%; padding: 0% 0% 0% 0%; table-layout: auto; width: 100%; height: 100%">
	<tr>
		<td style="border: 0px solid transparent">
			<h1>Immunefi</h1>
			<h2>Vault Safe</h2>
			<h3>Security Assessment & Correctness</h3>
			<h4>February 14th, 2023</h4>
			<h4 style="color: tomato">&nbsp;</h4>
		</td>
	</tr>
	<tr style="height: 1rem">
		<td style="border: 0px solid transparent"></td>
	</tr>
	<tr>
		<td style="border: 0px solid transparent">
			<b>Audited By</b>: <br>
			Angelos Apostolidis <br>
			<a href="mailto:angelos.apostolidis@ourovoros.io" style="color: rgb(249, 159, 28)">angelos.apostolidis@ourovoros.io</a> <br>
			George Delkos <br>
			<a href="mailto:george.delkos@ourovoros.io" style="color: rgb(249, 159, 28)">george.delkos@ourovoros.io</a> <br>
		</td>
	</tr>
	<tr style="height: 6rem">
		<td style="border: 0px solid transparent"></td>
	</tr>
</table>

<div style="page-break-after: always"></div>

## <img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/> Overview

### Project Summary

<table>
	<tr>
		<td style="width: 30%"><strong><span>Project Name</span></strong></td>
		<td><span>Immunefi - Vault Safe</span></td>
	</tr>
	<tr>
		<td style="width: 30%"><strong><span>Website</span></strong></td>
		<td><a href="https://www.immunefi.com">Immunefi</a></td>
	</tr>
	<tr>
		<td><strong><span>Description</span></strong></td>
		<td><span>Bug Bounty Vaults</span></td>
	</tr>
	<tr>
		<td><strong><span>Platform</span></strong></td>
		<td><span>Ethereum; Solidity, Yul</span></td>
	</tr>
	<tr>
		<td><strong><span>Codebase</span></strong></td>
		<td><a href="https://github.com/immunefi-team/vaults/"><span>GitHub Repository</span></a></td>
	</tr>
	<tr>
		<td><strong><span>Commits</span></strong></td>
		<td>
			<a href="https://github.com/immunefi-team/vaults/commit/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0">4055bbfe9b9d0e1e157b752898cf815e18cfc2d0</a><br>
		</td>
	</tr>
</table>

### Audit Summary

<table>
	<tr>
		<td style="width: 30%"><strong><span>Delivery Date</span></strong></td>
		<td><span>February 14th, 2023</span></td>
	</tr>
	<tr>
		<td><strong><span>Method of Audit</span></strong></td>
		<td><span>Static Analysis, Manual Review</span></td>
	</tr>
</table>

### Vulnerability Summary

<table>
	<tr>
		<td style="width: 30%"><strong><span style="background-color: white; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> <span>Total Issues</span></strong></td>
		<td><span>4</span></td>
	</tr>
	<tr>
		<td><strong><span style="background-color: darkorange; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> <span>Total Major</span></strong></td>
		<td><span>0</span></td>
	</tr>
	<tr>
		<td><strong><span style="background-color: dodgerblue; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> <span>Total Minor</span></strong></td>
		<td><span>2</span></td>
	</tr>
	<tr>
		<td><strong><span style="background-color: limegreen; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> <span>Total Informational</span></strong></td>
		<td><span>2</span></td>
	</tr>
</table>

<div style="page-break-after: always"></div>

## <img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/> Files In Scope

| Contract             | Location                                                                                                   |
| :------------------- | :--------------------------------------------------------------------------------------------------------- |
| src/Withdrawable.sol | https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Withdrawable.sol |
| src/Splitter.sol     | https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Splitter.sol     |

<div style="page-break-after: always"></div>

## <img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/> Findings

<table style="table-layout: fixed">
	<tr style="height: 1em">
		<td style="width: 5.6em; text-align: right"><span>ID</span></td>
		<td><span>Title</span></td>
		<td style="width: 10.75em"><span>Type</span></td>
		<td style="width: 8.25em"><span>Severity</span></td>
	</tr>
	<tr>
		<td style="text-align: right">
			<a href="#F-1">F-1</a>
		</td>
		<td>Ambiguous event definition</td>
		<td>Gas Optimization</td>
		<td>
			<span style="background-color: informational; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span>informational
		</td>
	</tr>
	<tr>
		<td style="text-align: right">
			<a href="#F-2">F-2</a>
		</td>
		<td>Usage of `transfer()` for sending Ether</td>
		<td>Volatile Code</td>
		<td>
			<span style="background-color: minor; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span>minor
		</td>
	</tr>
	<tr>
		<td style="text-align: right">
			<a href="#F-3">F-3</a>
		</td>
		<td>Inexistent input sanitization</td>
		<td>Volatile Code</td>
		<td>
			<span style="background-color: minor; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span>minor
		</td>
	</tr>
	<tr>
		<td style="text-align: right">
			<a href="#F-4">F-4</a>
		</td>
		<td>Redundant use of `virtual`</td>
		<td>Coding Style</td>
		<td>
			<span style="background-color: informational; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span>informational
		</td>
	</tr>
</table>

<div style="page-break-after: always"></div>

### <a name="F-1"><img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/></a> F-1: Ambiguous event definition

| Type             | Severity                                                                                                                            | Location                                                                                                                                                                                                                                                                                     |
| :--------------- | :---------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gas Optimization | <span style="background-color: limegreen; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> informational | <span class="informational">[Withdrawable L17](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Withdrawable.sol#L17), [L33](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Withdrawable.sol#L33)</span> |

#### <span class="informational">Description:</span>

The `LogWithdraw` event includes data unrelated to the ERC-20 token standard, i.e. a `tokenId`, leading to static data
logging during the said event's emission.

#### <span class="informational">Recommendation:</span>

We advise to remove the `tokenId` parameter from the `LogWithdraw` event.

#### <span class="informational">Alleviation:</span>

The team has acknowledged this exhibit but decided to include its alleviation on the next iteration of the code.

<div style="page-break-after: always"></div>

### <a name="F-2"><img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/></a> F-2: Usage of `transfer()` for sending Ether

| Type          | Severity                                                                                                                     | Location                                                                                                                                                      |
| :------------ | :--------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Volatile Code | <span style="background-color: dodgerblue; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> minor | <span class="minor">[Withdrawable L28](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Withdrawable.sol#L28)</span> |

#### <span class="minor">Description:</span>

After [EIP-1884](https://eips.ethereum.org/EIPS/eip-1884) was included in the Istanbul hard fork, it is not recommended
to use `.transfer()` for transferring ether as these functions have a hard-coded value for gas costs making them
obsolete as they are forwarding a fixed amount of gas, specifically `2300`. This can cause issues in case the linked
statements are meant to be able to transfer funds to other contracts instead of EOAs.

#### <span class="minor">Recommendation:</span>

We advise that the linked `.transfer()` calls are substituted with the utilization of
[the `sendValue()` function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/87326f7313e851a603ef430baa33823e4813d977/contracts/utils/Address.sol#L37-L59)
from the `Address.sol` implementation of OpenZeppelin either by directly importing the library or copying the linked
code.

#### <span class="minor">Alleviation:</span>

The team has acknowledged this exhibit but decided to include its alleviation on the next iteration of the code. Also,
the team has prepared a process to overcome this risk by transferring ownership to an EOA to recover the funds.

<div style="page-break-after: always"></div>

### <a name="F-3"><img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/></a> F-3: Inexistent input sanitization

| Type          | Severity                                                                                                                     | Location                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| :------------ | :--------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Volatile Code | <span style="background-color: dodgerblue; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> minor | <span class="minor">[Splitter L45](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Splitter.sol#L45), [L76](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Splitter.sol#L76), [L85](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Splitter.sol#L85), [109](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Splitter.sol#L109)</span> |

#### <span class="minor">Description:</span>

The linked code expressions fail to check the address-based values against the zero address.

#### <span class="minor">Recommendation:</span>

We advise to add `require` statements, checking the aforementioned values against the zero address.

#### <span class="minor">Alleviation:</span>

The team has acknowledged this exhibit but decided to include its alleviation on the next iteration of the code. Also,
the team has communicated the risks for using specific values as arguments.

<div style="page-break-after: always"></div>

### <a name="F-4"><img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/></a> F-4: Redundant use of `virtual`

| Type         | Severity                                                                                                                            | Location                                                                                                                                                        |
| :----------- | :---------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Coding Style | <span style="background-color: limegreen; border-radius: 50%; display: inline-block; height: 8pt; width: 8pt"></span> informational | <span class="informational">[Splitter L135](https://github.com/immunefi-team/vaults/tree/4055bbfe9b9d0e1e157b752898cf815e18cfc2d0/src/Splitter.sol#L135)</span> |

#### <span class="informational">Description:</span>

The linked function contains the `virtual` keyword without the intention of being extended.

#### <span class="informational">Recommendation:</span>

We advise to remove the `virtual` keyword from the linked function.

#### <span class="informational">Alleviation:</span>

The team has acknowledged this exhibit but decided to include its alleviation on the next iteration of the code, as it
relates to code maintainability and does not affect the users.

<div style="page-break-after: always"></div>

## <img src="https://i.ibb.co/NFtf2HY/logo-removebg-preview.png" style="height: 28pt; filter: invert(0)"/> Disclaimer

Reports made by Ourovoros are not to be considered as a recommendation or approval of any particular project or team.
Security reviews made by Ourovoros for any project or team are not to be taken as a depiction of the value of the
“product” or “asset” that is being reviewed.

Ourovoros reports are not to be considered as a guarantee of the bug-free nature of the technology analyzed and should
not be used as an investment decision with any particular project. They represent an extensive auditing process
intending to help our customers increase the quality of their code while reducing the high level of risk presented by
cryptographic tokens and blockchain technology.

Each company and individual is responsible for their own due diligence and continuous security. Our goal is to help
reduce the attack parameters and the high level of variance associated with utilizing new and consistently changing
technologies, and in no way claim any guarantee of security or functionality of the technology we agree to analyze.
