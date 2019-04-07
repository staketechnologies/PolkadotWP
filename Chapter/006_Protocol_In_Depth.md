# 6. プロトコルの詳細

本プロトコルは大きく３つのパートに分解することができる：コンセンサスメカニズム、パラチェーンインターフェイス、インターチェーン取引ルーティング。

## 6.1. リレーチェーンオペレーション

リレーチェーンはイーサリアムと似たように、ステイトがアドレスをアカウント情報（主に残高や取引回数）にマッピングしたステイトベースのチェーンになるだろう。アカウントをここに置くことには目的が一つある：システムで誰がどれだけのステイクを保持しているかを説明すること。そこには大きな違いはない、しかし：

- コントラクトはトランザクションによって配置することはできない。リレーチェーン上のアプリケーション機能を回避したいという欲求から、契約のパブリックデプロイのサポートをしない。
- 計算リソース（ガス）の使用量は計上されない；パブリック使用のための機能のみが直されるため、ガス計上はされなくなる。
- リストに挙げられたコントラクトが自動執行とネットワークメッセージアウトプットをすることを可能にする特殊な機能サポートされる。

リレーチェーンにVMがあり、それがEVMをベースにしている場合、単純さを最大化するためにいくつかの変更が必要である。
リレーチェーンにはコンセンサス、バリデーター、パラチェーンコントラクトを行うために、プラットフォーム専用のいくつかの組込みコントラクト（Ethereumの1-4アドレスのような）が存在している。

EVMではない場合、WebAssembly [2]（wasm）バックエンドが最も可能性の高い代替手段である。この場合、全体構造は似ているが、埋め込みコントラクトの必要はない。これがEVMのために作られた未熟な言語ではなく汎用言語用であるWasmを使う理由である。

現在のEthereumプロトコルからの全く異なる他のプロトコルの可能性は十分にある。
例えば、EthereumのSerenityのために提案されたように、同一ブロック内で競合しないトランザクションの並列実行を可能にする、簡易的なトランザクション受信フォーマットなど。

これは可能性は低いが、Serenityのような「純粋（Pure）」なチェーンがチェーンの基礎的なプロトコルとしてではなく、Relayチェーンとしてデプロイされるかもしれない。これにより、特定のコントラクトがステイキングトークン残高などを管理することができる。
現時点では、これは追加の複雑さと開発に不確実性を伴う価値がある程の十分なプロトコル簡素化を提供する可能性が低いと感じている。

コンセンサスメカニズム、バリデータセット、バリデーションメカニズムおよびパラチェインを管理するために必要な機能のピースがいくつもある。
これらはモノリシックプロトコルの下で一緒に実装することが可能である。ただし、モジュール性を高めるために、これらをリレーチェーンの「コントラクト」として説明する。

これは、それらが（オブジェクト指向言語のような）オブジェクトであることを意味すると解釈される。リレーチェーンのコンセンサスメカニズムによって管理されているが、必ずしもEVMのようなopcodesでプログラムとして定義されているわけでも、アカウントシステムを通じて個別にアドレス指定可能であるというわけでもない。

6.2. ステイキング コントラクト
このコントラクトは以下のようにバリデータセットを管理する。

- どのアカウントが現在バリデータであるか（Validators）；
- どのアカウントがすぐにバリデータになることができるか（Intentions）；
- どのアカウントがバリデータにノミネートするためにステイクしているか（Stashes）；
- ステイク量、許容ペイアウト率、アドレス、短期（セッション）アイデンティティを含むそれぞれの特性（Others）；

それは、アカウントが（その要件と共に）担保付き（bonded）のバリデータになる、ノミネートする、そして既存の担保付きの検証者がこのステータスからエグジットする意思を登録する。またバリデーションと正規化メカニズムのためのメカニズムも含みます。

6.2.1.ステークトークンの流動性
ネットワークセキュリティをステークトークンの全体的な「時価総額」に直結させるため、一般に、できるだけ多くのトータルステーキングトークンをネットワークメンテナンス操作内でステークすることが望ましい。これは、通貨のインフレを通し、収益をバリデータとして参加する人々に配ることによって、容易にインセンティブ設計することができる。しかし、そうすることは一つ問題を提起する：トークンがステークコントラクトでロックされるならば、価格向上を実現するためにどのように十分な流動性を維持できるのか？

これに対する1つの答えは、直接的なデリバティブコントラクトを許可し、ステイクされたトークン上で代替可能（Fungible)なトークンを保護することだ。これは信頼できる方法で手配するのが困難だ。さらに、これらのデリバティブトークンは、異なるユーロ圏の国債が代替可能ではないのと同じ理由で同等に扱うことはできない：原資産が破綻し、価値がなくなる可能性がある。ユーロ圏の政府では、これがデフォルトとなるかもしれない。しかしバリデータがステイクしたトークンの場合、バリデータの悪意を持った行動には処罰が伴う。

私たちは信条を守りながら、最も単純な解決策を選んだ：全てのトークンはステイクされない。つまりは、ある一定の割合（おそらく20％程度）のトークンが強制的に流動性を維持することを意味する。これはセキュリティの観点からは不完全だが、ネットワークのセキュリティに根本的な違いをもたらすことはまずありえない。ステイクの没収による賠償金の80％と、100％のステークの「完璧なケース」との大差はそれほどない。

ステイクされるトークンと流動的なトークンの比率はリバースオークションの仕組みによって案外簡単に決められる。基本的に、バリデーターになりたいトークン保有者はそれぞれ、参加するために必要となる最小支払い率を記載したオファーをステーキング契約に投稿します。各セッションの開始時に（セッションは定期的に、おそらく1時間に1回程度）、各バリデーターのステークとペイアウト率に従ってバリデータースロットが満たされる。これに対する１つの可能なアルゴリズムは、目標総賭け金をスロット数で割った数以下で、その額の半分の下限を下回らない賭け金を表す最低オファーを有するものを選ぶことであろう。スロットを埋めることができない場合は、満たすために下限が何らかの要因で繰り返し引き下げられる。

