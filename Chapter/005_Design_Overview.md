このセクションではシステム全体の設計像を簡潔に説明する。システムの詳細な説明は章を追って解説する。

## 5.1. コンセンサス
relay-chainでは、Polkadotは正当なブロックが同期性のあるByzantine faulttolerant (BFT)アルゴリズムを通して合意される。このアルゴリズムはTendermint [11]によってインスパイアされたものである。そして、副次的にHoneyBadgerBFT [14]に似通っている。後者は任意の不完全性のある
ネットワークインフラで正常に動作する権威者もしくはバリデーターがいれば効率的でfault-tolerantのコンセンサスを提供する。

proof-of-authority (PoA)スタイルのネットワークでは、これだけで十分である。しかし、Polkadotは信頼される権威者や3rdパーティーが存在しない完全にOpenでパブリックな環境ネットワークとしてデプロイが可能であるように設計されている。なので私達にはバリデーターを決定し、正直に動くためにインセンティブ設計する必要がある。なので、PoSベースの選考基準を設ける。

## 5.2. 掛け金を証明する
私達はネットワークに特定のアカウントがいくらの"掛け金"を持っているのかを測る方法があることを想定している。 既存のシステムと比較しやすいように計測する単位を"トークン"とする。この言葉はいくつかの理由で理想的ではない。1つはアカウントに紐付いている値がスカラー値であるとは限らないこと。もう1つは個別のトークンに特有性がないからである。

