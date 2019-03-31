# PolkadotWP

# POLKADOT: VISION FOR A HETEROGENEOUS MULTI-CHAIN FRAMEWORK DRAFT 1

DR. GAVIN WOOD
FOUNDER, ETHEREUM & PARITY
GAVIN@PARITY.IO

翻訳者：
- Sota Watanabe（Twitter @WatanabeSota）
- Masaki Minamide (Twitter @raika_5179)

## 概要
現在のブロックチェーンアーキテクチャーは拡張性やスケーラビリティに留まらず、様々な問題点を抱えている。私達はこの理由を、簡潔さと正当性という2つのコンセンサスアーキテクチャーの重要な2つの要素が密接に絡むことに起因すると考えている。このペーパーでは、この2つの要素を合わせた混合のマルチチェーンのアーキテクチャを紹介する。

In compartmentalising these two parts, and by keeping the overall functionality provided to an absolute minimum
of security and transport, we introduce practical means of core extensibility in situ. Scalability is addressed through
a divide-and-conquer approach to these two functions, scaling out of its bonded core through the incentivisation of
untrusted public nodes.
The heterogeneous nature of this architecture enables many highly divergent types of consensus systems interoperating in a trustless, fully decentralised “federation”, allowing open and closed networks to have trust-free access to
each other.
We put forward a means of providing backwards compatibility with one or more pre-existing networks such as
Ethereum. We believe that such a system provides a useful base-level component in the overall search for a practically
implementable system capable of achieving global-commerce levels of scalability and privacy.

## 1.序章
このペーパーは現実的にさらなるブロックチェーンのパラダイムを作っていく過程で取りうる1つの方向性を示唆した技術的な"ビジョン"のサマリーである。また、ブロックチェーン技術の様々な観点での具体的な改善策を提供する開発システムを現時点で可能な限り詳細を述べる。

このペーパーは、公式な詳細仕様書であることを意図していない。また、包括的な最終デザインであるわけでもない。APIやバインディング、言語や使用方法をカバーすることもしない。パラメーターは特定されているが変更が見込まれる極めて実験的なペーパーである。コミュニティーのアイデアや批評によってメカニズムが追加されるかもしれないし、修正、削除されるかもしれない。実験的なエビデンスとプロトタイピングによって何ができて何ができないのかがわかるので、このペーパーの大部分が修正されることもありうる。このドキュメントには様々な部分をより良くするかもしれないアイデアを含むプロトコルの詳細が述べられている。その詳細は初期Proof-of-Concept（実証実験）のベースになるものとして期待されている。最終的に完成する“version 1.0”は本プロジェクトの目的を達成するためのさらなるアイデアが反映され、修正されたプロトコルが基になるだろう。

### 1.1 歴史
- 09/10/2016: 0.1.0-proof1
- 20/10/2016: 0.1.0-proof2
- 01/11/2016: 0.1.0-proof3
- 10/11/2016: 0.1.0

## 2. イントロダクション
ブロックチェーンは“Internet of Things”(IoT)、ファイナンス、ガバナンス、アイデンティティマネジメント、分散ウェブ、アセットトラッキングなど様々なフィールドで実用的であることを証明してきた。しかし、技術の素晴らしさと誇張された話しの裏腹で、ブロックチェーンが実社会に多大な影響を与えているというわけではない。私達はこれは現在のテクノロジースタックの5つの鍵となる問題点があるからだと考えている。

**スケーラビリティ**：単一のトランザクションがシステム上で処理されるまでバンドウィズ、ストレージを含め全体でどれくらいリソースを費やしているか。そして、最大でどれくらいのトランザクションが処理できるか？

**孤立性**: Can the divergent needs of multiple
parties and applications be addressed to a nearoptimal degree under the same framework?

**開発可用性**: ツールがどレくらいよく動くか？APIは開発者のニーズに答えられているか？教育用のツールは整っているか？正しいインテグレーションんがあるか？

**ガバナンス**: ネットワークが柔軟に何度も進化し変更する余地が残されているか？包括的に意思決定ができる仕組みか？効率的なリーダーシップをもたらす正当性と透明性がある分散システムか？

**適応性**: 技術が必要としているニーズにあっているか？現実のアプリケーションとのギャップを埋めるために"ミドルウェア"が必要か？

現時点では、私達は最初の2つの問題に着手するつもりであるが、Polkadotのフレームワークがこれらの問題に多大な改善をもたらすことができると信じている。Parity Ethereumのような実用的なブロックチェーンの実装は、性能の良いハードウェアを用いると秒回3000トランザクションを超える処理が可能である。しかし、現実のブロックチェーンネットワークでは秒間30トランザクションに制限されている。この制限は主に同期を取るコンセンサスメカニズムが、安全性のために時間を要するように設計されているから存在している。これは根底にあるコンセンサスアーキテクチャーによるものである。state transition mechanismはトランザクションを収集し処理する過程で様々な正当性や歴史に同意をとり、かつ「同期」するメカニズムである。