ステイクしているトークンをアクティブなバリデータにトラストレスにノミネートすることは可能だ。それはバリデータに責任を任せる事になる。ノミネーションは承認投票システムによって行われる。それぞれのノミネーター志望者は、自らの責任の下で彼らがステイクを賭けるのに十分な信頼を置く、一人以上のバリデータをステークコントラクト上に登録することができる。

各セッションで、ノミネーターの掛け金は1人、またはそれ以上のバリデーターに分散される。分散アルゴリズムは、総賭け金がバリデーターセットに最適化する。(The dispersal algorithm optimises for a set of validators of equivalent total bonds.) ノミネーターの賭け金は、バリデーターの責任の下に置かれ、バリデーターの行動応じて利益を得るか、または処罰として減額を受ける。

6.2.3. 債権の没収/バーン
特定のバリデーターの振る舞いは賭け金に懲罰的な減少をもたらす。賭け金が許容最小額を下回ると、セッションは途中で終了し、別のセッションが開始される。処罰対象のバリデーターの不正行為のリストには以下が含まれる：

- パラチェインブロックの有効性についてコンセンサスを提供できないパラチェイングループの一員である
- 無効なパラチェインブロックの有効性について積極的に署名する
- 利用可能として以前に投票されたアウトバウンドペイロードを供給することができない
- 合意プロセス中に非活動的である
- 競合するフォークのリレーチェーンブロックを検証する

不正な悪意のある行動のケースによっては、ネットワークの完全性が損なわれ（無効なパラチェインブロックに署名したり、フォークの複数の面を検証したりするなど）、その結果、債権の完全な没収により追い出されることがある。その他の、それほど深刻ではない不正行為（例えば、合意プロセスにおける非活動）または誰の責任か不明瞭である（無効なグループの一部であるなど）場合、代わりに、債権のごく一部の罰金を科されることがある。後者の場合、これはサブグループchurnによって、悪意のあるノードが健全なノードよりより大きな損失を被るようにする。

場合によっては（マルチフォーク検証や無効なサブブロック署名など）、各パラチェインブロックを常に検証するのは面倒な作業になるため、バリデーターがお互いの不正行為を検出することは困難である。ここでは、そのような不正行為を検証し報告するために、検証プロセス外部にある組織の支援を必要とする。その役割を担った存在はそのような活動を報告することで報酬を得る。彼らの「Fisherman（釣り人）」という名前は、そのような稀な報酬に由来している。

これらのケースは通常非常に深刻であるため、いかなる報酬も没収された債券から容易に支払うことができると我々は考えている。一般的に、大規模な再割り当てを試みるのではなく、バーン（つまり、何もしないこと）により再割り当てのバランスを取ることが好ましい。これはトークンの全体的な価値を増加させ、発見に関与する特定の関係者よりもむしろネットワークに対して補償する効果がある。これは主に安全メカニズムとしてのものである。それは大量の報酬を伴ってしまう場合、単一のターゲットに対して報告する極端なインセンティブを与えてしまう事になるかもしれないからだ。

一般的に、報酬はネットワークにとって検証を行うのに十分なほどの大きさである必要がある一方、特定のバリデータに不正行為を強制させるような、組織化されたハッキング攻撃のインセンティブになるほど大きくないことが重要である。

このようにして、報酬は不正行為を行ったバリデータの債権量を超えないようにする必要がある。これは、検証者が故意的に不正行為を行い、自分自身を通報する事で利益を得ないようにするためである。これへの対処法として、バリデータになるのに最低限の賭け金を必要とすることや、ノミネーターに賭け金が少ないバリデーターは不正行為を行うインセンティブが大きい事実を啓蒙するなどがある。

## 6.3. パラチェーンレジストリ

各パラチェインはこのレジストリで定義されている。それは比較的単純なデータベースのような構造であり、そして各チェーンに関する静的な情報と動的な情報の両方を保持する。

静的情報には、異なるクラスのパラチェインを区別する手段である検証プロトコルの識別情報とともに、チェーンインデックス（単純な整数）が含まれる。これによって有効な候補を提示するために委任されたバリデータによって正しい検証アルゴリズムが実行される。
最初のPOCでは、新しい検証アルゴリズムをクライアント自体に配置することに重点が置かれ、追加のクラスのチェーンが追加されるたびにプロトコルのハードフォークが事実上必要になる。しかし最終的には、クライアントがハードフォークなしで新しいパラチェインを効果的に処理できるように、厳密かつ効率的な方法で検証アルゴリズムを指定することが可能である。これに対する1つの可能な方法は、WebAssemblyのような確立された、ネイティブにコンパイルされた、プラットフォームに依存しない言語でパラチェイン検証アルゴリズムを指定することである。これが本当に実現可能であるかどうかを判断するには追加の研究が必要だが、もしそうであれば、ハードフォークをしないことにより大きな利点をもたらす可能性がある。

動的情報には、パラチェーンの入力キュー（6.6.で説明）など、グローバルな合意が必要なトランザクションルーティングシステムの側面が含まれている。

レジストリは、全国民投票(referendum)によってのみ追加されたパラチェインを持つことができる。これは内部で管理できるが、より一般的なガバナンス要素のもとでの再利用を促進するために、外部の国民投票コントラクトに入れられる可能性が高くなる。追加チェーンの登録およびその他のあまり正式でないシステムアップグレードのための投票要件（たとえば、必要なクォーラム、大多数の要件）に対するパラメータは、「マスター規約」に記載されるが、少なくとも最初はかなり慣習的な方法に従う。正確な定式化は本研究の範囲外であるが、例えば、システムのステイクの3分の1以上が積極的に投票するという、3分の2のスーパーマジョリティが賢明な出発点となるだろう。

追加の操作には、パラチェーンの一時停止と削除が含まれる。中断は決して起こらないであろうと願っているが、それはパラチェーンのバリデーションシステムに少なくともいくらかの扱いにくい問題があることを保護するセーフガードの役目を担っている。それが必要とされる可能性がある最も顕著な例は、妥当性またはブロックについて合意することができないようにバリデータを導く実装間の重大なコンセンサスの違いである。バリデータは、債権の没収前にそのような問題を発見できるようにするために、複数のクライアント実装を使用することをお勧める。

一時停止は緊急措置であるため、国民投票ではなく動的バリデータ投票によって実行されるだろう。再検証はバリデータからも国民投票からも可能である。

