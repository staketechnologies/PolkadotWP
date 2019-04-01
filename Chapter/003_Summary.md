## まとめ
Polkadotはスケーリングを見込んだ異種混合のマルチチェーンである。つまり、一般的なアプリケーションに特化したいままでの単一ブロックチェーンの実装とはことなり、Polkadotそれ自体はアプリケーションを継承する構造をとっていない。むしろ、Polkadotは“relay-chain”という基盤をもっており、その上に沢山の検証性を持つグローバルで一貫性のあるダイナミックなデータ構造が繋がれる。我々はそれらのデータ構造をを“parallelised”チェーンもしくはparachainsと呼んでいる。言い換えると、Polkadotは2つの重要な点を除けば自立したチェーンのセットと同じようなものだと考えられる。(例：Ethereum, Ethereum Classic, NamecoinとBitcoinのおセット)

- プールされたセキュリティ
- トラストフリーインターチェーントランザクション

これらの点は、私達がPolkadotがスケールすることができると考えている理由である。In principle, a problem to be deployed on Polkadot may be substantially parallelised—scaled out—over a large number of parachains. それぞれのパラチェーン全ての機能がPolkadotネットワークの異なるセグメントで同時処理されるため、システムにはスケールする余地がある。Polkadotはインフラストラクチャーのコア部分をミドルウェアレベルでは複雑な仕様を扱えるようにしながら提供している。この背景には、開発リスクを減らし短時間で効率的な開発ができるように、そして安全性と堅牢性を備えることができるようにように設計するという重要な意思決定がある。

### 3.1. Polkadotの哲学
Polkadotはその上に、萌芽期のアイデアから熟練したデザインまで対応する次の波となるコンセンサスシステムを実装する極めて堅牢な基盤を提供するべきだ。安全性、独自性、相互通信性に関して強い保証を提供することで、Polkadotはparachain自体に拡張範囲を選択させている。当然のことながら、私達は様々なブロックチェーンの実験が実用的な構成要素の開発の手立てになると考えている。

私達はBitcoin or Z-cashのような保守的で、高価値が乗っているチェーンが価値が乗っていない“theme-chains” （マーケティング目的や遊びで作ったもの）と0ないしほぼ0料金のテストネットと共存すると考えている。また、完全に暗号化された"暗い"コンソーシアムチェーンが、機能性に長けオープンであるEthereumのようなチェーンとですら繋がると考えている。成熟したEthereumや型が定義されているBitcoinのようなチェーンから計算難易度の高い計算をアウトソースされたWASMチェーンといった実験的なVMベースですら共存するだろう。

チェーンのアップグレードを管理するために、Polkadotは固有のガバナンス構造をサポートしている。

To manage chain upgrades, Polkadot will inherently
support some sort of governance structure, likely based
on existing stable political systems and having a bicameral aspect similar to the Yellow Paper Council [24]. As
the ultimate authority, the underlying stakable token holders would have “referendum” control. To reflect the users’
need for development but the developers’ need for legitimacy, we expect a reasonable direction would be to form
the two chambers from a “user” committee (made up of
bonded validators) and a “technical” committee made up
of major client developers and ecosystem players. The
body of token holders would maintain the ultimate legitimacy and form a supermajority to augment, reparameterise, replace or dissolve this structure, something we
don’t doubt the eventual need for: in the words of Twain
“Governments and diapers must be changed often, and for
the same reason”.

https://polkadot.network/PolkaDotPaper.pdf