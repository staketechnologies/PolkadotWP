このセクションではシステム全体の設計像を簡潔に説明する。システムの詳細な説明は章を追って解説する。

## 5.1. コンセンサス
relay-chainでは、Polkadotは正当なブロックが同期性のあるByzantine faulttolerant (BFT)アルゴリズムを通して合意される。このアルゴリズムはTendermint [11]によってインスパイアされたものである。そして、副次的にHoneyBadgerBFT [14]に似通っている。後者は任意の不完全性のある
ネットワークインフラで正常に動作する権威者もしくはバリデーターがいれば効率的でfault-tolerantのコンセンサスを提供する。

proof-of-authority (PoA)スタイルのネットワークでは、これだけで十分である。しかし、Polkadotは信頼される権威者や3rdパーティーが存在しない完全にOpenでパブリックな環境ネットワークとしてデプロイが可能であるように設計されている。なので私達にはバリデーターを決定し、正直に動くためにインセンティブ設計する必要がある。なので、PoSベースの選考基準を設ける。

## 5.2. 掛け金を証明する
私達はネットワークに特定のアカウントがいくらの"掛け金"を持っているのかを測る方法があることを想定している。 既存のシステムと比較しやすいように計測する単位を"トークン"とする。この言葉はいくつかの理由で理想的ではない。1つはアカウントに紐付いている値がスカラー値であるとは限らないこと。もう1つは個別のトークンに特有性がないからである。

We imagine validators be elected, infrequently (at most
once per day but perhaps as seldom as once per quarter),
through a Nominated Proof-of-Stake (NPoS) scheme. Incentivisation can happen through a pro-rata allocation of funds coming from a token base expansion (up to 100%
per year, though more likely around 10%) together with
any transaction fees collected. While monetary base expansion typically leads to inflation, since all token owners
would have a fair opportunity at participation, no tokenholder would need to suffer a reduction in value of their
holdings over time provided they were happy to take a
role in the consensus mechanism. A particular proportion
of tokens would be targeted for the staking process; the
effective token base expansion would be adjusted through
a market-based mechanism to reach this target.