このシステムはproof-of-work (PoW)システムで可動しているBitcoinやEthereumや、proofof-stake (PoS)で可動しているNXTやBitsharesにも同じく適応できる。（注、EthereumはPoSに移行）これらはどれも同じハンディーキャップを抱えている。この問題を解決できればブロックチェーンが更に良いものになることは間違いないが、これらの2つのメカニズムを1つのプロトコルで扱うには、リスクやスケーラビリティ能力、プライバシー要求が異なる様々な全く別の主体やアプリケーションを一緒に扱わなければならない。One size does not fit all. Too often it is the case that in a
desire for broad appeal, a network adopts a degree of conservatism which results in a lowest-common-denominator
optimally serving few and ultimately leading to a failing
in the ability to innovate, perform and adapt, sometimes
dramatically so.

Factomのようないくつかのシステムはstatetransitionメカニズムを取り入れていない。しかし、However, much of the
utility that we desire requires the ability to transition state according to a shared state-machine. Dropping it solves
an alternative problem; it does not provide an alternative solution.

従って、スケールする分散コンピュートシステムを開発する合理的な打ち手はコンセンサスアーキテクチャーをstate-transitionメカニズムから切り離すことであることは明らかであるかのように見える。そして、驚くことではないかもしれないが、これがPolkadotがスケーリングソリューションである所以なのだ。

### 2.1 プロトコル、実装、ネットワーク
Bitcoin、Ethereumと同じように、Polkadotはネットワークプロトコルとそのプロトコルで動くパブリックネットワークであると言及される。 PolkadotはCreative Commons licenseでコードはFLOSS licenseの下、無料でオープンなプロジェクトを意図して作成されている。オープンソースで開発されているこのプロジェクトは誰であれコントリビューションを行うことができる。RFCsのシステムは、Python Enhancement Proposalsと同じようにプロトコルの変更やアップデートにあたり公開された形で共同開発できるように設計されている。APIを含むPolkadotプロトコルの私達の最初の実装はParity Polkadot Platformとして知られることとなるだろう。Parityの他のブロックチェーンの実装と同じようにPPPはパブリックブロックチェーンやプライベート/コンソーシアムブロックチェーンに限らず汎用目的ブロックチェーン技術として開発されており、開発はイギリス政府を含むいくつかの団体からの補助金を基に行われている。このペーパーは言うまでもなくパブリックネットワーク下でPolkadotを描写している。パブリックネットワークで私達が思い描く機能は他のネットワーク（例：パブリックor/andプライベート）の上位互換である。さらに、この文脈でPolkadotの全容がさらにはっきり明記され議論することもできるだろう。これはつまり、読者があるメカニズムのどれがPolkadotに関連しているか、いつパブリックでない環境にデプロイされたかなどを注意しなければならないということである。

### 2.2. 先行研究
コンセンサスをstate-transitionから切り離す方法というのは正式にではないが、少なくても2年間は提唱され続けている。この方法の提唱者であるMax KayeはEthereumのかなり初期のメンバーでもあった。2014年6月にまでさかのぼりその次の年に公開されたChain fibersとして知られる複雑なスケーラブルソリューションは単体のRelay-cahinと透明性の高いインターチェーン処理メカニズムを提供する混合の複数のチェーンチェーンを実装した。Decoherence was paid for
through transaction latency—transactions requiring the coordination of disparate portions of the system would
take longer to process. Polkadotはその大部分のデザインと設計は異なるものの、アーキテクチャーの多くは参考にしている。Polkadotと比べうるシステムは実際のところ存在していないけれど、他のいくつかのシステムで結局は些細な部分であるが類似点が提案されているということもある。それらの提案をブレイクダウンするとグローバルに一貫性のあるstate machineを細かくしたものである。

#### 2.2.1. lobal Stateのないシステム
Factomは適切な検証なしの正当さとデータの同期を許すことによる効率さを実証したシステムである。

Because of the avoidance of global state and the difficulties
with scaling which this brings, it can be considered a scalable solution. However, as mentioned previously, the set
of problems it solves is strictly and substantially smaller.