パラチェーンの削除は、国民投票の後に初めて行われ、スタンドアロンチェーンへの秩序ある移行を可能にするため、または他の何らかの合意システムの一部となるためには、かなりの猶予期間が必要である。猶予期間は数ヶ月程度である可能性があり、異なるパラチェーンがそれぞれの必要性に応じて異なる猶予期間を享受できるようにするために、パラチェインレジストリにチェーンごとで設定される可能性がある。

## 6.4. リレーブロックのシーリング

シーリングとは、本質的には正規化のプロセスを指す。つまり、オリジナルを意味のあるものにマッピングする基本的なデータ変換のことである。POWチェーンの下では、シーリングは事実上マイニングの同義語である。私たちの場合、それは特定のリレーチェーンブロックとそれが表すパラチェーンブロックの有効性、可用性、そして正規性に関するバリデータからの署名されたステートメントの収集を意味する。

基礎となるBFTコンセンサスアルゴリズムのメカニズムの説明は今回の範疇外となる。代わりに、合意形成ステートマシンを想定したプリミティブを使って説明する。最終的には、コアにあるいくつかの有望なBFT合意アルゴリズム（Tangaora [9]（Raft [16]のBFT版）、Tendermint [11]、HoneyBadgerBFT [14]）にインスパイアされることを期待している。 このアルゴリズムは、複数のパラチェーンに並行して合意に達する必要があるため、通常のブロックチェーン合意メカニズムとは異なる。一旦合意に達すると、私たちはその合意を反論できない証拠として記録することができ、それは参加者の誰もが提供することができる。我々はまた、処罰に対処する際、プロトコル内の不正行為は一般に不正行為をする参加者を含む小グループにする事により、付随的な被害を最小限に抑えることができると想定している。Tendermint BFTやオリジナルのSlasherなど、既存のPoSベースのBFTコンセンサススキームは、これらの主張を満たしている。

署名付きステートメントの形式をとる証明は、リレーチェーンブロックのヘッダー、およびその他の特定のフィールド（リレーチェーンのステイトツリーのルートおよびトランザクションツリーのルート）と共に配置される。

シーリングプロセスは、リレーチェーンのブロックと、リレーのコンテンツの一部を構成するパラチェーンのブロックの両方に対応する単一の合意生成メカニズムの下で行われる。パラチェーンは、サブグループによって別々に「コミット」された後に照合されるわけではない。これにより、リレーチェーンの処理がより複雑になるが、システム全体の合意を1段階で完了し、待ち時間を最小限に抑え、以下のルーティング処理に役立つ非常に複雑なデータ可用性の要件を満たすことができる。

各参加者のコンセンサスマシンの状態は、単純な（2次元の）表としてモデル化できる。各参加者（バリデータ）は、各パラチェインブロック候補ならびにリレーチェインブロック候補に関して、他の参加者からの署名付きステートメント（Vote）の形式で一組の情報を有する。情報セットは2つ：

- 利用可能性（Availability）：このバリデータはこのブロックからのトランザクションの一連の情報を出力していか；故に次のブロックのパラチェイン候補を適切に検証できる。バリデータは1（知られている）か0（まだ知られていない）のどちらかを投票することができる。1を投票した場合、このプロセスの残りの部分についても同様に投票することに一貫する。これに従わない後からの投票は罰の対象となる。

- 妥当性（Validity)：このパラチェインブロックは有効であり、全ての外部参照データ（例えばトランザクション）は利用可能か。これは、投票しているパラチェーンに割り当てられているバリデータにのみ関係する。彼らは1（有効）、-1（無効）または0（まだ知られていない）のどれかに投票することができる。彼らがゼロでない(non-zero)投票をしたら、このプロセスの残りの部分についても同様に投票することに一貫する。これに従わない後からの投票は罰の対象となる。

すべての検証者が投票を提出する必要がある。票は上記の規則によって修飾され、再提出されることがある。合意の進行は、並行して行われる各パラチェインに対する複数の標準的なBFT合意アルゴリズムとしてモデル化することができる。これらは少数の悪意のあるアクターが1つのパラチェイングループに集中することよって潜在的に妨害される。そのため、バックストップを確立するための全体的なコンセンサスが存在し、１つ以上の向こうパラチェインブロックにデッドロックされる最悪のシナリオを防ぐ。

個々のブロックの有効性のための基本的な規則（はバリデータ全体が、正規のリレーから参照されるユニークなパラチェイン候補になることについて合意に達することを可能にする）：

- 少なくとも3分の2のバリデータがポジティブに投票し、誰もネガティブに投票しないこと。
- 3分の1を超えるバリデータが、外に出て行く情報の可用性にポジティブに投票している。

正当性について少なくとも1つの正と負の投票がある場合、例外条件が作成され、悪意のある当事者がいるかどうか、または偶然の分岐があるかどうかを判断するためにバリデータのセット全体が投票する必要がある。有効と無効の他に、その両方に対する投票と同等である3番目の種類の投票が許可されている。つまり、ノードには意見の対立がある。これは、ノードの所有者が同意しない複数の実装を実行していることが原因である可能性があり、プロトコルにあいまいさがある可能性があることを示している。

すべての投票が完全なバリデータセットの確認を経た後、負けた側の意見が勝った側の意見の投票のある程度の割合（パラメータ化されるために；最大で半分、おそらくかなりより少ない）を占める場合、それは偶然起こったパラチェーンフォークと考えられ、そのパラチェーンは自動的にコンセンサスプロセスから中断される。さもなければ、それは悪意のある行為であると考えられ、反対意見に投票していた少数派を罰することになる。

結論は、正規性を示す一連の署名である。（The conclusion is a set of signatures demonstrating canonicality.）その後、リレーチェーンブロックはシーリングされ、次のブロックをシーリングするプロセスが開始される。

6.5.シーリングリレーブロックの改善
このシーリング方法はシステムの運用に強力な保証を提供するが、スケールに問題があると考えられている。なぜなら、パラチェインの重要な情報の可用性(Availability)は、バリデータ全体の3分の1以上によって保証されている必要があるためである。そしてこれは、チェーンが追加されるにつれて、すべてのバリデータの責任範囲が増大することを意味する。

