## まとめ
Polkadotはスケーリングを見込んだ異種混合のマルチチェーンである。つまり、一般的なアプリケーションに特化したいままでの単一ブロックチェーンの実装とはことなり、Polkadotそれ自体はアプリケーションを継承する構造をとっていない。むしろ、Polkadotは“relay-chain”という基盤をもっており、その上に沢山の検証性を持つグローバルで一貫性のあるダイナミックなデータ構造が繋がれる。我々はそれらのデータ構造をを“parallelised”チェーンもしくはparachainsと呼んでいる。言い換えると、Polkadotは2つの重要な点を除けば自立したチェーンのセットと同じようなものだと考えられる。(例：Ethereum, Ethereum Classic, NamecoinとBitcoinのおセット)

- プールされたセキュリティ
- トラストフリーインターチェーントランザクション

これらの点は、私達がPolkadotがスケールすることができると考えている理由である。In principle, a problem to be deployed on Polkadot may be substantially parallelised—scaled out—over a large number of parachains. それぞれのパラチェーン全ての機能がPolkadotネットワークの異なるセグメントで同時処理されるため、システムにはスケールする余地がある。Polkadotはインフラストラクチャーのコア部分をミドルウェアレベルでは複雑な仕様を扱えるようにしながら提供している。この背景には、開発リスクを減らし短時間で効率的な開発ができるように、そして安全性と堅牢性を備えることができるようにように設計するという重要な意思決定がある。

### 3.1. Polkadotの哲学
Polkadotはその上に、萌芽期のアイデアから熟練したデザインまで対応する次の波となるコンセンサスシステムを実装する極めて堅牢な基盤を提供するべきだ。安全性、独自性、相互通信性に関して強い保証を提供することで、Polkadotはparachain自体に拡張範囲を選択させている。当然のことながら、私達は様々なブロックチェーンの実験が実用的な構成要素の開発の手立てになると考えている。

私達はBitcoin or Z-cashのような保守的で、高価値が乗っているチェーンが価値が乗っていない“theme-chains” （マーケティング目的や遊びで作ったもの）と0ないしほぼ0料金のテストネットと共存すると考えている。また、完全に暗号化された"暗い"コンソーシアムチェーンが、機能性に長けオープンであるEthereumのようなチェーンとですら繋がると考えている。成熟したEthereumや型が定義されているBitcoinのようなチェーンから計算難易度の高い計算をアウトソースされたWASMチェーンといった実験的なVMベースですら共存するだろう。

チェーンのアップグレードを管理するために、Polkadotはできるだけ既存のシステムとYellow peperでいうCouncilと類似した2院制に基づいた固有のガバナンス構造をサポートしている。

絶対的な権限としてトークンホルダーは"一般投票"をコントロールするを持つ。ユーザーの開発ニーズだけではなく、開発者のニーズを満たすために、私達は、バリデーターによる"ユーザー"の議会と開発者とエコシステムの参加者によって成り立つ"技術的な"議会"の2つが良い方向へ導いてくれることを期待している。トークンホルダーの核は絶対の正当性を保持し、多数の意見を増強したり、パラメーターで示したり、取替えたり、分解したりすることだ。Twainの言葉を借りれば、"政府とおむつはよく取り替えなければいけない。どちらも同じ理由で。" である。

一方で、パラメータを再構成するのは、
Whereas reparameterisation is typically trivial to arrange within a larger consensus mechanism, more qualitative changes such as replacement and augmentation would likely need to be either non-automated “soft-decrees” (e.g. through the canonicalisation of a block number and the hash of a document formally specifying the new protocol)
or necessitate the core consensus mechanism to contain a
sufficiently rich language to describe any aspect of itself
which may need to change. The latter is an eventual aim,
however, the former more likely to be chosen in order to
facilitate a reasonable development timeline.
Polkadot’s primary tenets and the rules within which
we evaluate all design decisions are:

最小限であること: Polkadotはできるだけ少ない機能で実装する

シンプル: 一般的にミドルウェア、Parachainもしくは後の実装に負荷をかけるベースプロトコルの複雑さを最小限に抑える

一般的であること: 不要な実装を避ける。制約や限界をParachainに設ける。Polkadotはどのモデルが一番堅牢かを最適化するコンセンサスシステム開発の基盤であるべきである。

堅牢であること: Polkadotは根本的に安定したベースレイヤーであるべきである。経済的な側面に加え、高いインセンティブをもつ攻撃の可能性を最小化する分散システムであることを意味する。