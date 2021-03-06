# Polkadotに参加する
Polkadotには4つの基本的な役割がある。すなわち、コレイター、 フィッシャーマン、 ノミネーターとバリデーターである。Polkadotの1つの取りうる実装では最後の役割は基本的なバリデーターと有用性の保証人という2つの役割に分けられる。これは後で議論されることになっている。

![Figure1](https://github.com/stakedtechnologies/PolkadotWP/blob/sota/img/Four_Roles.png)


## 4.1. バリデーター
バリデーターはPolkadotネットワークを管理し、新しいブロックを認証する。バリデーターの役割は十分に高額の掛け金がデポジットされているといることに依存している。これは、他の掛け金が賭けられている他のグループから1つ以上のバリデーターを選出し同じように振る舞わせることもできる。なので、バリデーターの掛け金の一部はバリデーターに管理される必要はなく、むしろノミネーターによって管理されていると言える。バリデーターは高い有用性と帯域が必要なクライアントをrelay-cahinで走らせなければならない。それぞれのブロックでノードはノミネートされたparachianで新しいブロックを検証する準備をしなければならない。このプロセスには候補となるブロックの受け取り検証、再発行が含まれている。ノミネーションは決定的であるが、現実的には事前に予測不可能である。バリデーターが全てのparachainのデータベースを全て同期するとは合理的に考えて考えられないので、バリデーターは提案された新しいparachainのブロックを確定する役割をコレイターとして知られる第三者に委託する。

全ての新しいparachainブロックが予定されたバリデーターのサブグループによって適切に検証されたら、バリデーターはrelay-chainのブロック自体を検証する。この作業にはトランザクションState文字列のアップデート（本質的にはparacahinのアウトプット文字列を他のparacahinのインプット文字列にデータを移すこと。）、検証されたrelaycahinのトランザクションセットのトランザクションを処理すること、最後のparachainの最終変更が含まれるファイナルブロックの承認が含まれている。

バリデーターは私達が選んだコンセンサスアルゴリズムのルール下で彼らの責任を満たさない行動を起こした場合、罰せられる。意図的ではない障害でも、バリデーターの報酬は差し控えられる。繰り返される機能停止は結果的にセキュリティーボンドの減少を招く（バーンを通して）。2重支払いや不正ブロックの共謀などの悪意ある攻撃によって全ての掛け金を失うことになるかもしれない。いくつかの観点で、バリデーターは現在のPoWチェーンにおけるマイニングプールに似ている。

## 4.2. ノミネーター
ノミネーターはバリデーターのセキュリティボンドに貢献するstake-holding partyである。リスクキャピタルを持ち、そのことによって彼らがネットワークをメンテナンスしている特定のバリデーター（もしくはグループ）を信頼していることを表明すること以外に追加での役割はない。彼らは掛け金の増加、減少に応じて対価を受け取る。次で説明するコレイターと一緒に、ノミネーターはPoWネットワークにおけるマイナーと似ている。

## 4.3. コレイター
トランザクションコレイター（略してコレイター）は、バリデーターが正当なparacahinブロックを生成するのをサポートするグループである。彼らは、特定のparachainの“full-node”を持つ。これは、現在のPoWブロックチェーンにてマイナーがしているのと同じように、新しいブロックを監視しトランザクションを実行する為に必要な情報を保持している。普通の状態では、まだ承認されていないブロックを生成するために、トランザクションを照合し実行する。そして、ゼロ知識証明と共にブロックをparachainのブロックを提案する責任をもっているバリデーターに伝播する。

コレイター、ノミネイター、バリデーターの正確な関係は時間とともに変更される可能性が高い。初期は、少数のparacahinとトランザクションが想定されるのでコレイターはバリデーターと密接に働くことを想定している。イニシャルのクライアント実装はparachainのコレイターノードが無条件に正当だとされているparacahinのブロックをrelaycahinのバリデーターに提供するためにRPCを含んでいる。同期されたバージョンの全てのパラチェーンの保管コストが増加するので追加で、そのコストを分散化する経済的インセンティブ設計のあるグループが活動するインフラを作ることが見込まれる。 

最終的には、ほぼすべてのトランザクションフィーを回収しようと競争するコレイタープールの存在を期待している。そのようなコレイターは報酬のシェアを目的として特定のバリデーターと一定期間契約を結ぶようになるかもしれない。

代用となる"フリーランス"的なコレイターはmay simply create a market offering valid parachain blocks in return for a competitive share of the reward payable immediately. シンプルに、分散化されたノミネイターのプールは掛け金を入れている複数の参加者にバリデーターの仕事をシェアしコーディネートする。これはプールにおけるオープンな参加モデルはさらに分散化したシステムの構築をもたらす。

## 4.4. フィッシャーマン
他の2つの役割とは異なり、フィッシャーマンはブロックの承認プロセスに直接関わってはいない。むしろ、報酬によってモチベートされた“bounty hunters”として独立している。正確にはフィッシャーマンの存在によってめったに不正行為が起きないことが想定されている。そして、もし不正行為が起こるのであれば悪意ある攻撃というよりもシークレットキーのセキュリティに注意が足りなかったときである。The name comes　from the expected frequency of reward, the minimal requirements to take part and the eventual reward size.

フィッシャーマンは少なくても1つの掛け金がされている参加者が不正な行為をしたことを時間内に証明することで報酬が得られる。paracahinの場合は、不正行為は同じ鍵で2つの異なるブロックに署名をしたり、不正なブロックを承認するのを手伝ったりすることである。規格外の報酬やセッションのシークレットキーを悪用するのを防ぐために、単一のバリデーターの悪意ある署名メッセージを提供することのベース報酬は最小限に抑えられている。この報酬は他のバリデーターも同様に悪意ある攻撃を仕掛けようとしていた場合、漸近的に増加する。最低でも2/3のバリデーターが善意のある行動をしているというベースセキュリティでは、漸近率は66%に設定されている。

フィッシャーマンはいくつかの点で必要とされているリソースが相対的に少量で安定性と帯域がそれほど必要ではない現在のブロックチェーンシステムにおける"full nodes"に似ている。フィッシャーマンは少量の掛け金を支払うという点で異なる。この掛け金はバリデーターの時間とコンピュテーションリソースを奪うという点でシビリアタックを防ぐ効果がある。掛け金はすぐに引き出すことができる。これはおそらく数ドル程度で悪意あるバリデーターの攻撃を防ぐことによって大量の報酬を得ることができる。