オープンコンセンサスネットワーク内のデータの可用性は本質的に未解決の問題であるが、検証ノードにかかるオーバーヘッドを軽減する方法がある。 1つ目の解決策は、バリデータはデータの可用性に対する責任を負うが、実際にデータを保存・通信・複製する必要はないことである。このデータを編集している（あるいはまったく同じ）照合者に関連している可能性がある。
また、（このデータをコンパイルする照合者に関係、または同等であるかもしれない）2次データ格納庫(silos)が、支払いに対する利子/収入の一部を提供しているバリデータ、と可用性を保証するというタスクを管理できる。

しかしながら、これにより一時的なスケーラビリティを得られるが、根本的な問題を解決することにはならない。パラチェーンの追加は、さらなるバリデータを必要とするため、長期的なネットワークリソースの消費量（特に帯域幅の点で）はチェーンの二乗に比例して増加する。

最終的には、合計バリデータ×合計入力情報のバンド幅の基礎制限に手の打ち止めとなるだろう。これは、信頼されていないネットワークが、他の多くのノードにデータストレージのタスクを適切に分配することができないことに起因している。

6.5.1. 待ち時間の導入
この規則を緩和する1つの方法は、即時性の概念を緩和することだ。すぐにではなく、最終的にのみ可用性に投票する33％+ 1のバリデータを要求することで、指数関数的データ伝播をより有効に活用し、データ交換のピークを平準化することができる。 （証明されていないが）最も有り得そうな式は次のようになる。

（1）待ち時間=参加者×チェーン　（ latency = participants x chains ）

現在のモデルでは、システムのサイズはチェーンの数に比例してスケールし、それにより処理が確実に分散される。各チェーンは少なくとも1人のバリデータを必要とし、可用性検証を一定比率のバリデータに固定するため、参加者はチェーンの数が増えるにつれて同様に大きくなる。そしてこれに終始する：

（2）待ち時間= size2　( latency = size2 )

つまり、必要な帯域幅と可用性がネットワーク全体で認識されるまでの待ち時間（ファイナライズ前のブロック数とも呼ばれる）は、システムのスケールの2乗に比例して増加する。これは大きな成長要因であり、注目に値するロードブロッカーになる可能性があり、「平坦ではない（non-flat）」パラダイム（リレーチェーンのツリーを介したマルチレベルルーティングを行うため、複数の「Polkadots」を階層的に構成するなど）を実現する。

6.5.2.パブリック参加
もう1つの可能性のある方向性は、マイクロクレームシステムを通じたプロセスへの一般参加を許可することである。Fishermanと同様に、入手可能性を主張する検証者を監視する外部の存在がありえる。彼らの仕事は、そのような可用性を示すことができないように見える人を見つけることで、他のバリデータにミクロの苦情を申し立てることができる。システムをほとんど役に立たなくするようなシビル(sybil)攻撃を軽減するために、電力またはステークボンドを使用することができる。

6.5.3. 可用性の保証人
最終的な方法は、「可用性保証者」として2組目のステイク済みバリデータをノミネートすることである。これらは通常のバリデータと同じように結合され、同じセットから取られることさえ可能だ（少なくともセッションごとに、長期間にわたって選択される）。通常のバリデータとは異なり、パラチェインを切り替えるのではなく、重要なインターチェーンデータの可用性を証明するために単一のグループを形成する。

これには、参加者とチェーン間の同等性が緩和されるという利点がある。本質的に、チェーンは（元のチェーンバリデータセットと一緒に）成長することができるが、参加者、特にデータ可用性テストに参加している参加者は、最低限の準線形(sub-linear)に留まる可能性がある。

6.5.4. 照合者（Collat​​or）の設定
このシステムの重要な側面の1つは、どのパラチェイン内にもブロックを作成するための健全なコレクターの選択が行われていることを確認することである。単一の照合者がパラチェインを支配していた場合、外部データの可用性が不足する可能性はそれほど明白ではないため、いくつかの攻撃がより実行可能となる。

1つの選択肢は、擬似ランダムメカニズムでパラチェインブロックを人為的に重み付けすることにより、照合者の多様化を行うことだ。第一に、合意メカニズムの一部として、バリデーターが「より重い」と判断したパラチェインブロック候補を支持することを要求する。同様に、バリデータが最も重いブロックを提案することを動機付ける必要がある - これは彼らの報酬の一部を候補の重さに比例させることを通してなされるかもしれない。

照合者が彼らの候補が勝利候補として選択される合理的公平な機会が与えられることを確実にするために、パラチェインブロック候補の具体的な重みを各照合者のランダム関数で決定する。たとえば、照合者のアドレスと、作成されているブロックのポイントの近くで決定される暗号的に安全な疑似乱数の間のXOR距離の測定（概念的な「勝利チケット」）。これにより、各照合者（より具体的には各照合者のアドレス）に、候補者ブロックが他のすべての候補者よりも「勝つ」というランダムなチャンスが与えられる。

1人の照合者が勝利チケットに近いアドレスを「マイニング」してそのブロックをお気に入りにするというシビル攻撃を防ぐために、照合者のアドレスに慣性（inertia）を導入する。これは、アドレスに基準金額の資金があることを要求するのと同じくらい簡単かもしれない。よりエレガントなアプローチは、問題のアドレスに溜まっている資金の量で、勝利チケットの近くに重みを付けることだ。モデリングはまだ行われていないが、このメカニズムによって、ごくわずかなステイク者でも照合者として貢献できる可能性がある。



6.5.5. 太りすぎた（Overweight）ブロック
バリデータセットが危険に晒されている場合、有効ではあるが実行と検証に時間がかかるブロックを作成して提案する可能性がある。バリデータグループは、ショートカットを可能にする特定の情報が既に知られていない限り、実行するのに非常に長い時間がかかるブロックを合理的に形成できるので問題となる。 1人の照合者がその情報を知っていれば、他の古いブロック処理をしている人に対し、自分の候補者を受け入れさせることに明らかなアドバンテージとなる。これらのブロックを太りすぎ(Overweight)と呼ぶ。

