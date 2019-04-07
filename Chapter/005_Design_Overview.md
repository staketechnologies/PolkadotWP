このセクションではシステム全体の設計像を簡潔に説明する。システムの詳細な説明は章を追って解説する。

## 5.1. コンセンサス
relay-chainでは、Polkadotは正当なブロックが同期性のあるByzantine faulttolerant (BFT)アルゴリズムを通して合意される。このアルゴリズムはTendermint [11]によってインスパイアされたものである。そして、副次的にHoneyBadgerBFT [14]に似通っている。後者は任意の不完全性のある
ネットワークインフラで正常に動作する権威者もしくはバリデーターがいれば効率的でfault-tolerantのコンセンサスを提供する。

proof-of-authority (PoA)スタイルのネットワークでは、これだけで十分である。しかし、Polkadotは信頼される権威者や3rdパーティーが存在しない完全にOpenでパブリックな環境ネットワークとしてデプロイが可能であるように設計されている。なので私達にはバリデーターを決定し、正直に動くためにインセンティブ設計する必要がある。なので、PoSベースの選考基準を設ける。

## 5.2. 掛け金を証明する
私達はネットワークに特定のアカウントがいくらの"掛け金"を持っているのかを測る方法があることを想定している。 既存のシステムと比較しやすいように計測する単位を"トークン"とする。この言葉はいくつかの理由で理想的ではない。1つはアカウントに紐付いている値がスカラー値であるとは限らないこと。もう1つは個別のトークンに特有性がないからである。

![]()

私達は、頻度は高くないが（最大でも1日に1回、もしかすると4半期に1回ほど）Nominated Proof-of-Stake (NPoS)によってバリデーターは選出されることを想定している。Incentivisation can happen through a pro-rata allocation of funds coming from a token base expansion (up to 100%
per year, though more likely around 10%) together with any transaction fees collected. マネタリーベースの膨張は主にインフレーションをもたらすけれども、全てのトークン保有者が参加権をフェアに持つので、時とともに価値がへるという心配をする必要がない。そのことでコンセンサスメカニズムにおけるトークンホルダーの役割を喜んでこなすようになる。トークンの特定の割合がステーキングプロセスのターゲットとなる。効率的なトークンベースの増加（token base expansion）はマーケットベースのメカニズムでこのターゲット値に近づくように調整される。

バリデーターは掛け金によって密接につながっている。バリデーターが掛け金を引き出すことができるのは、バリデーターの責務が終わり時間が経ってからである。（3ヶ月くらい）この長い期間が存在するのは、チェーンのチェックポイントまでバリデーターが将来不正を行った場合罰するためである。報酬額を削減したり、意図的にネットワークを悪化させたり、他のバリデーターに掛け金を渡したりした場合、罰を受けることになる。例えば、バリデーターがフォークした両方のチェーンを承認しようとした場合（しばしばショートレンジアタックと呼ばれる）、後々それが検知され罰せられる。

ロングレンジ“nothing-at-stake”攻撃を

Long-range “nothing-at-stake” attacks4
are circumvented through a simple “checkpoint” latch which prevents a dangerous chain-reorganisation of more than a
particular chain-depth. To ensure newly-syncing clients
are not able to be fooled onto the wrong chain, regular
“hard forks” will occur (of at most the same period of the
validators’ bond liquidation) that hard-code recent checkpoint block hashes into clients. This plays well with a further footprint-reducing measure of “finite chain length” or
periodic reseting of the genesis-block.