![Summary](https://github.com/stakedtechnologies/PolkadotWP/blob/master/img/summary.png)

私達は、頻度は高くないが（最大でも1日に1回、もしかすると4半期に1回ほど）Nominated Proof-of-Stake (NPoS)によってバリデーターは選出されることを想定している。Incentivisation can happen through a pro-rata allocation of funds coming from a token base expansion (up to 100%
per year, though more likely around 10%) together with any transaction fees collected. マネタリーベースの膨張は主にインフレーションをもたらすけれども、全てのトークン保有者が参加権をフェアに持つので、時とともに価値がへるという心配をする必要がない。そのことでコンセンサスメカニズムにおけるトークンホルダーの役割を喜んでこなすようになる。トークンの特定の割合がステーキングプロセスのターゲットとなる。効率的なトークンベースの増加（token base expansion）はマーケットベースのメカニズムでこのターゲット値に近づくように調整される。

バリデーターは掛け金によって密接につながっている。バリデーターが掛け金を引き出すことができるのは、バリデーターの責務が終わり時間が経ってからである。（3ヶ月くらい）この長い期間が存在するのは、チェーンのチェックポイントまでバリデーターが将来不正を行った場合罰するためである。報酬額を削減したり、意図的にネットワークを悪化させたり、他のバリデーターに掛け金を渡したりした場合、罰を受けることになる。例えば、バリデーターがフォークした両方のチェーンを承認しようとした場合（しばしばショートレンジアタックと呼ばれる）、後々それが検知され罰せられる。

Long-range “nothing-at-stake” attacks4 are circumvented through a simple “checkpoint” latch which prevents a dangerous chain-reorganisation of more than a particular chain-depth. 新しく同期してきたクライアントが間違ったチェーンに騙さないことを確証するために、バリデーターの掛け金整理のタイミングと同じく定期でハードフォークが行われる。これによって最新のチェックポイントブロックハッシュがクライアントに入る。これは今後、“finite chain length”やジェネシスブロックを定期的にリセットすることによってうまくいくようになる。

## 5.3. Parachainとコレイター
各parachainはrelay-cahinに近いセキュリティー強度を持つ。paracahinのヘッダーはrelay-chainのブロックに格納されており、再編成や2重支払いがないようにしている。これはBitcoinでいうサイドチェーンとマージマイニングと似たセキュリティー保証である。Polkadotではそれに加え、parachainのstate transactionが正当であるという強い保証を提供する。これは、バリデーターが暗号学的にランダムにサブセットに配属されることを通して行われる。parachainごとにサブセットがあるかもしれなければ、blockごとにサブセットはことなるかもしれない。この設定はparacahinのブロックタイムがrelaycahinのブロックタイムと少なくても同じくらい長いことを示している。この分割の詳しい方法はこの論文の対象外である。しかし、RanDAOに似たcommit-revealフレームワーク、もしくは暗号学的に安全なハッシュ下の各parachainブロックに結合したデータに立脚している可能性が高い。

そのようなバリデーターのサブセットは正当だと保証されたparachainのブロック候補を提供することを要求されている。正当性というのは2つの重要なポイントを含む。1つ目は全てのstate transitionsが正確に実行され、全ての参照される外部データが最終的に正当であるということ。
2つ目は、that any data which is extrinsic to its
candidate, such as those external transactions, has sufficiently high availability so that participants are able to
download it and execute the block manually.5 Validators may provide only a “null” block containing no external “transactions” data, but may run the risk of getting a reduced reward if they do. They work alongside
a parachain gossip protocol with collators—individuals
who collate transactions into blocks and provide a noninteractive, zero-knowledge proof that the block constitutes a valid child of its parent (and taking any transaction
fees for their trouble).

parachainのプロトコルにチェーン独自のスパム防止方法を搭載する余地を残している。relay-chainにある“compute-resource metering”もしくは、“transaction fee”という根本的な概念は存在しない。relaychainプロトコルによってこれらが強制されることもない。（しかし、堅牢なメカニズムの用意されていないparachainをステークホルダーが採用することは起こりえないだろう）これはEthereumのようなチェーンと明確に異っている。（例：シンプルなfeeモデルを持つBitcoinのようなチェーンもしくは、スパム防止モデルは提唱されていないがそれ以外）

Polkadotのrelay-chainそれ自体はEtheruemのようなaccounts、stateチェーンとして存在する可能性が高い。もしかすると、EVMの派生系であるかもしれない。relay-cahinのノードはかなりの処理能力、トランザクションスループットが要求されるので、トランザクションスループットは高いトランザクション手数料とブロックサイズリミットによって最小化されるだろう。

## 5.4. インターチェーンコミュニケーション
Polkadotの重要な最後の要素は、インターチェーンコミュニケーションである。 paracahin間では幾分かのインフォメーションチャネルが存在するので、Polkadotはスケーラブルなマルチチェーンであると私達は考えている。Polkadotの場合、コミュニケーションはできるだけシンプルに設計している。paracahinで処理されるトランザクションは（Chainのロジックによっては）2つ目のparachainもしくは、relay-cahinに発送することができる。商用的なブロックチェーン上の外部トランザクションのように、トランザクションは完全に非同期であり情報をもとの出処に返し継承することはできない。

![transaction](https://github.com/stakedtechnologies/PolkadotWP/blob/sota/img/transaction.jpg)

実装の複雑性、リスク、将来のparachainアーキテクチャーの制限を最小化する為に、これらのインターチェーントランザクションは一般的な外部トランザクションと区別することができない。トランザクションはparacahinを認識することができるオリジナルの要素と任意のサイズのアドレスを持つ。BitcoinやEthereumといった現在の一般的なシステムとは異なり、インターチェーントランザクションでは料金が紐づく"決済"はできない。そのような決済は発生源と目的地のparachain間のネゴシエーションロジックを通して管理されなければならない。Ethereum’s Serenityで提案されているシステムはそのようなクロスチェーン決済を管理する簡単な方法である。

インターチェーントランザクションは正確性を保証するMarkle treeベースの単純な行列メカニズムを使うことによって解決される。1つのparacahinのアウトプット列を目的地のparacahinのインプット列に移動させるのはrelay-cahinのメンテナーの仕事である。その送られたトランザクションはrelay-cahinのトランザクションそれ自体ではなく、relay-chainによって参照される。他のparacahinのトランザクションからparacahinにスパムが送られるのを防ぐために、目的地のインプット列は一番前のブロック列の時よりも大きすぎないようにする必要がある。もしそのインプット列がブロック処理後、大きすぎた場合、それは"仕込まれた"と考えられ、限界値以下に減らさない限り、続くブロックにおいてトランザクションを処理することができなくなる。それらの列はrelay-cahinによって監督され、互いのparachainの状態を監視し合うことができる。なので、不正の目的地にトランザクションが送信された場合、一瞬で報告され目論見は失敗する。(リターンパスが存在しないので、2次トランザクションがこの理由で失敗した場合、オリジナルcallerに報告することができない。他のリカバリー方法が実行される必要がある。） 

## 5.5. PolkadotとEthereum
Ethereumのチューリング完全性により、お互いにインターオペラビリティを持つ可能性が豊富にあると考えている。少なくても、セキュリティを共有することはできると思う。簡単に言うと、私達はPolkadotからのトランザクションはバリデーターによって署名され、Ethereum上で運用することができ、送信先のコントラクトを起動できるということである。
 In the other direction,
we foresee the usage of specially formatted logs (events)
coming from a “break-out contract” to allow a swift verification that a particular message should be forwarded.

## 5.5.1. PolkadotからEthereum
Through the choice of a
BFT consensus mechanism with validators formed from a
set of stakeholders determined through an approval voting
mechanism, we are able to get a secure consensus with an
infrequently changing and modest number of validators.
In a system with a total of 144 validators, a block time of
4 seconds and a 900-block finality (allowing for malicious
behaviour such as double-votes to be reported, punished
and repaired), the validity of a block can reasonably be
considered proven through as little as 97 signatures (twothirds of 144 plus one) and a following 60-minute verification period where no challenges are deposited.
Ethereum is able to host a “break-in contract” which
can maintain the 144 signatories and be controlled by
them. Since elliptic curve digital signature (ECDSA) recovery takes only 3,000 gas under the EVM, and since
we would likely only want the validation to happen on a
super-majority of validators (rather than full unanimity),
the base cost of Ethereum confirming that an instruction
was properly validated as coming from the Polkadot network would be no more than 300,000 gas—a mere 6% of
the total block gas limit at 5.5M. Increasing the number of validators (as would be necessary for dealing with
dozens of chains) inevitably increases this cost, however
it is broadly expected for Ethereum’s transaction bandwidth to grow over time as the technology matures and
infrastructure improves. Together with the fact that not
all validators need to be involved (e.g. only the highest
staked validators may be called upon for such a task) the
limits of this mechanism extend reasonably well.
Assuming a daily rotation of such validators (which is
fairly conservative—weekly or even monthly may be acceptable), then the cost to the network of maintaining
this Ethereum-forwarding bridge would be around 540,000
gas per day or, at present gas prices, $45 per year. A basic transaction forwarded alone over the bridge would cost
around $0.11; additional contract computation would cost
more, of course. By buffering and bundling transactions
together, the break-in authorisation costs can easily be
shared, reducing the cost per transaction substantially;
if 20 transactions were required before forwarding, then
the cost for forwarding a basic transaction would fall to
around $0.01.
One interesting, and cheaper, alternative to this multisignature contract model would be to use threshold signatures in order to achieve the multi-lateral ownership semantics. While threshold signature schemes for ECDSA
are computationally expensive, those for other schemes
such as Schnorr signatures are very reasonable. Ethereum
plans to introduce primitives which would make such
schemes cheap to use in the upcoming Metropolis hardfork. If such a means were able to be utilised, the gas costs
for forwarding a Polkadot transaction into the Ethereum
network would be dramatically reduced to a near zero
overhead over and above the basic costs for validating the
signature and executing the underlying transaction.

In this model, Polkadot’s validator nodes would have
to do little other than sign messages. To get the transactions actually routed onto the Ethereum network, we
assume either validators themselves would also reside on
the Ethereum network or, more likely, that small bounties
be offered to the first actor who forwards the message on
to the network (the bounty could trivially be paid to the
transaction originator).

## 5.5.2. EthereumからPolkadot
Getting transactions to be
forwarded from Ethereum to Polkadot uses the simple notion of logs. When an Ethereum contract wishes to dispatch a transaction to a particular parachain of Polkadot,
it need simply call into a special “break-out contract”.
The break-out contract would take any payment that may
be required and issue a logging instruction so that its existence may be proven through a Merkle proof and an assertion that the corresponding block’s header is valid and
canonical.
Of the latter two conditions, validity is perhaps the
most straightforward to prove. In principle, the only requirement is for each Polkadot node needing the proof
(i.e. appointed validator nodes) to be running a fully synchronised instance of a standard Ethereum node. Unfortunately, this is itself a rather heavy dependency. A more
lightweight method would be to use a simple proof that the
header was evaluated correctly through supplying only the
part of Ethereum’s state trie needed to properly execute
the transactions in the block and check that the logs (contained in the block receipt) are valid. Such “SPV-like”6
proofs may yet require a substantial amount of information; conveniently, they would typically not be needed at
all: a bond system inside Polkadot would allow bonded
third-parties to submit headers at the risk of losing their
bond should some other third-party (such as a “fisherman”, see 6.2.3) provide a proof that the header is invalid
(specifically that the state root or receipt roots were impostors).
On a non-finalising PoW network like Ethereum, the
canonicality is impossible to proof conclusively. To address this, applications that attempt to rely on any kind
of chain-dependent cause-effect wait for a number of “confirmations”, or until the dependent transaction is at some
particular depth within the chain. On Ethereum, this
depth varies from 1 block for the least valuable transactions with no known network issues to 1200 blocks as was
the case during the initial Frontier release for exchanges.
On the stable “Homestead” network, this figure sits at
120 blocks for most exchanges, and we would likely take
a similar parameter.
So we can imagine our Polkadot-side Ethereuminterface to have some simple functions: to be able to
accept a new header from the Ethereum network and validate the PoW, to be able to accept some proof that a
particular log was emitted by the Ethereum-side breakout contract for a header of sufficient depth (and forward
the corresponding message within Polkadot) and finally
to be able to accept proofs that a previously accepted but
not-yet-enacted header contains an invalid receipt root.
To actually get the Ethereum header data itself (and
any SPV proofs or validity/canonicality refutations) into
the Polkadot network, an incentivisation for forwarding data is needed. This could be as simple as a payment
(funded from fees collected on the Ethereum side) paid
to anyone able to forward a useful block whose header is
valid. Validators would be called upon to retain information relating to the last few thousand blocks in order to
be able to manage forks, either through some protocolintrinsic means or through a contract maintained on the
relay chain.

## 5.6. PolkadotとBitcoin
Bitcoin interoperation
presents an interesting challenge for Polkadot: a so-called
“two-way peg” would be a useful piece of infrastructure
to have on the side of both networks. However, due to
the limitations of Bitcoin, providing such a peg securely is
a non-trivial undertaking. Delivering a transaction from
Bitcoin to Polkadot can in principle be done with a process similar to that for Ethereum; a “break-out address”
controlled in some way by the Polkadot validators could
receive transferred tokens (and data sent alongside them).
SPV proofs could be provided by incentivised oracles and,
together with a confirmation period, a bounty given for
identifying non-canonical blocks implying the transaction
has been “double-spent”. Any tokens then owned in the
“break-out address” would then, in principle, be controlled by those same validators for later dispersal.
The problem however is how the deposits can be securely controlled from a rotating validator set. Unlike
Ethereum which is able to make arbitrary decisions based
upon combinations of signatures, Bitcoin is substantially
more limited, with most clients accepting only multisignature transactions with a maximum of 3 parties. Extending this to 36, or indeed thousands as might ultimately be desired, is impossible under the current protocol. One option is to alter the Bitcoin protocol to enable
such functionality, however so-called “hard forks” in the
Bitcoin world are difficult to arrange judging by recent attempts. One possibility is the use of threshold signatures,
cryptographic schemes to allow a singly identifiable public
key to be effectively controlled by multiple secret “parts”,
some or all of which must be utilised to create a valid signature. Unfortunately, threshold signatures compatible
with Bitcoin’s ECDSA are computationally expensive to
create and of polynomial complexity. Other schemes such
a Schnorr signatures provide far lower costs, however the
timeline on which they may be introduced into the Bitcoin
protocol is uncertain.
Since the ultimate security of the deposits rests with
a number of bonded validators, one other option is to
reduce the multi-signature key-holders to only a heavily
bonded subset of the total validators such that threshold
signatures become feasible (or, at worst, Bitcoin’s native
multi-signature is possible). This of course reduces the
total amount of bonds that could be deducted in reparations should the validators behave illegally, however this
is a graceful degradation, simply setting an upper limit of
the amount of funds that can securely run between the
two networks (or indeed, on the % losses should an attack
from the validators succeed).
As such we believe it not unrealistic to place a reasonably secure Bitcoin interoperability “virtual parachain” between the two networks, though nonetheless a substantial effort with an uncertain timeline and quite possibly
requiring the cooperation of the stakeholders within that
network.