追加の注意点はあるが、これらのブロックを送信して検証するバリデータに対する保護は、無効なブロックとほぼ同じように考えられる。ブロックを実行するのにかかる時間は主観的であり、投票の最終結果は不正行為については、基本的に3つに分類される。 1つの可能性は、ブロックが明らかに太りすぎではないということだ - この場合、3分の2以上がブロックをある限度内で実行できると宣言している（例えば、ブロック間の合計許容時間の50％）。２つ目は、ブロックが確実に太り過ぎであるということだ。これは、3分の2以上が、制限内でブロックを実行できないと宣言した場合。 最後の可能性はバリデータ間の意見が半分に割れることだ。この場合、我々は何らかに比例した罰をすることを選ぶかもしれない。

バリデータがいつ太りすぎのブロックを提案している可能性があるかをバリデータが確実に予測できるようにするには、ブロックごとに自分のパフォーマンスに関する情報を公開するように要求することを勧める。十分な期間にわたって、彼らが判断しようとしている仲間と比較して彼らの処理速度をプロファイルすることを可能にするはずだ。

6.5.6. コレーター保険
バリデータに関して１つの問題が残っている：ＰｏＷネットワークとは異なり、有効性について照合者のブロックをチェックするために、彼らは実際にその中のトランザクションを実行しなければならない。悪意のある照合者は、無効な、または太りすぎのブロックをバリデータに供給することができ、グリーフ（リソースの無駄遣い）を引き起こし、潜在的にかなりの機会損失を強制する。

これを軽減するために、バリデータ側で単純な戦略を提案する。第一に、バリデータに送られるパラチェインブロック候補は資金があるリレーチェーン口座から署名されなければならない。そうでない場合、バリデータはすぐにそれを削除する必要がある。第二に、そのような候補者は、ある上限までの口座内の資金の額、過去に丁寧に提案した過去のブロック数までの組み合わせ（例えば、乗算）によって優先的に順序付けされるべきである。 ）、および前述のように当選チケットへの近接係数。上限は、無効なブロックを送信した場合にバリデータに支払われる懲罰的損害賠償と同じでなければならない。

無効または過重のブロック候補を検証者に送信することを照合者にさせないために、検証者は不正な照合者の口座にある資金の一部または全部を不正な検証者に移すという影響で、不正行為を主張する違反ブロックを含むトランザクションを次のブロックに入れることができる。このタイプの取引は、罰金の前に照合者が資金を取り出すことをできないようにするために、他の取引を前倒しで実行する。損害賠償として譲渡される資金の額は、まだモデル化されていない動的パラメータだが、生じたグリーフのレベルを反映するためのバリデータブロック報酬の割合となる可能性がある。悪意のある検証者が照合者の資金を勝手に没収するのを防ぐために、照合者は小額の入金の見返りにランダムに選択された検証者の陪審員による検証者の決定に上訴することができる。彼らがバリデータの支持を得た場合、デポジットは彼らによって消費される。そうでなければ、保証金は返却され、バリデーターは罰金を科される（バリデーターははるかにアーチ型の位置にあるので、罰金はかなり多額になるだろう）。

6.6. チェーン間トランザクションルーティング
チェーン間トランザクションルーティングは、リレーチェーンとそのバリデータの重要なメンテナンスタスクの1つである。これは、転記されたトランザクションが、ある信頼要件を必要とせずに、ソースパラチェーンからの希望する出力から他のデスティネーションパラチェーンの非交渉入力になる方法を決定するロジックである。

私たちは上の言葉を慎重に選ぶ。特に、この投稿を明示的に承認したために、ソースパラチェイン内にトランザクションがあったことを要求しない。私たちのモデルに課せられる唯一の制約は、パラチェインが全体のブロック処理出力の一部としてパッケージされ、ブロックの実行の結果であるポストを提供しなければならないということだ。

これらのポストは複数のFIFOキューとして構成されている。リストの数はルーティングベースと呼ばれ、16前後になる場合がある。特に、この数は、マルチフェーズルーティングに頼らなくてもサポートできるパラチェインの数を表す。当初、Polkadotはこの種の直接ルーティングをサポートするが、最初の一連のパラチェーンをはるかに超えてスケ​​ールアウトする手段として、1つの可能な多相ルーティングプロセス（「ハイパールーティング」）の概要を説明する。

すべての参加者が次の2つのブロックn、n + 1のサブグループを知っていると仮定する。要約すると、ルーティングシステムは次の段階に従う。

- CollatorS : Contact members of V alidators[n][S]
- CollatorS: FOR EACH subgroup s: ensure at
least 1 member of V alidators[n][s] in contact
- CollatorS : FOR EACH subgroup s: assume egress[n − 1][s][S] is available (all incoming post
data to ‘S‘ from last block)
- CollatorS: Compose block candidate b for S:
(b.header, b.ext, b.proof, b.receipt, b.egress)
- CollatorS : Send proof information proof[S] = (b.header, b.ext, b.proof, b.receipt) to
V alidators[n][S]
- CollatorS : Ensure external transaction data b.ext
is made available to other collators and validators
- CollatorS : FOR EACH subgroup s: Send egress information egress[n][S][s] = (b.header, b.receipt, b.egress[s]) to the re- ceiving sub-group’s members of next block
V alidators[n + 1][s]
- V alidatorV : Pre-connect all same-set members
for next block: let N = Chain[n + 1][V ]; connect
all validators v such that Chain[n + 1][v] = N
- V alidatorV : Collate all data ingress for this block: FOR EACH subgroup s: Retrieve egress[n − 1][s][Chain[n][V ]], get from other val- idators v such that Chain[n][v] = Chain[n][V].Possibly going via randomly selected other val-
idators for proof of attempt.
- V alidatorV : Accept candidate proofs for this
block proof[Chain[n][V ]]. Vote block validity
- V alidatorV : Accept candidate egress data for next block: FOR EACH subgroup s, accept egress[n][s][N ]. Vote block egress availability; re- publish among interested validators v such that
Chain[n + 1][v] = Chain[n + 1][V ]. • V alidatorV : UNTIL CONSENSUS