Tangleはコンセンサスシステムに対する斬新なアプローチである。
Rather than arranging transactions into blocks and forming consensus over a strictly linked list to give a globally canonical ordering of state-changes, it largely abandons the idea of a heavily structured ordering and instead
pushes for a directed acyclic graph of dependent transactions with later items helping canonicalise earlier items
through explicit referencing. For arbitrary state-changes,
this dependency graph would quickly become intractable,
however for the much simpler UTXO model2
this becomes quite reasonable. Because the system is only loosely coherent and transactions are generally independent of each
other, a large amount of global parallelism becomes quite
natural. 

Using the UTXO model does have the effect
of limiting Tangle to a purely value-transfer “currency”
system rather than anything more general or extensible.
Furthermore without the hard global coherency, interaction with other systems—which tend to need an absolute
degree knowledge over the system state—becomes impractical.

#### 2.2.2. Heterogeneous Chain Systems
サイドチェーンはBitcoinプロトコルで提案された追加仕様であり、メインのビットコインと追加となるサイドチェーン間でトラストレスなやりとりを可能にするプロトコルである。サイドチェーン間での"濃い”やりとりは想定されていない。つまり、やりとりは制限されており両者のアセットの交換点（2 way peg点）で管理者が存在する。The end vision is for a framework where the Bitcoin currency could be provided with additional, if peripheral, functionality through pegging it onto some other chains with more exotic state transition
systems than the Bitcoin protocol allows. この意味で、サイドチェーンはスケーラビリティというよりはむしろ拡張性をもたらすものである。

もちろん、サイドチェーンの正当性に関しては根本的に用意されたものはなにもない。一つのチェーン（例：Bitcoin）上のトークンはマイナーに正当な正しいトランザクションを検証してもらうというサイドチェーンの能力によってのみ安全性が担保されている。Bitcoinのネットワークの安全性を他のブロックチェーンに移植することは簡単にできることではない。さらに、Bitcoinのマージマイニングを行うためのプロトコルはこのペーパーの対象外である。

CosmosはNakamoto PoWコンセンサスメソッドをJae KwonのTendermintアルゴリズムに変えたマルチチェーンシステムである。本質的には、Tendermintの個々のインスタンスを使ってZoneで運営されるマルチチェーンがmaster hub cahinを介しトレストフリーコミュニケーションを可能にする。このインターチェーンコミュニケーションは任意の情報というよりはデジタル・アセット（またの名をトークン）の移動に制限されている。しかし、そのようなインターチェーンコミュニケーションはdataの受け渡しも可能であるといえば可能である。

Validator sets for the zoned chains, and in particular the means of incentivising them, are, like side-chains, left as an unsolved problem. 一般的な予測では、各々のZoneチェーン自体でトークンを保有しており、その上昇価値がバリデーターに還元される。未だに、まだ初期のデザインなので、一貫性のある詳細を確認することはできないが、ZoneとHub間のゆるい一貫性はZoneチェーンのパラメーターに柔軟性を出すだろうと考えられる。

#### 2.2.3. Casper
2つの内1つがもう一方を不要にするという見解があるが、PolkadotとCasperに関する包括的な比較はまだ存在しない。Casperはどちらのフォークしたチェーンが正当になるのかについてPoSアルゴリズムによって参加者が賭けをした記録に基づいている。Substantial consideration was given to ensuring that it be robust to network forks, even when prolonged, and have some additional degree of scalability on top of the basic Ethereum model. なので、Casperは本質的にPolkadotや派生系よりも複雑なモデルであると言えるかもしれない。いかにCasperが将来発展するのか最終的にどのような形でデプロイされるのかは依然として不明である。

CasperもPolkadotも両者とも興味深い新しいプロトコルを提案している。そして、いくつかの点でEthereumの究極の目的と開発方向が食い違っている。CasperはEthereum Foundationが手動するプロジェクトで、元々は完全なスケーリングを意図しないプロトコルのPoSへの仕様変更であった。重要なことに、それはEthereumのすべてのクライアントにアップデートを要求するハードフォークであった。なので、開発は強い連携が必要であった分散プロジェクトを継承したものよりも本質的にさらに複雑になった。

Polkadotはいくつかの点で異なる。まず、
Polkadot differs in several ways; first and foremost,
Polkadot is designed to be a fully extensible and scalable
blockchain development, deployment and interaction test
bed. It is built to be a largely future-proof harness able to
assimilate new blockchain technology as it becomes available without over-complicated decentralised coordination
or hard forks. We already envision several use cases such
as encrypted consortium chains and high-frequency chains
with very low block times that are unrealistic to do in
any future version of Ethereum currently envisioned. Finally, the coupling between it and Ethereum is extremely
loose; no action on the part of Ethereum is necessary to
enable trustless transaction forwarding between the two
networks.
https://polkadot.network/PolkaDotPaper.pdf