# PolkadotWP

# POLKADOT: VISION FOR A HETEROGENEOUS MULTI-CHAIN FRAMEWORK DRAFT 1

DR. GAVIN WOOD
FOUNDER, ETHEREUM & PARITY
GAVIN@PARITY.IO

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

現時点では、私達は最初の2つの問題に着手するつもりであるが、Polkadotのフレームワークがこれらの問題に多大な改善をもたらすことができると信じている。Parity Ethereumのような実用的なブロックチェーンの実装は、性能の良いハードウェアを用いると秒回3000トランザクションを超える処理が可能である。しかし、現実のブロックチェーンネットワークでは秒間30トランザクションに制限されている。この制限は主に同期を取るコンセンサスメカニズムが安全性のために時間を要するように設計されている。

https://polkadot.network/PolkaDotPaper.pdf