ここで、egress [n] [from] [to]は、ブロック番号 'n'のparachain 'from'からparachain 'to'への投稿に対する現在の出力キュー情報である。 Collat​​orSは、パラチェインSのCollator。Validators [n] [s]は、ブロック番号nのパラチェインsのバリデータのセット。逆に、Chain [n] [v]はバリデータvがブロック番号nに割り当てられているパラチェイン。 block.egress [to]は、宛先parachainがtoである、あるparachainブロックブロックからの投稿の出力キュー。

照合者は、自分のブロックが正規になったことに基づいて料金を徴収するため、次のブロックの送信先ごとに、サブグループのメンバーに現在のブロックからの出力キューが通知される。バリデータは（パラチェイン）ブロックについてコンセンサスを形成することのみを奨励されている。原則として、バリデータは照合者と忠誠を尽くし、他の照合者のブロックが標準的になる可能性を減らすために共謀することができるが、これはパラチェインのバリデータをランダムに選択するため整理するのが困難であり、合意プロセスを妨げるパラチェインブロックに対して支払うべき料金の減少で擁護される可能性がある。

6.6.1. External Data Availability. Ensuring a parachain’s external data is actually available is a perennial issue with decentralised systems aiming to distribute workload across the network. At the heart of the issue is the availability problem which states that since it is neither possible to make a non-interactive proof of availability nor any sort of proof of non-availability, for a BFT system to properly validate any transition whose correctness relies upon the availability of some external data, the maximum number of acceptably Byzantine nodes, plus one, of the system must attest to the data being available.

For a system to scale out properly, like Polkadot, this invites a problem: if a constant proportion of validators must attest to the availability of the data, and assuming that validators will want to actually store the data before asserting it is available, then how do we avoid the problem of the bandwidth/storage requirements increasing with the system size (and therefore number of validators)? One possible answer would be to have a separate set of validators (availability guarantors), whose order grows sublinearly with the size of Polkadot as a whole. This is described in 6.5.3.

We also have a secondary trick. As a group, collators have an intrinsic incentive to ensure that all data is available for their chosen parachain since without it they are unable to author further blocks from which they can collect transaction fees. Collators also form a group, membership of which is varied (due to the random nature of parachain validator groups) non-trivial to enter and easy to prove. Recent collators (perhaps of the last few thousand blocks) are therefore allowed to issue challenges to the availability of external data for a particular parachain block to validators for a small bond.

Validators must contact those from the apparently offending validator sub-group who testified and either acquire and return the data to the collator or escalate the matter by testifying to the lack of availability (direct refusal to provide the data counts as a bond-confiscating offence, therefore the misbehaving validator will likely just drop the connection) and contacting additional validators to run the same test. In the latter case, the collator’s bond is returned.

Once a quorum of validators who can make such nonavailability testimonials is reached, they are released, the misbehaving sub-group is punished, and the block reverted.

6.6.2. Posts Routing. Each parachain header includes an egress-trie-root; this is the root of a trie containing the routing-base bins, each bin being a concatenated list of egress posts. Merkle proofs may be provided across parachain validators to prove that a particular parachain’s block had a particular egress queue for a particular destination parachain.

At the beginning of processing a parachain block, each other parachain’s egress queue bound for said block is merged into our block’s ingress queue. We assume strong, probably CSPR9, sub-block ordering to achieve a deterministic operation that offers no favouritism between any parachain block pairing. Collators calculate the new queue and drain the egress queues according to the parachain’s logic.

The contents of the ingress queue is written explicitly into the parachain block. This has two main purposes: firstly, it means that the parachain can be trustlessly synchronised in isolation from the other parachains. Secondly, it simplifies the data logistics should the entire ingress queue not be able to be processed in a single block; validators and collators are able to process following blocks without having to source the queue’s data specially.

If the parachain’s ingress queue is above a threshold amount at the end of block processing, then it is marked saturated on the relay-chain and no further messages may be delivered to it until it is cleared. Merkle proofs are used to demonstrate fidelity of the collator’s operation in the parachain block’s proof.

6.6.3. Critique. One minor flaw relating to this basic mechanism is the post-bomb attack. This is where all parachains send the maximum amount of posts possible to a particular parachain. While this ties up the target’s ingress queue at once, no damage is done over and above a standard transaction DoS attack.

Operating normally, with a set of well-synchronised and non-malicious collators and validators, for N parachains, N × M total validators and L collators per parachain, we can break down the total data pathways per block to:

Validator: M −1+L+L: M −1 for the other validators in the parachain set, L for each collator providing a candidate parachain block and a second L for each collator of the next block requiring the egress payloads of the previous block. (The latter is actually more like worst-case operation since it is likely that collators will share such data.)

Collator: M + kN : M for a connection to each relevant parachain block validator, kN for seeding the egress payloads to some subset of each parachain validator group for the next block (and possibly some favoured collator(s)).

As such, the data path ways per node grow linearly with the overall complexity of the system. While this is reasonable, as the system scales into hundreds or thousands of parachains, some communication latency may be absorbed in exchange for a lower complexity growth rate. In this case, a multi-phase routing algorithm may be used in order to reduce the number of instantaneous pathways at a cost of introducing storage buffers and latency.

6.6.4. Hyper-cube Routing. Hyper-cube routing is a mechanism which can mostly be build as an extension to the basic routing mechanism described above. Essentially, rather than growing the node connectivity with the number of parachains and sub-group nodes, we grow only with the logarithm of parachains. Posts may transit between several parachains’ queues on their way to final delivery.

Routing itself is deterministic and simple. We begin by limiting the number of bins in the ingress/egress queues; rather than being the total number of parachains, they are the routing-base (b) . This will be fixed as the number of parachains changes, with the routing-exponent (e) instead being raised. Under this model, our message volume grows with O(be), with the pathways remaining constant and the latency (or number of blocks required for delivery) with O(e).

Our model of routing is a hypercube of e dimensions, with each side of the cube having b possible locations. Each block, we route messages along a single axis. We alternate the axis in a round-robin fashion, thus guaranteeing worst-case delivery time of e blocks.

As part of the parachain processing, foreign-bound messages found in the ingress queue are routed immediately to the appropriate egress queue’s bin, given the current block number (and thus routing dimension). This process necessitates additional data transfer for each hop on the delivery route, however this is a problem itself which may be mitigated by using some alternative means of data payload delivery and including only a reference, rather than the full payload of the post in the post-trie.

