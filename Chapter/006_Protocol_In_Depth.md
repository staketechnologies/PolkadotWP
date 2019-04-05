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

6.5.2. Public Participation. One more possible direction is to enlist public participation in the process through a micro-complaints system. Similar to the fishermen, there could be external parties to police the validators who claim availability. Their task is to find one who appears unable to demonstrate such availability. In doing so they can lodge a micro-complaint to other validators. PoW or a staked bond may be used to mitigate the sybil attack which would render the system largely useless.

6.5.3. Availability Guarantors. A final route would be to nominate a second set of bonded validators as “availability guarantors”. These would be bonded just as with the normal validators, and may even be taken from the same set (though if so, they would be chosen over a long-term period, at least per session). Unlike normal validators, they would not switch between parachains but rather would form a single group to attest to the availability of all important interchain data.

This has the advantage of relaxing the equivalence between participants and chains. Essentially, chains can grow (along with the original chain validator set), whereas the participants, and specifically those taking part in data availability testament, can remain at the least sub-linear and quite possibly constant.

6.5.4. Collator Preferences. One important aspect of this system is to ensure that there is a healthy selection of collators creating the blocks in any given parachain. If a single collator dominated a parachain then some attacks become more feasible since the likelihood of the lack of availability of external data would be less obvious.

One option is to artificially weight parachain blocks in a pseudo-random mechanism in order to favour a wide variety of collators. In the first instance, we would require as part of the consensus mechanism that validators favour parachain block candidates determined to be “heavier”. Similarly, we must incentivise validators to attempt to suggest the weightiest block they can find—this could be done through making a portion of their reward proportional to the weight of their candidate.

To ensure that collators are given a reasonable fair chance of their candidate being chosen as the winning candidate in consensus, we make the specific weight of a parachain block candidate determinate on a random function connected with each collator. For example, taking the XOR distance measure between the collator’s address and some cryptographically-secure pseudorandom number determined close to the point of the block being created (a notional “winning ticket”). This effectively gives each collator (or, more specifically, each collator’s address) a random chance of their candidate block “winning” over all others.

To mitigate the sybil attack of a single collator “mining” an address close to the winning ticket and thus being a favourite each block, we would add some inertia to a collator’s address. This may be as simple as requiring them to have a baseline amount of funds in the address. A more elegant approach would be to weight the proximity to the winning ticket with the amount of funds parked at the address in question. While modelling has yet to be done, it is quite possible that this mechanism enables even very small stakeholders to contribute as a collator.



6.5.5. Overweight Blocks. If a validator set is compromised, they may create and propose a block which though valid, takes an inordinate amount of time to execute and validate. This is a problem since a validator group could reasonably form a block which takes a very long time to execute unless some particular piece of information is already known allowing a short cut, e.g. factoring a large prime. If a single collator knew that information, then they would have a clear advantage in getting their own candidates accepted as long as the others were busy processing the old block. We call these blocks overweight.

Protection against validators submitting and validating these blocks largely falls under the same guise as for invalid blocks, though with an additional caveat: Since the time taken to execute a block (and thus its status as overweight) is subjective, the final outcome of a vote on misbehaviour will fall into essentially three camps. One possibility is that the block is definitely not overweight— in this case more than two-thirds declare that they could execute the block within some limit (e.g. 50% of the total time allowed between blocks). Another is that the block is definitely overweight—this would be if more than two-thirds declare that they could not execute the block within said limit. One final possibility is a fairly equal split of opinion between validators. In this case, we may choose to do some proportionate punishment.

To ensure validators can predict when they may be proposing an overweight block, it may be sensible to require them to publish information on their own performance for each block. Over a sufficient period of time, this should allow them to profile their processing speed relative to the peers that would be judging them.

6.5.6. Collator Insurance. One issue remains for validators: unlike with PoW networks, to check a collator’s block for validity, they must actually execute the transactions in it. Malicious collators can feed invalid or overweight blocks to validators causing them grief (wasting their resources) and exacting a potentially substantial opportunity cost.

To mitigate this, we propose a simple strategy on the part of validators. Firstly, parachain block candidates sent to validators must be signed from a relay chain account with funds; if they are not, then the validator should drop it immediately. Secondly, such candidates should be ordered in priority by a combination (e.g. multiplication) of the amount of funds in the account up to some cap, the number of previous blocks that the collator has successfully proposed in the past (not to mention any previous punishments), and the proximity factor to the winning ticket as discussed previously. The cap should be the same as the punitive damages paid to the validator in the case of them sending an invalid block.