An example of such a hyper-cube routing for a system with4parachains,b=2ande=2mightbe:

Phase 0, on each message M:
• sub0: if Mdest ∈ {2,3} then sendTo(2) else keep • sub1: if Mdest ∈ {2,3} then sendTo(3) else keep • sub2: if Mdest ∈ {0,1} then sendTo(0) else keep • sub3: if Mdest ∈ {0,1} then sendTo(1) else keep

Phase 1, on each message M:
• sub0: if Mdest ∈ {1,3} then sendTo(1) else keep • sub1: if Mdest ∈ {0,2} then sendTo(0) else keep • sub2: if Mdest ∈ {1,3} then sendTo(3) else keep • sub3: if Mdest ∈ {0,2} then sendTo(2) else keep

The two dimensions here are easy to see as the first two bits of the destination index; for the first block, the higher-order bit alone is used. The second block deals with the low-order bit. Once both happen (in arbitrary order) then the post will be routed.

6.6.5. Maximising Serendipity. One alteration of the basic proposal would see a fixed total of c2 − c validators, with c−1 validators in each sub-group. Each block, rather than there being an unstructured repartitioning of validators among parachains, instead for each parachain sub-group, each validator would be assigned to a unique and different parachain sub-group on the following block. This would lead to the invariant that between any two blocks, for any two pairings of parachain, there exists two validators who have swapped parachain responsibilities. While this cannot be used to gain absolute guarantees on availability (a single validator will occasionally drop offline, even if benevolent), it can nonetheless optimise the general case.

This approach is not without complications. The addition of a parachain would also necessitate a reorganisation of the validator set. Furthermore the number of validators, being tied to the square of the number of parachains, would start initially very small and eventually grow far too fast, becoming untenable after around 50 parachains. None of these are fundamental problems. In the first case, reorganisation of validator sets is something that must be done regularly anyway. Regarding the size of the validator set, when too small, multiple validators may be assigned to the same parachain, applying an integer factor to the overall total of validators. A multi-phase routing mechanism such as Hypercube Routing, discussed in 6.6.4 would alleviate the requirement for large number of validators when there is a large number of chains.

6.7. Parachain Validation. A validator’s main purpose is to testify, as a well-bonded actor, that a parachain’s block is valid, including but not limited to any state transition, any external transactions included, the execution of any waiting posts in the ingress queue and the final state of the egress queue. The process itself is fairly simple. Once the validator sealed the previous block they are free to begin working to provide a candidate parachain block candidate for the next round of consensus.

Initially, the validator finds a parachain block candidate through a parachain collator (described next) or one of its co-validators. The parachain block candidate data includes the block’s header, the previous block’s header, any external input data included (for Ethereum and Bitcoin, such data would be referred to as transactions, however in principle they may include arbitrary data structures for arbitrary purposes), egress queue data and internal data to prove state-transition validity (for Ethereum this would be the various state/storage trie nodes required to execute each transaction). Experimental evidence shows this full dataset for a recent Ethereum block to be at the most a few hundred KiB.

Simultaneously, if not yet done, the validator will be attempting to retrieve information pertaining to the previous block’s transition, initially from the previous block’s validators and later from all validators signing for the availability of the data.

Once the validator has received such a candidate block, they then validate it locally. The validation process is contained within the parachain class’s validator module, a consensus-sensitive software module that must be written for any implementation of Polkadot (though in principle a library with a C ABI could enable a single library to be shared between implementations with the appropriate reduction in safety coming from having only a single “reference” implementation).

The process takes the previous block’s header and verifies its identity through the recently agreed relay-chain block in which its hash should be recorded. Once the parent header’s validity is ascertained, the specific parachain class’s validation function may be called. This is a single function accepting a number of data fields (roughly those given previously) and returning a simple Boolean proclaiming the validity of the block.

Most such validation functions will first check the header-fields which are able to be derived directly from the parent block (e.g. parent hash, number). Following this, they will populate any internal data structures as necessary in order to process transactions and/or posts. For an Ethereum-like chain this amounts to populating a trie database with the nodes that will be needed for the full execution of transactions. Other chain types may have other preparatory mechanisms.

Once done, the ingress posts and external transactions (or whatever the external data represents) will be enacted, balanced according to chain’s specification. (A sensible default might be to require all ingress posts be processed before external transactions be serviced, however this should be for the parachain’s logic to decide.) Through this enactment, a series of egress posts will be created and it will be verified that these do indeed match the collator’s candidate. Finally, the properly populated header will be checked against the candidate’s header.

With a fully validated candidate block, the validator can then vote for the hash of its header and send all requisite validation information to the co-validators in its subgroup.

6.7.1. Parachain Collators. Parachain collators are unbonded operators who fulfill much of the task of miners on the present-day blockchain networks. They are specific to a particular parachain. In order to operate they must maintain both the relay-chain and the fully synchronised parachain.

The precise meaning of “fully synchronised” will depend on the class of parachain, though will always include the present state of the parachain’s ingress queue. In Ethereum’s case it also involves at least maintaining a Merkle-tree database of the last few blocks, but might also include various other data structures including Bloom filters for account existence, familial information, logging outputs and reverse lookup tables for block number.

In addition to keeping the two chains synchronised, it must also “fish” for transactions by maintaining a transaction queue and accepting properly validated transactions from the public network. With the queue and chain, it is able to create new candidate blocks for the validators chosen at each block (whose identity is known since the relaychain is synchronised) and submit them, together with the various ancillary information such as proof-of-validity, via the peer network.

For its trouble, it collects all fees relating to the transactions it includes. Various economics float around this arrangement. In a heavily competitive market where there is a surplus of collators, it is possible that the transaction fees be shared with the parachain validators to incentivise the inclusion of a particular collator’s block. Similarly, some collators may even raise the required fees that need to be paid in order to make the block more attractive to validators. In this case, a natural market should form with transactions paying higher fees skipping the queue and having faster inclusion in the chain.

6.8. Networking. Networking on traditional blockchains like Ethereum and Bitcoin has rather simple requirements. All transactions and blocks are broadcast in a simple undirected gossip. Synchronisation is more involved, especially with Ethereum but in reality this logic was contained in the peer strategy rather than the protocol itself which resolved around a few request and answer message types.

While Ethereum made progress on current protocol offerings with the devp2p protocol, which allowed for many subprotocols to be multiplexed over a single peer connection and thus have the same peer overlay support many p2p protocols simultaneously, the Ethereum portion of the protocol still remained relatively simple and the p2p protocol as a while remains unfinished with important functionality missing such as QoS support. Sadly, a desire to create a more ubiquitous “web 3” protocol largely failed, with the only projects using it being those explicitly funded from the Ethereum crowd-sale.

The requirements for Polkadot are rather more substantial. Rather then a wholly uniform network, Polkadot has several types of participants each with different requirements over their peer makeup and several network “avenues” whose participants will tend to converse about particular data. This means a substantially more structured network overlay—and a protocol supporting that— will likely be necessary. Furthermore, extensibility to facilitate future additions such as new kinds of “chain” may themselves require a novel overlay structure.

While an in-depth discussion of how the networking protocol may look is outside of the scope of this document, some requirements analysis is reasonable. We can roughly break down our network participants into two sets (relay-chain, parachains) each of three subsets. We can also state that each of the parachain participants are only interested in conversing between themselves as opposed to participants in other parachains:

- Relay-chain participants:
- Validators: P, split into subsets P[s] for each parachain	
- Availability Guarantors: A (this may be represented by Validators in the basic form of the protocol)
- Relay-chain clients: M (note members of each parachain set will also tend to be members of M)
- Parachain participants:
- Parachain Collators: C[0], C[1], . . .
- Parachain Fishermen: F[0], F[1], . . .
- Parachain clients: S[0], S[1], . . .
- Parachain light-clients: L[0], L[1], . . .

In general we name particular classes of communication will tend to take place between members of these sets:

- P|A <-> P|A: The full set of validators/guarantors must be well-connected to achieve consensus.
- P[s] <-> C[s] | P[s]: Each validator as a member of a given parachain group will tend to gossip with other such members as well as the collators of that parachain to discover and share block candidates.
- A <-> P[s] | C | A: Each availability guarantor will need to collect consensus-sensitive cross-chain data from the validators assigned to it; collators may also optimise the chance of consensus on their block by advertising it to availability guarantors. Once they have it, the data will be disbursed to other such guarantor to facilitate consensus.
- P[s] <-> A | P[s']: Parachain validators will need to collect additional input data from the previous set of validators or the availability guarantors.
- F[s]<->P:When reporting, fishermen may place a claim with any participant.
- M <-> M | P | A: General relay-chain clients disburse data from validators and guarantors.
- S[s] <-> S[s] | P[s] | A: Parachain clients disburse data from the validator/guarantors.
- L[s] <-> L[s] | S[s]: Parachain light clients disburse data from the full clients.

To ensure an efficient transport mechanism, a “flat” overlay network—like Ethereum’s devp2p—where each node does not (non-arbitrarily) differentiate fitness of its peers is unlikely to be suitable. A reasonably extensible peer selection and discovery mechanism will likely need to be included within the protocol as well as aggressive planning an lookahead to ensure the right sort of peers are “serendipitously” connected at the right time.

The precise strategy of peer make-up will be different for each class of participant: for a properly scaled-out multi-chain, collators will either need to be continuously reconnecting to the accordingly elected validators, or will need on-going agreements with a subset of the validators to ensure they are not disconnected during the vast majority of the time that they are useless for that validator. Collators will also naturally attempt to maintain one or more stable connections into the availability guarantor set to ensure swift propagation of their consensus-sensitive data.

Availability guarantors will mostly aim to maintain a stable connection to each other and to validators (for consensus and the consensus-critical parachain data to which they attest), as well as to some collators (for the parachain data) and some fishermen and full clients (for dispersing information). Validators will tend to look for other validators, especially those in the same sub-group and any collators that can supply them with parachain block candidates.

Fishermen, as well as general relay-chain and parachain clients will generally aim to keep a connection open to a validator or guarantor, but plenty of other nodes similar to themselves otherwise. Parachain light clients will similarly aim to be connected to a full client of the parachain, if not just other parachain light-clients.

6.8.1. The Problem of Peer Churn. In the basic protocol proposal, each of these subsets constantly alter randomly with each block as the validators assigned to verify the parachain transitions are randomly elected. This can be a problem should disparate (non-peer) nodes need to pass data between each other. One must either rely on a fairly-distributed and well-connected peer network to ensure that the hop-distance (and therefore worst-case latency) only grows with the logarithm of the network size (a Kademlia-like protocol [13] may help here), or one must introduce longer block times to allow the necessary connection negotiation to take place to keep a peer-set that reflects the node’s current communication needs.

Neither of these are great solutions: long block times being forced upon the network may render it useless for particular applications and chains. Even a perfectly fair and connected network will result in substantial wastage of bandwidth as it scales due to uninterested nodes having to forward data useless to them.

While both directions may form part of the solution, a reasonable optimisation to help minimise latency would be to restrict the volatility of these parachain validator sets, either reassigning the membership only between series of blocks (e.g. in groups of 15, which at a 4 second block time would mean altering connections only once per minute) or by rotating membership in an incremental fashion, e.g. changing by one member at a time (e.g. if there are 15 validators assigned to each parachain, then on average it would be a full minute between completely unique sets). By limiting the amount of peer churn, and ensuring that advantageous peer connections are made well in advance through the partial predictability of parachain sets, we can help ensure each node keep a permanently serendipitous selection of peers.

6.8.2. Path to an Effective Network Protocol.

 Likely the most effective and reasonable development effort will focus on utilising a pre-existing protocol rather than rolling our own. Several peer-to-peer base protocols exist that we may use or augment including Ethereum’s own devp2p [22], IPFS’s libp2p [1] and GNU’s GNUnet [4]. A full review of these protocols and their relevance for building a modular peer network supporting certain structural guarantees, dynamic peer steering and extensible sub-protocols is well beyond the scope of this document but will be an important step in the implementation of Polkadot. 