To disincentivise collators from sending invalid or overweight block candidates to validators, any validator may place in the next block a transaction including the offending block alleging misbehaviour with the effect of transferring some or all of the funds in the misbehaving collator’s account to the aggrieved validator. This type of transaction front-runs any others to ensure the collator cannot remove the funds prior to the punishment. The amount of funds transferred as damages is a dynamic parameter yet to be modelled but will likely be a proportion of the validator block reward to reflect the level of grief caused. To prevent malicious validators arbitrarily confiscating collators’ funds, the collator may appeal the validator’s decision with a jury of randomly chosen validators in return for placing a small deposit. If they find in the validator’s favour, the deposit is consumed by them. If not, the deposit is returned and the validator is fined (since the validator is in a much more vaulted position, the fine will likely be rather hefty).

6.6. Interchain Transaction Routing. Interchain transaction routing is one of the essential maintenance tasks of the relay-chain and its validators. This is the logic which governs how a posted transaction (often shortened to simply “post”) gets from being a desired output from one source parachain to being a non-negotiable input of another destination parachain without any trust requirements.

We choose the wording above carefully; notably we don’t require there to have been a transaction in the source parachain to have explicitly sanctioned this post. The only constraints we place upon our model is that parachains must provide, packaged as a part of their overall block processing output, the posts which are the result of the block’s execution.

These posts are structured as several FIFO queues; the number of lists is known as the routing base and may be around 16. Notably, this number represents the quantity of parachains we can support without having to resort to multi-phase routing. Initially, Polkadot will support this kind of direct routing, however we will outline one possible multi-phase routing process (“hyper-routing”) as a means of scaling out well past the initial set of parachains.

We assume that all participants know the subgroupings for next two blocks n, n + 1. In summary, the routing system follows these stages:

- CollatorS : Contact members of V alidators[n][S]
- CollatorS: FOR EACH subgroup s: ensure at least 1 member of V alidators[n][s] in contact
- CollatorS : FOR EACH subgroup s: assume egress[n − 1][s][S] is available (all incoming post data to ‘S‘ from last block)
- CollatorS: Compose block candidate b for S: (b.header, b.ext, b.proof, b.receipt, b.egress)
- CollatorS : Send proof information proof[S] = (b.header, b.ext, b.proof, b.receipt) to Validators[n][S]
- CollatorS : Ensure external transaction data b.extis made available to other collators and validators
- CollatorS : FOR EACH subgroup s: Send egress information egress[n][S][s] = (b.header, b.receipt, b.egress[s]) to the receiving sub-group’s members of next block Validators[n + 1][s]
- ValidatorV : Pre-connect all same-set members for next block: let N = Chain[n + 1][V ]; connect all validators v such that Chain[n + 1][v] = N
- ValidatorV : Collate all data ingress for this block: FOR EACH subgroup s: Retrieve egress[n − 1][s][Chain[n][V ]], get from other validators v such that Chain[n][v] = Chain[n][V]. Possibly going via randomly selected other validators for proof of attempt.
- ValidatorV : Accept candidate proofs for this block proof[Chain[n][V ]]. Vote block validity
- ValidatorV : Accept candidate egress data for next block: FOR EACH subgroup s, accept egress[n][s][N ]. Vote block egress availability; republish among interested validators v such that Chain[n + 1][v] = Chain[n + 1][V ]. • V alidatorV : UNTIL CONSENSUS

Where: egress[n][from][to] is the current egress queue information for posts going from parachain ‘from‘, to parachain ‘to‘ in block number ‘n‘. CollatorS is a collator for parachain S. V alidators[n][s] is the set of validators for parachain s at block number n. Conversely, Chain[n][v] is the parachain to which validator v is assigned on block number n. block.egress[to] is the egress queue of posts from some parachain block block whose destination parachain is to.

Since collators collect (transaction) fees based upon their blocks becoming canonical they are incentivised to ensure that for each next-block destination, the subgroup’s members are informed of the egress queue from the present block. Validators are incentivised only to form a consensus on a (parachain) block, as such they care little about which collator’s block ultimately becomes canonical. In principle, a validator could form an allegiance with a collator and conspire to reduce the chances of other collators’ blocks becoming canonical, however this is both difficult to arrange due to the random selection of validators for parachains and could be defended against with a reduction in fees payable for parachain blocks which hold up the consensus process.

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